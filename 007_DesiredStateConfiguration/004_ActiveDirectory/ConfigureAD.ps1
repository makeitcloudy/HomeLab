# Install and configure Highly Available Domain Controllers in a new forest.
Configuration ConfigureAD
{
    param
    (
        [Parameter(Mandatory)] 
        [pscredential]$SafemodeAdministratorCred, 

        [Parameter(Mandatory)] 
        [pscredential]$DomainAdministratorCred, 

        [Parameter(Mandatory)] 
        [pscredential]$ADUserCred
    )

    # Import DSC Resources
    Import-DscResource -ModuleName 'ActiveDirectoryDSC' -ModuleVersion 6.4.0
    Import-DscResource -ModuleName 'ComputerManagementDsc' -ModuleVersion 9.0.0
    Import-DscResource -ModuleName 'NetworkingDsc' -ModuleVersion 9.0.0
    
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration' -ModuleVersion 1.1
    #Import-DscResource -ModuleName 'PSDscResources' -ModuleVersion 2.12.0.0

    Node $AllNodes.Where{$_.Role -eq 'FirstDomainController'}.Nodename
    {
        # Configure LCM to allow Windows to automatically reboot if needed. Note: NOT recommended for production!
        LocalConfigurationManager
        {
            # Set this to $true to automatically reboot the node after a configuration that requires reboot is applied. Otherwise, you will have to manually reboot the node for any configuration that requires it. The default (recommended for PRODUCTION servers) value is $false.
            RebootNodeIfNeeded = $true
            # The thumbprint of a certificate used to secure credentials passed in a configuration.
            CertificateId = $node.Thumbprint
        }

        NetAdapterBinding DisableIPv6
        {
            InterfaceAlias = $Node.InterfaceAlias
            ComponentId    = 'ms_tcpip6'
            State          = 'Disabled'
        }

        DnsServerAddress DnsSettings {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $Node.InterfaceAlias
            Address        = $Node.DNSServers
            #Address       = '10.2.134.201'
            DependsOn      = '[NetAdapterBinding]DisableIPv6'
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

        # Rename the computer
        Computer RenameComputer {
            Name       = $node.NodeName
            DependsOn  = '[DnsServerAddress]DnsSettings'
        }

        # Reboot after renaming
        PendingReboot RebootAfterRename {
            Name      = 'RebootAfterRename'
            DependsOn = '[Computer]RenameComputer'
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

        # Create AD Domain specified in HADCServerConfigData.
        #ADDomain FirstDomainController {
        #    DomainName = $node.DomainName
        #
        #    DomainNetbiosName             = $Node.DomainNetbiosName
        #    DomainMode                    = $Node.DomainMode
        #    ForestMode                    = $Node.ForestMode
        #    Credential                    = $DomainAdministratorCred
        #    SafemodeAdministratorPassword = $SafemodeAdministratorCred
        #}
        
        ADDomain DomainSetup
        {
            DomainName                    = $Node.DomainName
            DomainNetbiosName             = $Node.DomainNetbiosName
            ForestMode                    = $Node.ForestMode
            DomainMode                    = $Node.DomainMode
            Credential                    = $DomainAdministratorCred
            SafemodeAdministratorPassword = $SafemodeAdministratorCred
            DatabasePath                  = $Node.DatabasePath
            LogPath                       = $Node.LogPath
            SysvolPath                    = $Node.SysvolPath
            DependsOn                     = '[WindowsFeature]ADDSFeatureInstall'
        }

        WaitForADDomain 'WaitForDomainInstall'
        {
            DomainName             = $Node.DomainName
            Credential             = $DomainAdministratorCred
            RestartCount           = 2
            # RebootRetryCount     = 2
            # RetryCount           = 10
            # RetryIntervalSec     = 60
            DependsOn    = '[ADDomain]DomainSetup'
        }

#        ADDomainController FirstDC
#        {
#            # Name of the remote domain. If no parent name is specified, this is the fully qualified domain name for the first domain in the forest.
#            DomainName                    = $Node.DomainName
#            InstallDns                    = $true
#
#            # Credentials used to query for domain existence.
#            Credential                    = $DomainAdministratorCred
#            # Password for the administrator account when the computer is started in Safe Mode.
#            SafemodeAdministratorPassword = $SafemodeAdministratorCred
#            # Specifies the fully qualified, non-Universal Naming Convention (UNC) path to a directory on a fixed disk of the local computer that contains the domain database (optional).
#            DatabasePath                  = $Node.DatabasePath
#            # Specifies the fully qualified, non-UNC path to a directory on a fixed disk of the local computer where the log file for this operation will be written (optional).
#            LogPath                       = $Node.DatabasePath
#            # Specifies the fully qualified, non-UNC path to a directory on a fixed disk of the local computer where the Sysvol file will be written. (optional)
#            SysvolPath                    = $Node.DatabasePath
#            # DependsOn specifies which resources depend on other resources, and the LCM ensures that they are applied in the correct order, regardless of the order in which resource instances are defined.
#            DependsOn                     = '[WindowsFeature]ADDSInstall'
#        }

        # Wait until AD Domain is created.
#        WaitForADDomain 'WaitForDomainInstall'
#        {
#            DomainName           = $Node.DomainName
#
#           Credential           = $DomainAdministratorCred
#            # Maximum number of retries to check for the domain's existence.
#            #RetryCount          = $Node.RetryCount
#            # Interval to check for the domain's existence.
#            WaitTimeout          = $Node.RetryIntervalSec
#            DependsOn            = '[ADDomainController]FirstDC'
#        }

        # Enable Recycle Bin.
        ADOptionalFeature RecycleBin
        {
            FeatureName                       = 'Recycle Bin Feature'
            # Credential with Enterprise Administrator rights to the forest.
            EnterpriseAdministratorCredential = $DomainAdministratorCred
            # Fully qualified domain name of forest to enable Active Directory Recycle Bin.
            ForestFQDN                        = $Node.DomainName
            DependsOn                         = '[WaitForADDomain]WaitForDomainInstall'
        }

        # Create AD User "Test.User".
        ADUser ADUser
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
		    # Set this to $true to automatically reboot the node after a configuration that requires reboot is applied. Otherwise, you will have to manually reboot the node for any configuration that requires it. The default (recommended for PRODUCTION servers) value is $false.
            RebootNodeIfNeeded = $true
		    # The thumbprint of a certificate used to secure credentials passed in a configuration.
            CertificateId      = $node.Thumbprint
        }

        NetAdapterBinding DisableIPv6
        {
            InterfaceAlias = $Node.InterfaceAlias
            ComponentId    = 'ms_tcpip6'
            State          = 'Disabled'
        }

        DnsServerAddress DnsSettings {
            AddressFamily  = 'IPv4'
            InterfaceAlias = $Node.InterfaceAlias
            Address        = $Node.DNSServers
            DependsOn      = '[NetAdapterBinding]DisableIPv6'
        }

        # Rename Computer using ComputerManagementDsc
        Computer RenameComputer {
            Name       = $node.NodeName
            DependsOn  = '[DnsServerAddress]DnsSettings'
        }

        # Reboot after renaming
        # PendingReboot using ComputerManagementDsc
        PendingReboot RebootAfterRename {
            Name                        = 'RebootAfterRename'
            SkipWindowsUpdate           = $true
            SkipComponentBasedServicing = $true
            DependsOn                   = '[Computer]RenameComputer'
        }

        # Install Windows Feature AD Domain Services.
        #WindowsFeature DNSInstall
        #{
        #    Ensure    = 'Present'
        #    Name      = 'DNS'
        #    DependsOn = '[PendingReboot]RebootAfterRename'
        #}

        # Install Windows Feature AD Domain Services.
        WindowsFeature ADDSInstall
        {
            Ensure    = 'Present'
            Name      = 'AD-Domain-Services'
            DependsOn = '[PendingReboot]RebootAfterRename'
        }

        # Ensure that the Active Directory Domain Services feature is installed.
        WaitForADDomain WaitForDomainInstall
        {
            DomainName  = $Node.DomainName
            Credential  = $DomainAdministratorCred
            #RetryCount = $Node.RetryCount
            WaitTimeout = $Node.RetryIntervalSec
            DependsOn   = '[WindowsFeature]ADDSInstall'
        }

        # Ensure that the AD Domain is present before the second domain controller is added.
        ADDomainController SecondDC
        {
            DomainName                    = $Node.DomainName
            Credential                    = $DomainAdministratorCred
            SafemodeAdministratorPassword = $SafemodeAdministratorCred
            InstallDns                    = $true
            DependsOn                     = '[WaitForADDomain]WaitForDomainInstall'
            
        }
    }
}