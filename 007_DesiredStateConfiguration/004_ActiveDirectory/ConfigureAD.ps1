# Install and configure Highly Available Domain Controllers in a new forest.
Configuration ConfigureAD
{
    param
    (
        [Parameter(Position = 0, Mandatory = $true)] 
        [pscredential]$AdministratorCred,

        [Parameter(Position = 1, Mandatory = $true)] 
        [pscredential]$DomainAdministratorCred,

        [Parameter(Position = 2, Mandatory = $true)] 
        [pscredential]$SafemodeAdministratorCred,

        [Parameter(Position =3, Mandatory = $true)] 
        [pscredential]$ADUserCred,

        [array]$featureName = @(
            'RSAT-AD-PowerShell',
            'RSAT-ADDS',
            'RSAT-ADDS-Tools',
            'RSAT-ADLDS'
        )
    )

    # Import DSC Resources
    Import-DscResource -ModuleName 'ActiveDirectoryDSC' -ModuleVersion 6.4.0
    Import-DscResource -ModuleName 'ComputerManagementDsc' -ModuleVersion 9.1.0
    Import-DscResource -ModuleName 'NetworkingDsc' -ModuleVersion 9.0.0
    
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration' -ModuleVersion 1.1
    #Import-DscResource -ModuleName 'PSDscResources' -ModuleVersion 2.12.0.0

    Node $AllNodes.Where{$_.Role -eq 'PrimaryDomainController'}.Nodename
    {
        # Configure LCM to allow Windows to automatically reboot if needed. Note: NOT recommended for production!
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyAndMonitor'
            # Set this to $true to automatically reboot the node after a configuration that requires reboot is applied. Otherwise, you will have to manually reboot the node for any configuration that requires it. The default (recommended for PRODUCTION servers) value is $false.
            RebootNodeIfNeeded = $true
            RefreshMode = 'Push'
            # The thumbprint of a certificate used to secure credentials passed in a configuration.
            CertificateId = $node.Thumbprint
            
        }

        FirewallProfile DomainFirewall
        {
            Name    = 'Domain'
            Enabled = 'False'
        }

        FirewallProfile PublicFirewall
        {
            Name    = 'Public'
            Enabled = 'True'
        }

        FirewallProfile PrivateFirewall
        {
            Name    = 'Private'
            Enabled = 'False'
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
        }

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

        NetBios DisableNetBios
        {
            InterfaceAlias = $Node.InterfaceAlias
            Setting        = 'Disable'
            DependsOn      = '[NetAdapterName]InterfaceRename'
        }

        IPAddress IPv4StaticAddress {
            AddressFamily       = 'IPv4'
            InterfaceAlias      = $Node.InterfaceAlias
            IPAddress           = $Node.IPV4Address
            #KeepExistingAddress = $true
            DependsOn           = '[NetAdapterName]InterfaceRename'
        }

        DefaultGatewayAddress IPv4DefaultGateway {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $Node.InterfaceAlias
            Address        = $Node.DefaultGatewayAddress
            DependsOn      = '[NetAdapterName]InterfaceRename'
        }

        DnsServerAddress IPv4DnsSettings {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $Node.InterfaceAlias
            Address        = $Node.DNSServers
            #Address       = '10.2.134.201'
            DependsOn      = '[NetAdapterName]InterfaceRename'
        }

        # Rename the computer
        Computer RenameComputer {
            Name       = $node.ComputerName
            DependsOn  = '[DnsServerAddress]IPv4DnsSettings'
        }

        # Reboot after renaming
        PendingReboot RebootAfterRename {
            Name                        = 'RebootAfterRename'
            SkipWindowsUpdate           = $true
            SkipComponentBasedServicing = $true
            DependsOn                   = '[Computer]RenameComputer'
        }

        # Install Windows Feature [Active Directory Domain Services].
        #WindowsFeature DNSInstall
        #{
        #    Ensure = 'Present'
        #    Name   = 'DNS'
        #    DependsOn = '[PendingReboot]RebootAfterRename'
        #}

        # Install Windows Feature [Active Directory Domain Services].
        WindowsFeature ADDSFeatureInstall
        {
            Ensure    = 'Present'
            Name      = 'AD-Domain-Services'
            DependsOn = '[PendingReboot]RebootAfterRename'
        }

        foreach ($feature in $featureName){
            WindowsFeature $feature
            {
                Ensure = 'Present'
                Name = $feature
                DependsOn = '[WindowsFeature]ADDSFeatureInstall'
            }
        }
        
        ADDomain DomainSetup
        {
            DomainName                    = $Node.DomainName
            DomainNetbiosName             = $Node.DomainNetbiosName
            ForestMode                    = $Node.ForestMode
            DomainMode                    = $Node.DomainMode
            Credential                    = $AdministratorCred
            SafemodeAdministratorPassword = $SafemodeAdministratorCred
            DatabasePath                  = $Node.DatabasePath
            LogPath                       = $Node.LogPath
            SysvolPath                    = $Node.SysvolPath
            DependsOn                     = '[WindowsFeature]ADDSFeatureInstall'
        }

        WaitForADDomain WaitForDomainInstall
        {
            DomainName             = $Node.DomainName
            Credential             = $DomainAdministratorCred
            RestartCount           = 2
            SiteName               = $Node.SiteName
            # RebootRetryCount     = 2
            # RetryCount           = 10
            # RetryIntervalSec     = 60
            DependsOn              = '[ADDomain]DomainSetup'
        }

        # Enable Recycle Bin.
        ADOptionalFeature RecycleBin
        {
            FeatureName                       = 'Recycle Bin Feature'
            # Credential with Enterprise Administrator rights to the forest.
            EnterpriseAdministratorCredential = $DomainAdministratorCred
            # Fully qualified domain name of forest to enable Active Directory Recycle Bin.
            ForestFQDN                        = $Node.DomainName
            DependsOn                         = '[ADDomain]DomainSetup', '[WindowsFeature]ADDSFeatureInstall'
        }

        # Create AD User "Test.User".
        ADUser TestUser
        {
            DomainName  = $Node.DomainName
            Credential  = $DomainAdministratorCred
            UserName    = 'Test.User'
            Password    = $ADUserCred
            Ensure      = 'Present'
            DependsOn   = '[WaitForADDomain]WaitForDomainInstall'
        }
    }

    Node $AllNodes.Where{$_.Role -eq 'SubsequentDomainController'}.Nodename
    {

        # Configure LCM to allow Windows to automatically reboot if needed. Note: NOT recommended for production!
        LocalConfigurationManager
        {
            ConfigurationMode = 'ApplyAndMonitor'
            # Set this to $true to automatically reboot the node after a configuration that requires reboot is applied. Otherwise, you will have to manually reboot the node for any configuration that requires it. The default (recommended for PRODUCTION servers) value is $false.
            RebootNodeIfNeeded = $true
            RefreshMode = 'Push'
            # The thumbprint of a certificate used to secure credentials passed in a configuration.
            CertificateId = $node.Thumbprint
            
        }
        
        FirewallProfile DomainFirewall
        {
            Name    = 'Domain'
            Enabled = 'False'
        }

        FirewallProfile PublicFirewall
        {
            Name    = 'Public'
            Enabled = 'True'
        }

        FirewallProfile PrivateFirewall
        {
            Name    = 'Private'
            Enabled = 'False'
        }

        Firewall 'AllowWinRMHTTPin' {
            Name          = 'Allow-WinRM-HTTP-In'
            DisplayName   = 'Windows Remote Management (HTTP-In)'
            Direction     = 'Inbound'
            Action        = 'Allow'
            Enabled       = 'True'
            Protocol      = 'TCP'
            LocalPort     = '5985'
            RemoteAddress = $Node.ManagementNodeIPv4Address
            Profile       = ('Domain', 'Private')
            Ensure        = 'Present'
        }

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

        NetBios DisableNetBios
        {
            InterfaceAlias = $Node.InterfaceAlias
            Setting        = 'Disable'
            DependsOn      = '[NetAdapterName]InterfaceRename'
        }

        IPAddress IPv4Address {
            AddressFamily       = 'IPv4'
            InterfaceAlias      = $Node.InterfaceAlias
            IPAddress           = $Node.IPV4Address
            KeepExistingAddress = $true
            DependsOn           = '[NetAdapterBinding]DisableIPv6'
        }

        DefaultGatewayAddress IPv4DefaultGateway {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $Node.InterfaceAlias
            Address        = $Node.DefaultGatewayAddress
            DependsOn      = '[NetAdapterBinding]DisableIPv6'
        }

        DnsServerAddress IPv4DnsSettings {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $Node.InterfaceAlias
            Address        = $Node.DNSServers
            DependsOn      = '[NetAdapterBinding]DisableIPv6'
        }

        DnsConnectionSuffix SetDnsSuffix {
            InterfaceAlias           = $Node.InterfaceAlias
            ConnectionSpecificSuffix = 'lab.local'
            Ensure                   = 'Present'
            
            UseSuffixWhenRegistering = $true
            #RegisterThisConnectionsAddress = $true
            DependsOn = '[NetAdapterBinding]DisableIPv6'
        }
        
        # Rename Computer using ComputerManagementDsc
        Computer RenameComputer {
            Name       = $node.ComputerName
            DependsOn  = '[DnsServerAddress]IPv4DnsSettings'
        }

        # Reboot after renaming
        # PendingReboot using ComputerManagementDsc
        PendingReboot RebootAfterRename {
            Name                        = $Node.ComputerName
            SkipWindowsUpdate           = $true
            SkipComponentBasedServicing = $true
            DependsOn                   = '[Computer]RenameComputer'
        }

        # Install Windows Feature AD Domain Services.
        WindowsFeature ADDSInstall
        {
            Ensure    = 'Present'
            Name      = 'AD-Domain-Services'
            DependsOn = '[PendingReboot]RebootAfterRename'
        }

        foreach ($feature in $featureName){
            WindowsFeature $feature
            {
                Ensure = 'Present'
                Name = $feature
                DependsOn = '[WindowsFeature]ADDSInstall'
            }
        }

        # Ensure that the Active Directory Domain Services feature is installed.
        WaitForADDomain WaitForDomainInstall
        {
            DomainName  = $Node.DomainName
            Credential  = $DomainAdministratorCred
            RestartCount = 2
            #WaitTimeout = $Node.WaitTimeout
            DependsOn   = '[DnsServerAddress]IPv4DnsSettings','[WindowsFeature]ADDSInstall'
        }

        # Ensure that the AD Domain is present before the second domain controller is added.

#        ADDomain SecondDC
#        {
#            DomainName                    = $Node.DomainName
#            DomainNetbiosName             = $Node.DomainNetbiosName
#            ForestMode                    = $Node.ForestMode
#            DomainMode                    = $Node.DomainMode
#            Credential                    = $DomainAdministratorCred
#            SafemodeAdministratorPassword = $SafemodeAdministratorCred
#            DatabasePath                  = $Node.DatabasePath
#            LogPath                       = $Node.LogPath
#            SysvolPath                    = $Node.SysvolPath
#            DependsOn                     = '[WaitForADDomain]WaitForDomainInstall'
#        }

        ADDomainController SecondDCController
        {
            DomainName                    = $Node.DomainName
            Credential                    = $DomainAdministratorCred
            SafemodeAdministratorPassword = $SafemodeAdministratorCred
            InstallDns                    = $true
            DatabasePath                  = $Node.DatabasePath
            LogPath                       = $Node.LogPath
            SysvolPath                    = $Node.SysvolPath
            #SiteName                      = 'Lab-Site'
            IsGlobalCatalog               = $Node.IsGlobalCatalog
                        
            #PsDscRunAsCredential can only be used for the composite resource
            #PsDscRunAsCredential          = $DomainAdministratorCred
            DependsOn                     = '[WaitForADDomain]WaitForDomainInstall'
            #DependsOn                     = "[ADDomain]SecondDC"
        }

    }    
}