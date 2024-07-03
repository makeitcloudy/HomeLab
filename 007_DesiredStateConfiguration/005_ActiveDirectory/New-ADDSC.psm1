function Install-Modules
{
    <#
    .PARAMETER modules
    $modules = @{
    'Module1' = '1.0'
    'Module2' = '2.3'
    'Module3' = '3.5'
}
    #>
    param (
        [Parameter(Mandatory)]
        $modules
    )
    if ( -not(Get-PSRepository -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*psgallery*' }) )
    {
        Write-Host -fore Magenta '>> Fixing PsGallery, please wait... <<'
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        Register-PSRepository -Default -Verbose
    }
    foreach ($moduleName in $modules.Keys)
    {
        $desiredVersion = $modules[$moduleName]
        $installedModule = Get-Module -Name $moduleName -ListAvailable -ErrorAction SilentlyContinue | Where-Object { $_.Version -eq $desiredVersion }
        if ($null -eq $installedModule)
        {
            Write-Host "$moduleName version $desiredVersion is not installed on $($Env:COMPUTERNAME). Installing..."
            Install-Module -Name $moduleName -RequiredVersion $desiredVersion -Force -Confirm:$false
            Write-Host "$moduleName version $desiredVersion has been installed on $($Env:COMPUTERNAME)."
        }
        else
        {
            Write-Host "$moduleName version $desiredVersion is already installed on $($Env:COMPUTERNAME)." -ForegroundColor Green
        }
    }
}

function Create-SelfSignedCert
{
    param (
        $certFolder = 'C:\dsc\cert'
        ,
        $certStore = 'Cert:\LocalMachine\My'
        ,
        $validYears = 2
    )
    $pubCertPath = Join-Path -Path $certFolder -ChildPath DscPubKey.cer
    $expiryDate = (Get-Date).AddYears($validYears)
    # You may want to delete this file after completing
    $privateKeyPath = Join-Path -Path $ENV:TEMP -ChildPath DscPrivKey.pfx
    $privateKeyPass = Read-Host -AsSecureString -Prompt 'Private Key Password'
    if (!(Test-Path -Path $certFolder))
    {
        New-Item -Path $certFolder -Type Directory | Out-Null
    }
    $cert = New-SelfSignedCertificate -Type DocumentEncryptionCertLegacyCsp `
        -DnsName 'DscEncryption' `
        -HashAlgorithm SHA512 `
        -NotAfter $expiryDate `
        -KeyLength 4096 `
        -CertStoreLocation $certStore
    $cert | Export-PfxCertificate -FilePath $privateKeyPath `
        -Password $privateKeyPass `
        -Force
    $cert | Export-Certificate -FilePath $pubCertPath
    Import-Certificate -FilePath $pubCertPath `
        -CertStoreLocation $certStore
    Import-PfxCertificate -FilePath $privateKeyPath `
        -CertStoreLocation $certStore `
        -Password $privateKeyPass | Out-Null
}

configuration DomainFirstDC {
    Param(
        [Parameter(Position = 0)]
        [String]$DomainMode = 'WinThreshold',
        [Parameter(Position = 1)]
        [String]$ForestMode = 'WinThreshold',
        [Parameter(Position = 2, Mandatory = $true)]
        [PSCredential]$DomainCredential,
        [Parameter(Position = 3, Mandatory = $true)]
        [PSCredential]$SafemodePassword,
        [Parameter(Position = 4)]
        [String]$NetAdapterName = 'Ethernet0',
        [array]$featureNames = @(
            'RSAT-AD-PowerShell',
            'RSAT-ADDS',
            'RSAT-AD-AdminCenter',
            'RSAT-ADDS-Tools',
            'RSAT-ADLDS'
        )

    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName ActiveDirectoryDsc -ModuleVersion '6.4.0'
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion '9.0.0'
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion '9.1.0'

    #* -------------------------------------------------------------------------------- FIRST DC ONLY
    Node $AllNodes.Where{ $_.Role -eq 'RootDomainController' }.NodeName  {

        # * LOCALE and TIME
        SystemLocale SystemLocaleExample
        {
            IsSingleInstance = 'Yes'
            SystemLocale     = $Node.Locale
        }

        Timezone TimeZoneConfiguration {
            TimeZone            = $NODE.TimeZone
            IsSingleInstance    = 'Yes'
        }

        $ntpServerValue1 = [string]($NODE.NTPServer | ForEach-Object { $_, (',0x{0:x}' -f '8') }) -replace ' ,',","
        $ntpServerValue2 = [string]($NODE.FailOverNTPServers | %{$_, (",0x{0:x}" -f "a")}) -replace " ,",","
        $ntpServerValue = $ntpServerValue1, $ntpServerValue2 -join " "

        $ntpservers = @()
        $ntpservers += $NODE.NTPServer
        $ntpservers += $NODE.FailOverNTPServers | %{$_}

        $timeRootPath = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\W32Time"
        $NTPListPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers"

        Service w32time
        {
            Name = "W32Time"
            State = "Running"
            StartupType = "Automatic"
        }

        Registry NTPType
        {
            Key = "$timeRootPath\Parameters"
            ValueName = "Type"
            ValueType = "String"
            ValueData = "NTP"
            Ensure = "Present"
        }

        Registry NTPServer
        {
            Key = "$timeRootPath\Parameters"
            ValueName = "NTPServer"
            ValueType = "String"
            ValueData = $ntpServerValue
            Ensure = "Present"
        }

        # * RESET LOCAL ADMIN PASSWORD
        # this will be used as the default domain admin's password
        User DomainAdmin
        {
            Ensure   = 'Present'
            UserName = 'Administrator'
            Password = $DomainCredential
        }

        # * NETWORKING
        NetAdapterName InterfaceRename
        {
            NewName = $NetAdapterName
        }

        IPAddress StaticIP
        {
            InterfaceAlias = $NetAdapterName
            AddressFamily  = 'IPv4'
            IPAddress      = $NODE.IPv4Address
            DependsOn      = '[NetAdapterName]InterfaceRename'
        }

        DnsServerAddress SetDnsServer
        {
            InterfaceAlias = $NetAdapterName
            AddressFamily  = 'IPv4'
            Address        = $NODE.DNSServers
            DependsOn      = '[NetAdapterName]InterfaceRename'
        }

        FirewallProfile DomainFirewallOff
        {
            Name    = 'Domain'
            Enabled = 'False'
        }

        FirewallProfile PublicFirewallOff
        {
            Name    = 'Public'
            Enabled = 'False'
        }

        FirewallProfile PrivateFirewallOff
        {
            Name    = 'Private'
            Enabled = 'False'
        }

        # * INSTALL FEATURES
        WindowsFeature ADDSFeatureInstall
        {
            Ensure    = 'Present'
            Name      = 'AD-Domain-Services'
            DependsOn = '[NetAdapterName]InterfaceRename', '[User]DomainAdmin'
        }

        ## additional Windows Features [non-essential but good to have!]
        foreach ($featureName in $featureNames)
        {
            WindowsFeature $featureName
            {
                Ensure    = 'Present'
                Name      = $featureName
                DependsOn = '[WindowsFeature]ADDSFeatureInstall'
            }
        }

        $DomainContainer = "DC=$($NODE.DomainName.Split('.') -join ',DC=')"

        ADDomain 'ThisDomain'
        {
            DomainName                    = $NODE.DomainName
            DomainNetbiosName             = $NODE.DomainNetbiosName
            ForestMode                    = $ForestMode
            DomainMode                    = $DomainMode
            Credential                    = $DomainCredential
            SafemodeAdministratorPassword = $SafemodePassword
            DatabasePath                  = $NODE.NTDSPath
            LogPath                       = $NODE.LogPath
            SysvolPath                    = $NODE.SysvolPath
            DependsOn                     = '[WindowsFeature]ADDSFeatureInstall'
        }

        WaitForADDomain 'WaitForDomainInstall'
        {
            DomainName   = $NODE.DomainName
            Credential   = $DomainCredential
            RestartCount = 2
            # RebootRetryCount     = 2
            # RetryCount           = 10
            # RetryIntervalSec     = 60
            DependsOn    = '[ADDomain]ThisDomain'
        }

        # * STARTER ORGANIZATIONAL UNITS [OPTIONAL]
        ADOrganizationalUnit 'CreateAccountsOU'
        {
            Name       = 'Accounts'
            Path       = $DomainContainer
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[WaitForADDomain]WaitForDomainInstall'
        }

        ADOrganizationalUnit 'AdminOU'
        {
            Name       = 'Admin'
            Path       = "OU=Accounts,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]CreateAccountsOU'
        }

        ADOrganizationalUnit 'BusinessOU'
        {
            Name       = 'Business'
            Path       = "OU=Accounts,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]CreateAccountsOU'
        }

        ADOrganizationalUnit 'ServiceOU'
        {
            Name       = 'Service'
            Path       = "OU=Accounts,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]CreateAccountsOU'
        }

        # * PASSWORD POLICY
        ADDomainDefaultPasswordPolicy 'DefaultPasswordPolicy'
        {
            DomainName        = $NODE.DomainName
            ComplexityEnabled = $NODE.ComplexityEnabled
            MinPasswordLength = $NODE.MinPasswordLength
            DependsOn         = '[ADDomain]ThisDomain', '[WindowsFeature]ADDSFeatureInstall'
        }

        # * ENABLE RECYCLEBIN
        ADOptionalFeature RecycleBin
        {
            FeatureName                       = 'Recycle Bin Feature'
            EnterpriseAdministratorCredential = $DomainCredential
            ForestFQDN                        = $NODE.DomainName
            DependsOn                         = '[ADDomain]ThisDomain', '[WindowsFeature]ADDSFeatureInstall'
        }

        # * SITES AND SUBNETS

        # # sites
        ADReplicationSite 'FirstSite'
        {
            Ensure                     = 'Present'
            Name                       = $NODE.FirstSite
            RenameDefaultFirstSiteName = $true
            DependsOn                  = '[ADDomain]ThisDomain', '[WindowsFeature]ADDSFeatureInstall'
        }

        foreach ($site in $NODE.AdditionalSites)
        {
            ADReplicationSite $site
            {
                Ensure    = 'Present'
                Name      = $site
                DependsOn = '[ADDomain]ThisDomain', '[WindowsFeature]ADDSFeatureInstall'
            }
        }

        # # site replications
        ADReplicationSiteLink 'PrimarySitelink'
        {
            Name                          = 'PrimarySitelink'
            SitesIncluded                 = $NODE.SitelinkPrimaryMembers
            Cost                          = 100
            ReplicationFrequencyInMinutes = 15
            Ensure                        = 'Present'
        }

        ADReplicationSiteLink 'SecondarySitelink'
        {
            Name                          = 'SecondarySitelink'
            SitesIncluded                 = $NODE.SitelinkSecondaryMembers
            Cost                          = 159
            ReplicationFrequencyInMinutes = 20
            Ensure                        = 'Present'
        }

        # # site subnets
        ADReplicationSubnet 'London-OY_10.2.134.0/24'
        {

            Name        = '10.2.134.0/24'
            Site        = 'London-OY'
            Location    = 'Olivers Yard DC'
            Description = 'Infrastructure Management Subnet'

        }

        ADReplicationSubnet 'London-SH_10.24.29.0/24'
        {

            Name        = '10.2.134.0/24'
            Site        = 'London-SH'
            Location    = 'Shoreditch DC'
            Description = 'Infrastructure Management Subnet'

        }


        # * LCM CONFIGURATION

        LocalConfigurationManager
        {
            CertificateId      = $NODE.Thumbprint
            RebootNodeIfNeeded = $true
        }

    }

}

configuration DomainAdditionalDCs {
    Param(
        [Parameter(Position = 0)]
        [String]$DomainMode = 'WinThreshold',
        [Parameter(Position = 1)]
        [String]$ForestMode = 'WinThreshold',
        [Parameter(Position = 2, Mandatory = $true)]
        [PSCredential]$DomainCredential,
        [Parameter(Position = 3, Mandatory = $true)]
        [PSCredential]$SafemodePassword,
        [Parameter(Position = 4)]
        [String]$NetAdapterName = 'Ethernet0',
        [array]$featureNames = @(
            'RSAT-AD-PowerShell',
            'RSAT-ADDS',
            'RSAT-AD-AdminCenter',
            'RSAT-ADDS-Tools',
            'RSAT-ADLDS'
        )
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc
    Import-DscResource -ModuleName NetworkingDsc
    Import-DscResource -ModuleName ComputerManagementDsc

    #* -------------------------------------------------------------------------------- ADDITIONAL DCS ONLY
    Node $AllNodes.Where{ $_.Role -eq 'MemberDomainController' }.NodeName  {

        # * LOCALE and TIME
        SystemLocale SystemLocaleExample
        {
            IsSingleInstance = 'Yes'
            SystemLocale     = $Node.Locale
        }

        Timezone TimeZoneConfiguration {
            TimeZone            = $NODE.TimeZone
            IsSingleInstance    = 'Yes'
        }

        $ntpServerValue1 = [string]($NODE.NTPServer | ForEach-Object { $_, (',0x{0:x}' -f '8') }) -replace ' ,',","
        $ntpServerValue2 = [string]($NODE.FailOverNTPServers | %{$_, (",0x{0:x}" -f "a")}) -replace " ,",","
        $ntpServerValue = $ntpServerValue1, $ntpServerValue2 -join " "

        $ntpservers = @()
        $ntpservers += $NODE.NTPServer
        $ntpservers += $NODE.FailOverNTPServers | %{$_}

        $timeRootPath = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\W32Time"
        $NTPListPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DateTime\Servers"

        Service w32time
        {
            Name = "W32Time"
            State = "Running"
            StartupType = "Automatic"
        }

        Registry NTPType
        {
            Key = "$timeRootPath\Parameters"
            ValueName = "Type"
            ValueType = "String"
            ValueData = "NTP"
            Ensure = "Present"
        }

        Registry NTPServer
        {
            Key = "$timeRootPath\Parameters"
            ValueName = "NTPServer"
            ValueType = "String"
            ValueData = $ntpServerValue
            Ensure = "Present"
        }

        # * NETWORKING
        NetAdapterName InterfaceRename
        {
            NewName = $NetAdapterName
        }

        IPAddress StaticIP
        {
            InterfaceAlias = $NetAdapterName
            AddressFamily  = 'IPv4'
            IPAddress      = $NODE.IPv4Address
            DependsOn      = '[NetAdapterName]InterfaceRename'
        }

        DnsServerAddress SetDnsServer
        {
            InterfaceAlias = $NetAdapterName
            AddressFamily  = 'IPv4'
            Address        = $NODE.DNSServers
            DependsOn      = '[NetAdapterName]InterfaceRename'
        }

        FirewallProfile DomainFirewallOff
        {
            Name    = 'Domain'
            Enabled = 'False'
        }

        FirewallProfile PublicFirewallOff
        {
            Name    = 'Public'
            Enabled = 'False'
        }

        FirewallProfile PrivateFirewallOff
        {
            Name    = 'Private'
            Enabled = 'False'
        }

        # * INSTALL FEATURES
        WindowsFeature ADDSFeatureInstall
        {
            Ensure    = 'Present'
            Name      = 'AD-Domain-Services'
            DependsOn = '[NetAdapterName]InterfaceRename'
        }

        ## additional Windows Features [non-essential but good to have!]
        foreach ($featureName in $featureNames)
        {
            WindowsFeature $featureName
            {
                Ensure    = 'Present'
                Name      = $featureName
                DependsOn = '[WindowsFeature]ADDSFeatureInstall'
            }
        }

        # * JOIN DOMAIN AND PROMOTE TO DC
        WaitForADDomain 'WaitForDomainInstall'
        {
            DomainName   = $NODE.DomainName
            Credential   = $DomainCredential
            RestartCount = 2
            DependsOn    = '[DnsServerAddress]SetDnsServer', '[WindowsFeature]ADDSFeatureInstall'
        }

        ADDomainController 'DomainControllerMinimal'
        {
            DomainName                    = $NODE.DomainName
            Credential                    = $DomainCredential
            SafeModeAdministratorPassword = $SafeModePassword
            DatabasePath                  = $NODE.NTDSPath
            LogPath                       = $NODE.LogPath
            SysvolPath                    = $NODE.SysvolPath
            IsGlobalCatalog               = $NODE.IsGlobalCatalog
            DependsOn                     = '[WaitForADDomain]WaitForDomainInstall'
        }

        # *LCM CONFIGURATION
        LocalConfigurationManager
        {
            CertificateId      = $NODE.Thumbprint
            RebootNodeIfNeeded = $true
        }

    }

}