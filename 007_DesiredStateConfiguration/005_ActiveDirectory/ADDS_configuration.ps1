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
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion '9.1.0'
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion '9.0.0'

    #* -------------------------------------------------------------------------------- FIRST DC ONLY
    Node $AllNodes.Where{ $_.Role -eq 'RootDomainController' }.NodeName  {

        # * LCM CONFIGURATION

        LocalConfigurationManager
        {
            ActionAfterReboot  = 'ContinueConfiguration'
            CertificateID      = $Node.Thumbprint
            ConfigurationMode  = 'ApplyAndMonitor'
            RebootNodeIfNeeded = $true
            RefreshMode        = 'Push'
        }

        #region - LOCALE and TIME
        SystemLocale SystemLocaleExample
        {
            IsSingleInstance = 'Yes'
            SystemLocale     = $Node.Locale
        }

        Timezone TimeZoneConfiguration {
            TimeZone            = $Node.TimeZone
            IsSingleInstance    = 'Yes'
        }

        $ntpServerValue1 = [string]($Node.NTPServer | ForEach-Object { $_, (',0x{0:x}' -f '8') }) -replace ' ,',","
        $ntpServerValue2 = [string]($Node.FailOverNTPServers | %{$_, (",0x{0:x}" -f "a")}) -replace " ,",","
        $ntpServerValue = $ntpServerValue1, $ntpServerValue2 -join " "

        $ntpservers = @()
        $ntpservers += $Node.NTPServer
        $ntpservers += $Node.FailOverNTPServers | %{$_}

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
        #endregion        

        # * RESET LOCAL ADMIN PASSWORD
        # this will be used as the default domain admin's password
        User DomainAdmin
        {
            Ensure   = 'Present'
            UserName = 'Administrator'
            Password = $DomainCredential
        }

        #region - NETWORKING
        #region - NETWORKING - Network Interface
        NetAdapterName InterfaceRename
        {
            NewName = $Node.InterfaceAlias
        }

        NetAdapterBinding DisableIPv6
        {
            InterfaceAlias = $Node.InterfaceAlias
            ComponentId    = 'ms_tcpip6'
            State          = 'Disabled'
            DependsOn      = '[NetAdapterName]InterfaceRename'
        }

        #NetBios DisableNetBios
        #{
        #    InterfaceAlias = $Node.InterfaceAlias
        #    Setting        = 'Disable'
        #    DependsOn      = '[NetAdapterName]InterfaceRename'
        #}

        NetIPInterface IPv4DisableDhcp
        {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $Node.InterfaceAlias
            Dhcp           = 'Disabled'
            DependsOn      = '[NetAdapterName]InterfaceRename'
        }

        IPAddress SetStaticIPv4Address
        {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $Node.InterfaceAlias
            IPAddress      = $Node.IPv4Address
            DependsOn      = '[NetIPInterface]IPv4DisableDhcp'
        }

        DefaultGatewayAddress SetIPv4DefaultGateway {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $Node.InterfaceAlias
            Address        = $Node.DefaultGatewayAddress
            DependsOn      = '[IPAddress]SetStaticIPv4Address'
        }

        DnsServerAddress SetIPv4DnsServer
        {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $Node.InterfaceAlias
            Address        = $Node.DNSServers
            DependsOn      = '[IPAddress]SetStaticIPv4Address','[DefaultGatewayAddress]SetIPv4DefaultGateway'
        }
        #endregion

        #region - NETWORKING - Firewall
        FirewallProfile DomainFirewall
        {
            Name    = 'Domain'
            Enabled = 'True'
        }

        FirewallProfile PublicFirewall
        {
            Name    = 'Public'
            Enabled = 'True'
        }

        FirewallProfile PrivateFirewall
        {
            Name    = 'Private'
            Enabled = 'True'
        }

        Firewall AllowWinRMHTTPin {
            Name          = 'Allow-WinRM-HTTP-In'
            DisplayName   = 'Windows Remote Management (HTTP-In)'
            Direction     = 'Inbound'
            Action        = 'Allow'
            Enabled       = 'True'
            Protocol      = 'TCP'
            LocalPort     = '5985'
            # ammend it by the parameter - for some reason it does not work this time that's why statically assigned
            #RemoteAddress = '10.2.134.239'
            RemoteAddress = $Node.ManagementNodeIPv4Address
            Ensure        = 'Present'
            Profile       = ('Domain', 'Private')
            #Profile       = ('Domain', 'Private', 'Public')
            DependsOn = '[FirewallProfile]DomainFirewall','[FirewallProfile]PrivateFirewall'
        }
        #endregion
        #endregion

        #region - Domain Setup
        #region - Domain Setup - INSTALL FEATURES
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

        $DomainContainer = "DC=$($Node.DomainName.Split('.') -join ',DC=')"

        ADDomain 'ThisDomain'
        {
            DomainName                    = $Node.DomainName
            DomainNetbiosName             = $Node.DomainNetbiosName
            ForestMode                    = $ForestMode
            DomainMode                    = $DomainMode
            Credential                    = $DomainCredential
            SafemodeAdministratorPassword = $SafemodePassword
            DatabasePath                  = $Node.NTDSPath
            LogPath                       = $Node.LogPath
            SysvolPath                    = $Node.SysvolPath
            DependsOn                     = '[WindowsFeature]ADDSFeatureInstall'
        }

        WaitForADDomain 'WaitForDomainInstall'
        {
            DomainName   = $Node.DomainName
            Credential   = $DomainCredential
            RestartCount = 2
            # RebootRetryCount     = 2
            # RetryCount           = 10
            # RetryIntervalSec     = 60
            DependsOn    = '[ADDomain]ThisDomain'
        }
        #endregion
        #endregion

        #region - Domain Setup - OPTIONAL - STARTER ORGANIZATIONAL UNITS
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
        #endregion

        #region - Domain Customizations
        #region - Domain Customizations - PASSWORD POLICY
        ADDomainDefaultPasswordPolicy 'DefaultPasswordPolicy'
        {
            DomainName        = $Node.DomainName
            ComplexityEnabled = $Node.ComplexityEnabled
            MinPasswordLength = $Node.MinPasswordLength
            DependsOn         = '[ADDomain]ThisDomain', '[WindowsFeature]ADDSFeatureInstall'
        }
        #endregion

        #region - Domain Customizations - ENABLE RECYCLEBIN
        ADOptionalFeature RecycleBin
        {
            FeatureName                       = 'Recycle Bin Feature'
            EnterpriseAdministratorCredential = $DomainCredential
            ForestFQDN                        = $Node.DomainName
            DependsOn                         = '[ADDomain]ThisDomain', '[WindowsFeature]ADDSFeatureInstall'
        }
        #endregion

        #region - Domain Customizations - SITES AND SUBNETS
        ADReplicationSite 'FirstSite'
        {
            Ensure                     = 'Present'
            Name                       = $Node.FirstSite
            RenameDefaultFirstSiteName = $true
            DependsOn                  = '[ADDomain]ThisDomain', '[WindowsFeature]ADDSFeatureInstall'
        }
        #endregion
        #endregion
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
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion '9.1.0'
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion '9.0.0'

    # * Additional Domain Controler Configuration
    Node $AllNodes.Where{ $_.Role -eq 'MemberDomainController' }.NodeName  {

        # * LCM CONFIGURATION

        LocalConfigurationManager
        {
            ActionAfterReboot  = 'ContinueConfiguration'
            CertificateID      = $Node.Thumbprint
            ConfigurationMode  = 'ApplyAndMonitor'
            RebootNodeIfNeeded = $true
            RefreshMode        = 'Push'
        }

        # * LOCALE and TIME
        SystemLocale SystemLocaleExample
        {
            IsSingleInstance = 'Yes'
            SystemLocale     = $Node.Locale
        }

        Timezone TimeZoneConfiguration {
            TimeZone            = $Node.TimeZone
            IsSingleInstance    = 'Yes'
        }

        $ntpServerValue1 = [string]($Node.NTPServer | ForEach-Object { $_, (',0x{0:x}' -f '8') }) -replace ' ,',","
        $ntpServerValue2 = [string]($Node.FailOverNTPServers | %{$_, (",0x{0:x}" -f "a")}) -replace " ,",","
        $ntpServerValue = $ntpServerValue1, $ntpServerValue2 -join " "

        $ntpservers = @()
        $ntpservers += $Node.NTPServer
        $ntpservers += $Node.FailOverNTPServers | %{$_}

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
            NewName = $Node.InterfaceAlias
        }

        NetIPInterface IPv4DisableDhcp
        {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $Node.InterfaceAlias
            Dhcp           = 'Disabled'
            DependsOn      = '[NetAdapterName]InterfaceRename'
        }

        IPAddress SetStaticIPv4Address
        {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $Node.InterfaceAlias
            IPAddress      = $Node.IPv4Address
            DependsOn      = '[NetIPInterface]IPv4DisableDhcp'
        }

        DefaultGatewayAddress SetIPv4DefaultGateway {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $Node.InterfaceAlias
            Address        = $Node.DefaultGatewayAddress
            DependsOn      = '[IPAddress]SetStaticIPv4Address'
        }

        DnsServerAddress SetIPv4DnsServer
        {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $Node.InterfaceAlias
            Address        = $Node.DNSServers
            DependsOn      = '[IPAddress]SetStaticIPv4Address','[DefaultGatewayAddress]SetIPv4DefaultGateway'
        }

        FirewallProfile DomainFirewallOn
        {
            Name    = 'Domain'
            Enabled = 'True'
        }

        FirewallProfile PublicFirewallOn
        {
            Name    = 'Public'
            Enabled = 'True'
        }

        FirewallProfile PrivateFirewallOn
        {
            Name    = 'Private'
            Enabled = 'True'
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
            DomainName   = $Node.DomainName
            Credential   = $DomainCredential
            RestartCount = 2
            DependsOn    = '[DnsServerAddress]SetIPv4DnsServer', '[WindowsFeature]ADDSFeatureInstall'
        }

        ADDomainController 'DomainControllerMinimal'
        {
            DomainName                    = $Node.DomainName
            Credential                    = $DomainCredential
            SafeModeAdministratorPassword = $SafeModePassword
            DatabasePath                  = $Node.NTDSPath
            LogPath                       = $Node.LogPath
            SysvolPath                    = $Node.SysvolPath
            IsGlobalCatalog               = $Node.IsGlobalCatalog
            DependsOn                     = '[WaitForADDomain]WaitForDomainInstall'
        }
    }
}