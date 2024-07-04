Configuration NodeInitialConfigWorkgroup {
    param (
        [Parameter(Mandatory = $true)]
        [pscredential]$NodeName,        
    
        [Parameter(Mandatory = $true)]
        [pscredential]$AdminCredential
    )
    
    Import-DscResource -ModuleName 'ComputerManagementDsc' -ModuleVersion 9.1.0
    Import-DscResource -ModuleName 'NetworkingDsc' -ModuleVersion 9.0.0

    Import-DscResource -ModuleName 'PSDscResources' -ModuleVersion 2.12.0.0

    Node $AllNodes.NodeName {
        #LocalConfigurationManager {
        #    RebootNodeIfNeeded = $true
        #    ConfigurationMode = 'ApplyAndAutoCorrect'
        #    RefreshMode = 'Push'
        #    AllowModuleOverWrite = $true
        #}

        NetAdapterBinding DisableIPv6
        {
            InterfaceAlias = $Node.InterfaceAlias
            ComponentId    = 'ms_tcpip6'
            State          = 'Disabled'
        }

        # Set DNS Client Server Address using NetworkingDsc
        DnsServerAddress DnsSettings {
            
            AddressFamily  = 'IPv4'
            Address        = $Node.DNSServers
            InterfaceAlias = $Node.InterfaceAlias
            DependsOn      = "[NetAdapterBinding]DisableIPv6"
        }

        Service WinRm {
            Name        = 'WinRM'
            StartupType = 'Automatic'
            State       = 'Running'
        }

        Script SetTrustedHosts {
            GetScript = {
                @{
                    Result = (Get-Item -Path WSMan:\localhost\Client\TrustedHosts).Value
                }
            }
            SetScript = {
                Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value $using:Node.TrustedHosts -Force
            }
            TestScript = {
                $currentTrustedHosts = (Get-Item -Path WSMan:\localhost\Client\TrustedHosts).Value
                $currentTrustedHosts -eq $using:Node.TrustedHosts
            }
            DependsOn = '[Service]WinRm'
        }

        # Rename Computer using ComputerManagementDsc
        Computer RenameComputer {
            Name       = $NodeName
            Credential = $AdminCredential
            DependsOn = '[Script]SetTrustedHosts'
        }
        
        # PendingReboot using ComputerManagementDsc
        PendingReboot RebootAfterRename {
            Name      = 'RebootAfterRename'
            DependsOn = '[Computer]RenameComputer'
        }

        # Set Trusted Hosts
        #WindowsFeature InstallWSMan {
        #    Name = "Windows-RemoteManagement-Service"
        #    Ensure = "Present"
        #}

        #WindowsFeature InstallPSRemoting {
        #    Name = "WindowsPowerShell"
        #    Ensure = "Present"
        #    #DependsOn = "[WindowsFeature]InstallWSMan"
        #}

        #WindowsFeature ConfigureTrustedHosts {
        #    Name = "WindowsRemoteManagement"
        #    Ensure = "Present"
        #    #DependsOn = "[WindowsFeature]InstallPSRemoting"
        #}
    }
}