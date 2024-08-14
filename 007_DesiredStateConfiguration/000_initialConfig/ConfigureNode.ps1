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

    #Everytime you update the list of DSC resources to reflect the configuration changes
    #you have to update it as well in the $modules varialble inside the initialConfigDsc.ps1 file

    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 9.1.0
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 9.0.0
    Import-DscResource -ModuleName StorageDsc -ModuleVersion 6.0.1

    Import-DscResource -ModuleName PSDscResources -ModuleVersion 2.12.0.0

    #Node $AllNodes.NodeName {
    #Node $AllNodes.Where({ $_.Role -eq 'newVM' }).NodeName
    Node $AllNodes.NodeName {
        #switch ($Node.Role) {
        #    'newVM' {
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
                    DependsOn      = '[NetAdapterBinding]DisableIPv6'
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
#            }
#        }
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

    # Every time the list of DSC resources used in current configuration is modified, due to the configuration changes
    # $modules variable varialble inside the initialConfigDsc.ps1, should be updated as well
    # those two should go hand in hand
    
    # https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc.ps1

    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 9.1.0
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 9.0.0
    Import-DscResource -ModuleName StorageDsc -ModuleVersion 6.0.1

    Import-DscResource -ModuleName PSDscResources -ModuleVersion 2.12.0.0

    Node $AllNodes.NodeName {
    #Node $AllNodes.Where({ $_.Role -eq 'newVM' }).NodeName
        switch($Node.Role) {
            'DHCPServer' {
                Write-Output 'DHCP Server Configuration'
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

                NetIPInterface IPv4DisableDhcp
                {
                    AddressFamily  = 'IPv4'
                    InterfaceAlias = $Node.InterfaceAlias
                    Dhcp           = 'Disabled'
                    DependsOn      = '[NetAdapterName]InterfaceRename'
                }

                IPAddress SetStaticIPv4Address {
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
                    Address        = $Node.DomainDnsServers
                    InterfaceAlias = $Node.InterfaceAlias
                    DependsOn      = '[NetAdapterBinding]DisableIPv6'
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
                #endregion
            }

            'CertificationServices' {
                Write-Output 'ADCS Configuration'
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

                NetIPInterface IPv4DisableDhcp
                {
                    AddressFamily  = 'IPv4'
                    InterfaceAlias = $Node.InterfaceAlias
                    Dhcp           = 'Disabled'
                    DependsOn      = '[NetAdapterName]InterfaceRename'
                }

                IPAddress SetStaticIPv4Address {
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
                    Address        = $Node.DomainDnsServers
                    InterfaceAlias = $Node.InterfaceAlias
                    DependsOn      = '[NetAdapterBinding]DisableIPv6'
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
                #endregion
            }

            'IscsiServer' {
                Write-Output 'Iscsi Server Configuration'
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

                NetIPInterface IPv4DisableDhcp
                {
                    AddressFamily  = 'IPv4'
                    InterfaceAlias = $Node.InterfaceAlias
                    Dhcp           = 'Disabled'
                    DependsOn      = '[NetAdapterName]InterfaceRename'
                }

                IPAddress SetStaticIPv4Address {
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
                    Address        = $Node.DomainDnsServers
                    InterfaceAlias = $Node.InterfaceAlias
                    DependsOn      = '[NetAdapterBinding]DisableIPv6'
                }
                #endregion

                #region storage
                WaitforDisk QuorumDrive
                {
                    DiskId           = $Node.QuorumDriveQDiskId
                    RetryIntervalSec = 60
                    RetryCount       = 10
                }

                # Q - quorum drive
                Disk VolumeQuorum
                {
                    DiskId      = $Node.QuorumDriveQDiskId
                    DriveLetter = $Node.QuorumDriveQLetter
                    
                    FSFormat    = $Node.QuorumDriveQFSFormat
                    FSLabel     = $Node.QuorumDriveQFSLabel
                    PartitionStyle = $Node.QuorumDriveQPartitionStyle
                    DependsOn   = '[WaitForDisk]QuorumDrive'
                }

                # Z - vhdx drive
                WaitforDisk VhdxDrive
                {
                    DiskId           = $Node.VhdxDriveZDiskId
                    RetryIntervalSec = 60
                    RetryCount       = 10
                }

                Disk VolumeVhdx
                {
                    DiskId      = $Node.VhdxDriveZDiskId
                    DriveLetter = $Node.VhdxDriveZLetter
                    
                    FSFormat    = $Node.VhdxDriveZFSFormat
                    FSLabel     = $Node.VhdxDriveZFSLabel
                    PartitionStyle = $Node.VhdxDriveZPartitionStyle
                    DependsOn   = '[WaitForDisk]VhdxDrive'
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
                #endregion
            }

            'FileServer' {
                Write-Output 'File Server Configuration'
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

                NetIPInterface IPv4DisableDhcp
                {
                    AddressFamily  = 'IPv4'
                    InterfaceAlias = $Node.InterfaceAlias
                    Dhcp           = 'Disabled'
                    DependsOn      = '[NetAdapterName]InterfaceRename'
                }

                IPAddress SetStaticIPv4Address {
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
                    Address        = $Node.DomainDnsServers
                    InterfaceAlias = $Node.InterfaceAlias
                    DependsOn      = '[NetAdapterBinding]DisableIPv6'
                }
                #endregion

                #region storage
                WaitforDisk DataDriveProfile
                {
                    DiskId           = $Node.DataDrivePDiskId
                    RetryIntervalSec = 60
                    RetryCount       = 10
                }

                Disk VolumeProfile
                {
                    DiskId      = $Node.DataDrivePDiskId
                    DriveLetter = $Node.DataDrivePLetter
                    
                    FSFormat    = $Node.DataDrivePFSFormat
                    FSLabel     = $Node.DataDrivePFSLabel
                    PartitionStyle = $Node.DataDrivePPartitionStyle
                    DependsOn   = '[WaitforDisk]DataDriveProfile'
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
                #endregion
            }

            'SQLServer' {
                Write-Output 'SQL Server Configuration'
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

                NetIPInterface IPv4DisableDhcp
                {
                    AddressFamily  = 'IPv4'
                    InterfaceAlias = $Node.InterfaceAlias
                    Dhcp           = 'Disabled'
                    DependsOn      = '[NetAdapterName]InterfaceRename'
                }

                IPAddress SetStaticIPv4Address {
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
                    Address        = $Node.DomainDnsServers
                    InterfaceAlias = $Node.InterfaceAlias
                    DependsOn      = '[NetAdapterBinding]DisableIPv6'
                }
                #endregion

                #region storage
                WaitforDisk DataDriveSqlDb
                {
                    DiskId           = $Node.DataDriveSDiskId
                    RetryIntervalSec = 60
                    RetryCount       = 10
                }

                Disk VolumeProfile
                {
                    DiskId      = $Node.DataDriveSDiskId
                    DriveLetter = $Node.DataDriveSLetter
                    DependsOn   = '[WaitforDisk]DataDriveSqlDb'
                    FSFormat    = $Node.DataDriveSFSFormat
                    FSLabel     = $Node.DataDriveSFSLabel
                    PartitionStyle = $Node.DataDriveSPartitionStyle
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
                                    
                #region - domain join
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
                #endregion
            }

            default {
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

                NetIPInterface IPv4DisableDhcp {
                    AddressFamily  = 'IPv4'
                    InterfaceAlias = $Node.InterfaceAlias
                    Dhcp           = 'Disabled'
                    DependsOn      = '[NetAdapterName]InterfaceRename'
                }

                IPAddress SetStaticIPv4Address {
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
                    Address        = $Node.DomainDnsServers
                    InterfaceAlias = $Node.InterfaceAlias
                    DependsOn      = '[NetAdapterBinding]DisableIPv6'
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