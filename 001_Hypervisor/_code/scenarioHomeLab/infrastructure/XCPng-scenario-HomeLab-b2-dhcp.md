## DHCP

Two DHCP servers split between Sites. At the moment there is one DHCP server in each site. Sites are split by network interfaces on the MKT and Xen.  
Each DHCP server ends up with 3 network interfaces.  
default gateway is in vlan1342 - prod - b2  
second network interfaces which serves the DHCP leases in - vlan1332  
third network interfaces which serves the DHCP leases in - vlan1352  

**TODO:** cluster the DHCP within site.

### Windows - Server OS - 2x DHCP Server - Core

File Server - cluster - 'w2k22dtc_2302_untd_nprmpt_uefi.iso'

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'b2_dhcp01' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:06' --StorageName 'node4_ssd_sdd' --VmDescription 'w2k22_DHCP_core'

/opt/scripts/vm_create_uefi.sh --VmName 'b2_dhcp02' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:07' --StorageName 'node4_ssd_sde' --VmDescription 'w2k22_DHCP_core'

```

Once the OS is installed, execute the code to mount the VMTools

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='b2_dhcp01'
xe vm-cd-insert vm='b2_dhcp01' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='b2_dhcp02'
xe vm-cd-insert vm='b2_dhcp02' cd-name='Citrix_Hypervisor_821_tools.iso'

```

Then follow up with

* [run_initialSetup.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/README.md#run_initialsetupps1) - it ask for the new name of the vm,
* once done and VM is rebooted, run the following

```powershell
$domainName = 'lab.local'  #FIXME
Set-InitialConfigDsc -NewComputerName $env:computername -Option Domain -DomainName $domainName -Verbose
```

### DHCP - Eject vmTools

```bash
xe vm-cd-eject vm='b2_dhcp01'
xe vm-cd-eject vm='b2_dhcp02'

```

Proceed with the code

```powershell
https://makeitcloudy.pl/windows-DSC/
# proceed with the code from paragraph 2.2
# the code available in that paragraph runs the Set-InitialConfigDsc function which triggers the the code 
https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc.ps1
# config data are grabbed from here
# for the domain scenario to work properly the DNS should be configured properly (DomainDnsServers)
# and goes hand in hand with the IP addresses of the domain controllers 
https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigData.psd1

Set-InitialConfigDsc -NewComputerName $env:ComputerName -Option Domain -Verbose
```

### DHCP - dhcp01 - Configure subsequent network interfaces

```bash
# the initial network interface was 0
# each subsequent network interface increases by 1
/opt/scripts/vm_add_network_interface.sh --VmName 'b2_dhcp01' --NetworkName 'prod-A2-vlan1332' --Mac '16:A2:13:32:02:06' --Device '1'
/opt/scripts/vm_add_network_interface.sh --VmName 'b2_dhcp01' --NetworkName 'prod-C2-vlan1352' --Mac '16:C2:13:52:02:06' --Device '2'
```

```powershell
$dhcp_interface_vlan1332 = @{
    Mac       = '16:A2:13:32:02:06'
    #Mac       = '16-A2-13-32-02-06'
    Name      = 'vlan1332'
    IPAddress = '10.2.133.6'
    Mask      = '24'
}

$dhcp_interface_vlan1352 = @{
    Mac       = '16:C2:13:52:02:06'
    #Mac       = '16-C2-13-52-02-06'
    Name      = 'vlan1352'
    IPAddress = '10.2.135.6'
    Mask      = '24'
}

#function Set-PLNetAdapter is part of the AutomatedLabModule
Set-PLNetAdapter @dhcp_interface_vlan1332
Set-PLNetAdapter @dhcp_interface_vlan1352
```

### DHCP - dhcp02 - Configure subsequent network interfaces

```bash
# the initial network interface was 0
# each subsequent network interface increases by 1
/opt/scripts/vm_add_network_interface.sh --VmName 'b3_dhcp02' --NetworkName 'prod-A3-vlan1333' --Mac '26:A3:13:33:02:07' --Device '1'
/opt/scripts/vm_add_network_interface.sh --VmName 'b3_dhcp02' --NetworkName 'prod-C3-vlan1353' --Mac '26:C3:13:53:02:07' --Device '2'
```

```powershell
$dhcp_interface_vlan1333 = @{
    Mac       = '26:A3:13:33:02:07'
    #Mac       = '26-A3-13-33-02-07'
    Name      = 'vlan1333'
    IPAddress = '10.3.133.7'
    Mask      = '24'
}

$dhcp_interface_vlan1353 = @{
    Mac       = '26:C3:13:53:02:07'
    #Mac       = '26-C3-13-53-02-07'
    Name      = 'vlan1353'
    IPAddress = '10.3.135.7'
    Mask      = '24'
}

#function Set-PLNetAdapter is part of the AutomatedLabModule
Set-PLNetAdapter @dhcp_interface_vlan1333
Set-PLNetAdapter @dhcp_interface_vlan1353
```

### Configure DHCP Scopes

Makes use of the MMC console.  
Alternatively craft powershell code.  

```powershell
$scope_vlan1332 = @{
    Name          = 'a2_vlan1332'
    #ScopeId       = '10.2.133.0' # The network address for the scope
    StartRange    = '10.2.133.201' # Starting IP address of the range
    EndRange      = '10.2.133.253' # Ending IP address of the range
    SubnetMask    = '255.255.255.0' # Subnet mask
    #LeaseDuration = '1.00:00:00' # Lease duration (1 days)
    LeaseDuration = '04:00:00' # Lease duration (4 hours)
}

$scope_vlan1352 = @{
    Name          = 'b2_vlan1352'
    #ScopeId       = '10.2.135.0' # The network address for the scope
    StartRange    = '10.2.135.201' # Starting IP address of the range
    EndRange      = '10.2.135.253' # Ending IP address of the range
    SubnetMask    = '255.255.255.0' # Subnet mask
    #LeaseDuration = '1.00:00:00' # Lease duration (1 days)
    LeaseDuration = '04:00:00' # Lease duration (4 hours)
}

# Create the DHCP scope
Add-DhcpServerv4Scope @scope_vlan1332
Add-DhcpServerv4Scope @scope_vlan11352


$ReservationName = "Lab - A2 - "
$IPAddress = "10.2.133.253" # The reserved IP address
$MacAddress = "26:A2:13:32:02:53" # The MAC address to be reserved
$ScopeId = "10.2.133.0" # The network address for the scope

# Add a static reservation
Add-DhcpServerv4Reservation -ScopeId $ScopeId -IPAddress $IPAddress -ClientId $MacAddress -Name $ReservationName


# Define the DHCP server and scope
$DhcpServer = "YourDhcpServerName"  # Replace with your DHCP server name
$ScopeId = "10.0.0.0"                # Replace with your DHCP scope ID

# Set the gateway and DNS servers
$Gateway = "10.0.0.1"                 # Replace with your gateway IP
$DnsServer1 = "8.8.8.8"               # Replace with your primary DNS IP
$DnsServer2 = "8.8.4.4"               # Replace with your secondary DNS IP

# Add the DHCP option for the gateway
Set-DhcpServerv4OptionValue -DnsServer $DnsServer1, $DnsServer2 -ScopeId $ScopeId -DhcpServer $DhcpServer
Set-DhcpServerv4OptionValue -Router $Gateway -ScopeId $ScopeId -DhcpServer $DhcpServer

Get-Service -Name DHCPserver | Restart-Service
# once done the red flag should dissapear from the IPv4
```

### PowerShell code

#### disable ipv6

```
Get-NetAdapterBinding -ComponentID ms_tcpip6
$interfaceName = @('Eth0','vlan1442','vlan1542')

$interfaceName.foreach({Disable-NetAdapterBinding -Name $_ -ComponentID ms_tcpip6})

```