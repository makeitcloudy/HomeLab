Configuration NodeInitialConfigWorkgroup {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $NewComputerName,

        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $AdminCredential
    )
    
    Import-DscResource -ModuleName 'ComputerManagementDsc' -ModuleVersion 9.1.0
    Import-DscResource -ModuleName 'NetworkingDsc' -ModuleVersion 9.0.0

    Import-DscResource -ModuleName 'PSDscResources' -ModuleVersion 2.12.0.0

    #Node $AllNodes.NodeName {
    #Node $AllNodes.Where({ $_.Role -eq 'newVM' }).NodeName
    Node $AllNodes.NodeName {
        switch ($Node.Role) {
            'newVM' {
                #LocalConfigurationManager {
                #    RebootNodeIfNeeded = $true
                #    ConfigurationMode = 'ApplyAndAutoCorrect'
                #    RefreshMode = 'Push'
                #    AllowModuleOverWrite = $true
                #}
                #region Services
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
                #endregion

                #region network interface
                NetAdapterName InterfaceRename {
                    NewName = $Node.InterfaceAlias
                }

                NetAdapterBinding DisableIPv6 {
                    InterfaceAlias = $Node.InterfaceAlias
                    ComponentId    = 'ms_tcpip6'
                    State          = 'Disabled'
                    DependsOn      = '[NetAdapterName]InterfaceRename'
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

                # Set DNS Client Server Address using NetworkingDsc
                DnsServerAddress DnsSettings {
                    AddressFamily  = 'IPv4'
                    Address        = $Node.WorkgroupDnsServers
                    InterfaceAlias = $Node.InterfaceAlias
                    DependsOn      = "[NetAdapterBinding]DisableIPv6"
                }
                #endregion

                # Rename Computer using ComputerManagementDsc
                Computer RenameComputer {
                    Name       = $NewComputerName
                    Credential = $AdminCredential
                    DependsOn = '[Script]SetTrustedHosts'
                    WorkGroupName = $Node.WorkgroupName
                }
                
                # PendingReboot using ComputerManagementDsc
                PendingReboot RebootAfterRename {
                    Name      = 'RebootAfterRename'
                    DependsOn = '[Computer]RenameComputer'
                }
            }
        }
    }
}

Configuration NodeInitialConfigDomain {
    param (
        [Parameter(Mandatory = $true)]
        [String]$NewComputerName,        
    
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $AdminCredential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $DomainJoinCredential
    )
    
    Import-DscResource -ModuleName 'ComputerManagementDsc' -ModuleVersion 9.1.0
    Import-DscResource -ModuleName 'NetworkingDsc' -ModuleVersion 9.0.0

    Import-DscResource -ModuleName 'PSDscResources' -ModuleVersion 2.12.0.0

    Node $AllNodes.NodeName {
    #Node $AllNodes.Where({ $_.Role -eq 'newVM' }).NodeName

    switch($Node.Role) {
        'DHCPServer' {
            NetIPInterface IPv4DisableDhcp {
                AddressFamily  = 'IPv4'
                InterfaceAlias = $Node.InterfaceAlias
                Dhcp           = 'Disabled'
                DependsOn      = '[NetAdapterName]InterfaceRename'
            }

            IPAddress SetStaticIPv4AddressDHCPServer {
                AddressFamily  = 'IPv4'
                InterfaceAlias = $Node.InterfaceAlias
                IPAddress      = $Node.IPv4Address
                DependsOn      = '[NetIPInterface]IPv4DisableDhcp'
            }

            DefaultGatewayAddress SetIPv4DefaultGatewayDHCPServer {
                AddressFamily  = 'IPv4'
                InterfaceAlias = $Node.InterfaceAlias
                Address        = $Node.DefaultGatewayAddress
                DependsOn      = '[IPAddress]SetStaticIPv4AddressDHCPServer'
            }
        }

        'CertificationServices' {
            NetIPInterface IPv4DisableDhcp {
                AddressFamily  = 'IPv4'
                InterfaceAlias = $Node.InterfaceAlias
                Dhcp           = 'Disabled'
                DependsOn      = '[NetAdapterName]InterfaceRename'
            }

            IPAddress SetStaticIPv4AddressCertificationServices {
                AddressFamily  = 'IPv4'
                InterfaceAlias = $Node.InterfaceAlias
                IPAddress      = $Node.IPv4Address
                DependsOn      = '[NetIPInterface]IPv4DisableDhcp'
            }

            DefaultGatewayAddress SetIPv4DefaultGatewayCertificationServices {
                AddressFamily  = 'IPv4'
                InterfaceAlias = $Node.InterfaceAlias
                Address        = $Node.DefaultGatewayAddress
                DependsOn      = '[IPAddress]SetStaticIPv4AddressCertificationServices'
            }
        }

        'FileServer' {
            NetIPInterface IPv4DisableDhcp {
                AddressFamily  = 'IPv4'
                InterfaceAlias = $Node.InterfaceAlias
                Dhcp           = 'Disabled'
                DependsOn      = '[NetAdapterName]InterfaceRename'
            }

            IPAddress SetStaticIPv4AddressFileServer {
                AddressFamily  = 'IPv4'
                InterfaceAlias = $Node.InterfaceAlias
                IPAddress      = $Node.IPv4Address
                DependsOn      = '[NetIPInterface]IPv4DisableDhcp'
            }

            DefaultGatewayAddress SetIPv4DefaultGatewayFileServer {
                AddressFamily  = 'IPv4'
                InterfaceAlias = $Node.InterfaceAlias
                Address        = $Node.DefaultGatewayAddress
                DependsOn      = '[IPAddress]SetStaticIPv4AddressFileServer'
            }
        }

        'SQLServer' {
            NetIPInterface IPv4DisableDhcp
            {
                AddressFamily  = 'IPv4'
                InterfaceAlias = $Node.InterfaceAlias
                Dhcp           = 'Disabled'
                DependsOn      = '[NetAdapterName]InterfaceRename'
            }

            IPAddress SetStaticIPv4AddressSQLServer {
                AddressFamily  = 'IPv4'
                InterfaceAlias = $Node.InterfaceAlias
                IPAddress      = $Node.IPv4Address
                DependsOn      = '[NetIPInterface]IPv4DisableDhcp'
            }

            DefaultGatewayAddress SetIPv4DefaultGatewaySQLServer {
                AddressFamily  = 'IPv4'
                InterfaceAlias = $Node.InterfaceAlias
                Address        = $Node.DefaultGatewayAddress
                DependsOn      = '[IPAddress]SetStaticIPv4AddressSQLServer'
            }
        }

        default {
            #region - apply common settings
            NetAdapterName InterfaceRename {
                NewName = $Node.InterfaceAlias
            }
                
            NetAdapterBinding DisableIPv6 {
                InterfaceAlias = $Node.InterfaceAlias
                ComponentId    = 'ms_tcpip6'
                State          = 'Disabled'
                DependsOn      = '[NetAdapterName]InterfaceRename'
            }

            # Set DNS Client Server Address using NetworkingDsc
            DnsServerAddress DnsSettings {
                AddressFamily  = 'IPv4'
                Address        = $Node.DomainDnsServers
                InterfaceAlias = $Node.InterfaceAlias
                DependsOn      = "[NetAdapterBinding]DisableIPv6"
            }

            # Set DNS Client Server Address using NetworkingDsc
            DnsServerAddress DnsSettings {
                AddressFamily  = 'IPv4'
                Address        = $Node.DomainDnsServers
                InterfaceAlias = $Node.InterfaceAlias
                DependsOn      = "[NetAdapterBinding]DisableIPv6"
            }
            #endregion

            #region services
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
            #endregion
                        
            # Rename Computer using ComputerManagementDsc
            Computer RenameComputer {
                Name        = $NewComputerName
                DomainName  = $Node.DomainName
                Credential  = $DomainJoinCredential
                ##JoinOU      = $Node.JoinOu
                #AccountCreate | InstallInvoke | JoinReadOnly | JoinWithNewName | PasswordPass | UnsecuredJoin | Win9XUpgrade
                ##Options     = 'JoinWithNewName'
                ##Server = 'dc01.lab.local'
                #Description = ''
                #[PsDscRunAsCredential = [PSCredential]]
                DependsOn   = '[Script]SetTrustedHosts'
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
            #endregion
        }
    }
    }
}
  
Configuration SQLServer {
    $AllNodes.Where({$_.Role -eq 'SQLServer'}).ForEach{
        Node $AllNodes.NodeName {

        }
    }
}