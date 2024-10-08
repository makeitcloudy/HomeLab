# XCP-ng - HomeLab

It contains the code which creates the VM on the XCP-ng hypervisor. It has the dependencies on the following scripts, which should exist on the XCP-ng in */opt/scripts*. Details are described in the [blogpost](https://makeitcloudy.pl/windows-preparation/), which is also available [here](https://github.com/makeitcloudy/makeitcloudy.github.io/blob/master/_posts/2022-05-13-windows-preparation.md).

* [AutomatedXCP-ng](https://github.com/makeitcloudy/AutomatedXCP-ng/)
* AutomatedXCP-ng [/opt/scripts/vm_create_bios.sh](https://github.com/makeitcloudy/AutomatedXCP-ng/blob/main/bash/vm_create_bios.sh)
* AutomatedXCP-ng [/opt/scripts/vm_create_uefi.sh](https://github.com/makeitcloudy/AutomatedXCP-ng/blob/main/bash/vm_create_uefi.sh)
* AutomatedXCP-ng [/opt/scripts/vm_create_uefi_secureBoot.sh](https://github.com/makeitcloudy/AutomatedXCP-ng/blob/main/bash/vm_create_uefi_secureBoot.sh)
* AutomatedXCP-ng [/opt/scripts/vm_add_disk.sh](https://github.com/makeitcloudy/AutomatedXCP-ng/blob/main/bash/vm_add_disk.sh)

## XCP-ng - HomeLab - Networking Facts

Mac Address:

```code
# Enter an address in the form XY:XX:XX:XX:XX:XX where 
#                  X is any hexadecimal digit, and 
#                  Y is one of 2, 6, A or E.
```

## XCP-ng - HomeLab - Assumptions

It is assumed:

1. that the storage and network is configured on the XCP-ng.
2. there is Storage Repository which keeps the ISO's used for the VM installations
3. there is a DHCP server within the network, so it is possible to RDP to the VM's (Xen Orchestra used to login to the VM's via virtual console, at this stage does not offer the clipboard)
4. the ISO's are unattended - [blog post](https://makeitcloudy.pl/OSDBuilder-offline-servicing-updates/) - describing the process

## XCP-ng - HomeLab - Windows Server 2022 - ISO

Storage repository contains following ISO for the VM provisioning.

```code
'w2k22dtc_2302_untd_nprmpt_uefi.iso' - Desktop Experience
'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' - Core
```

## Management Node

Configuration Data for the Desired State Configuration (DSC) is stored in the [HomeLab](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigData.psd1) Git repository.

### Windows - Desktop OS - Initial Configuration - Management Node - w10mgmt

Node (Desktop) used to manage the environment and author DSC configurations - Starting Point

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName 'b2_w10mgmt' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 90 --TemplateName 'Windows 10 (64-bit)' --IsoName 'w10ent_21H2_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:49' --StorageName 'node4_ssd_sdg' --VmDescription 'b2_w10mgmt_MgmtNode'

# After installation eject CD
# Run on XCP-ng
# eject installation media
xe vm-cd-eject vm='b2_w10mgmt'
xe vm-cd-insert vm='b2_w10mgmt' cd-name='Citrix_Hypervisor_821_tools.iso'

## Add Disk
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName 'b2_w10mgmt' --storageName 'node4_hdd_sdc_lsi' --diskName 'b2_w10mgmt_dataDrive' --deviceId 4 --diskGB 20  --description 'b2_w10mgmt'
```

Then follow up with

```powershell
https://makeitcloudy.pl/windows-preparation/
# proceed with the code from paragraph 2.0.2
# machine won't restart
```

Proceed with the code

```powershell
https://makeitcloudy.pl/windows-DSC/
# proceed with the code from paragraph 2.2
# the code available in that paragraph runs the Set-InitialConfigDsc function which triggers the the code 
https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc.ps1

# scenario - workgroup - run first
Set-InitialConfigDsc -NewComputerName $NodeName -Option Workgroup -Verbose
# scenario - domain - when the domain is already configured
Set-InitialConfigDsc -NewComputerName $NodeName -Option Domain -Verbose

# when the VM is provisioned login via XCP-ng console unless you know the IP address
# Restart-Computer for the succesfull installation of the PV-Tools
```

## Active Directory Domain Services

### Windows - Server OS - 2x Domain Controller - Server Core

```bash
# First domain controller - server core
/opt/scripts/vm_create_uefi.sh --VmName 'b2_dc01' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:01' --StorageName 'node4_ssd_sdd' --VmDescription 'w2k22_dc01_ADDS_core'

# Second domain controller - server core
/opt/scripts/vm_create_uefi.sh --VmName 'b2_dc02' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:02' --StorageName 'node4_ssd_sde' --VmDescription 'w2k22_dc02_ADDS_core'

```

### VMTools Installation - ADDS

```bash
# it works - provided there is only one iso on SR with such name
# .iso should be available in following location: 
# /var/opt/xen/ISO_Store      - custom local iso storage created during the XCPng setup
# /opt/xensource/packages/iso - default iso storage with XCPng tools
xe vm-cd-eject vm='b2_dc01'
xe vm-cd-insert vm='b2_dc01' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='b2_dc02'
xe vm-cd-insert vm='b2_dc02' cd-name='Citrix_Hypervisor_821_tools.iso'

```

```powershell

### take the snapshot of the VM (dc01, dc02)
# then follow up with paragraph 2
https://makeitcloudy.pl/active-directory-DSC/
# run the code on DC01 from, then once finished run the code on DC02
# run the configuration on DC02 - once the DC01 is available again after the reboot
# even if the the group policy client can take up some time (5min) - it stuck on the LogonUI.exe process for the logon to the machine
# the DSC configuration on DC02 can be run in parallel and the replication takes place properly
https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory_demo.ps1
# it will execute
https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory/ADDS_setup.ps1

# at this point the code change the IP address from the DHCP pool reservation to static IP
# which is outside of the scope from the pool - the configuration is hardcoded among the configuration
# data available in the ADDS_setup.ps1 file

# the DSC configuration is available in this file, configurationData is in ADDS_setup.ps1
https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory/ADDS_configuration.ps1

# once the domain is setup run the _ad_carlWebster_structure.ps1
https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/006_CoreServices/Windows/Server/ad/_ad_carlWebster_structure.ps1
# everything apart from the Site configuration
# as of 2024.08.07 - still some users / groups needs fixes
# though this will be rewritten to the DSC configuration at some point anyway
```

## ADCS

### Windows - Server OS - 1x ADCS Root - DesktopExperience | 1x ADCS Sub - Core

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'b2_adcsR' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 40 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:03' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_adcsR_ADCS_RootCA'

/opt/scripts/vm_create_uefi.sh --VmName 'b2_adcsS' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:04' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_adcsS_ADCS_IssuingCA'

```

### Windows - Server OS - 1x Web Server - Core

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'b2_adcsWS' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:05' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_adcsR_ADCS_WebEnrollment'
```

Once the OS is installed, execute the code to mount the VMTools

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='b2_adcsWS'
xe vm-cd-insert vm='b2_adcsWS' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='b2_adcsR'
xe vm-cd-insert vm='b2_adcsR' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='b2_adcsS'
xe vm-cd-insert vm='b2_adcsS' cd-name='Citrix_Hypervisor_821_tools.iso'

```

The IP reservation on the DHCP server in the subnet are done, so get the IP address is known, otherwise login to the VM via XCP-ng console (no clipboard available) and get the IP address. Connect to the machine via RDP.
Note: Machine should have access to the internet to grab the content from github.

Then follow up with (initial configuration - VMTools installation script, which also rename the machine and reboots it)

* [run_initialSetup.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/README.md#run_initialsetupps1) - details about the code are described in the blog post [windows-preparation](https://makeitcloudy.pl/windows-preparation/) - paragraph 2.0.2


```bash
xe vm-cd-eject vm='b2_adcsWS'
xe vm-cd-eject vm='b2_adcsR'
xe vm-cd-eject vm='b2_adcsS'

```

Proceed with the code

* adcsR - is a root CA - do not add it to the domain
* adcsS - is subCA - add it to the domain
* adcsWS - is Web Enrollment - add it to the domain

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

## DHCP

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

The IP reservation on the DHCP server in the subnet are done, so get the IP address is known, otherwise login to the VM via XCP-ng console (no clipboard available) and get the IP address. Connect to the machine via RDP.
Note: Machine should have access to the internet to grab the content from github.

Then follow up with

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

### Configure subsequent network interfaces

```bash
# the initial network interface was 0
# each subsequent network interface increases by 1
/opt/scripts/vm_add_network_interface.sh --VmName 'b2_dhcp01' --NetworkName 'eth1-B2-vlan1442' --Mac '12:B2:14:42:02:06' --Device '1'
/opt/scripts/vm_add_network_interface.sh --VmName 'b2_dhcp01' --NetworkName 'eth1-B2-vlan1542' --Mac '12:B2:15:42:02:06' --Device '2'
```

```powershell
$dhcp_interface_vlan1442 = @{
    Mac       = '12:B2:14:42:02:06'
    #Mac       = '12-B2-14-42-02-06'
    Name      = 'vlan1442'
    IPAddress = '10.2.144.6'
    Mask      = '24'
}

$dhcp_interface_vlan1542 = @{
    Mac       = '12:B2:15:42:02:06'
    #Mac       = '12-B2-15-42-02-06'
    Name      = 'vlan1542'
    IPAddress = '10.2.154.6'
    Mask      = '24'
}

#function Set-PLNetAdapter is part of the AutomatedLabModule
Set-PLNetAdapter @dhcp_interface_vlan1442
Set-PLNetAdapter @dhcp_interface_vlan1542
```

### Configure DHCP Scopes

Makes use of the MMC console.  
Alternatively craft powershell code.  

```powershell
$scope_vlan1442 = @{
    Name          = 'b2_vlan1442'
    #ScopeId       = '10.2.144.0' # The network address for the scope
    StartRange    = '10.2.144.201' # Starting IP address of the range
    EndRange      = '10.2.144.253' # Ending IP address of the range
    SubnetMask    = '255.255.255.0' # Subnet mask
    #LeaseDuration = '1.00:00:00' # Lease duration (1 days)
    LeaseDuration = '04:00:00' # Lease duration (4 hours)
}

$scope_vlan1542 = @{
    Name          = 'b2_vlan1542'
    #ScopeId       = '10.2.154.0' # The network address for the scope
    StartRange    = '10.2.154.201' # Starting IP address of the range
    EndRange      = '10.2.154.253' # Ending IP address of the range
    SubnetMask    = '255.255.255.0' # Subnet mask
    #LeaseDuration = '1.00:00:00' # Lease duration (1 days)
    LeaseDuration = '04:00:00' # Lease duration (4 hours)
}

# Create the DHCP scope
Add-DhcpServerv4Scope @scope_vlan1442
Add-DhcpServerv4Scope @scope_vlan1542


$ReservationName = "Lab - B2 - "
$IPAddress = "10.2.144.253" # The reserved IP address
$MacAddress = "12:B2:14:42:02:53" # The MAC address to be reserved
$ScopeId = "10.2.144.0" # The network address for the scope

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

###

## File Services

### Windows - Server OS - 1x File Server - iSCSI target - Core

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'b2_iscsi' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:13' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_iscsi_Filer'

```

Once the OS is installed, execute the code to mount the VMTools

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='b2_iscsi'
xe vm-cd-insert vm='b2_iscsi' cd-name='Citrix_Hypervisor_821_tools.iso'

```

Windows Server (regardsless if it is desktop experience or core) needs a reboot for the PV drivers to become available in the OS, then the disk can be added on the XCP-ng terminal. That's why it's a good time to install VMTools, which requires restart anyway.  
Add Disk.  

* QuorumDrive - stores quorum disk - once clustering is setup
* vhdxClusterStorageDrive - stores the profile vhdx'es - once file cluster is setup

```bash
# once the VM is installed, and vmTools with the PVdrivers are there, add drives
# do not initialize them - do that from the failover cluster console

/opt/scripts/vm_add_disk.sh --vmName 'b2_iscsi' --storageName 'node4_hdd_sdc_lsi' --diskName 'b2_iscsi_quorumDrive' --deviceId 5 --diskGB 20  --description 'w2k22_quorumDrive'
/opt/scripts/vm_add_disk.sh --vmName 'b2_iscsi' --storageName 'node4_hdd_sdc_lsi' --diskName 'b2_iscsi_vhdxClusterStorageDrive' --deviceId 6 --diskGB 100  --description 'w2k22_vhdxClusterStorageDrive'

# add network interfaces to the VM
# * cluster network
# * storage network
```

Eject installation media

```bash
xe vm-cd-eject vm='b2_iscsi'

```

This should take place after the installation of the Management Tools, anyway.
Once the computer is renamed, proceed with the code

TODO: Integrate the Set-InitialConfigDsc with the AutomatedLab powershell module

#### target nodes - desktop experience

1. Run code in the Elevated ISE

#### target nodes - core

1. Run code in the console, pick 15 from the sconfig

```powershell
https://makeitcloudy.pl/windows-DSC/
# proceed with the code from paragraph 2.2
# the code available in that paragraph runs the Set-InitialConfigDsc function which triggers the the code 
https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc.ps1
# config data are grabbed from here
# for the domain scenario to work properly the DNS should be configured properly (DomainDnsServers)
# and goes hand in hand with the IP addresses of the domain controllers 
https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigData.psd1
# run 
Set-InitialConfigDsc -NewComputerName $env:ComputerName -Option Domain -Verbose

# when the VM is provisioned login via XCP-ng console unless you know the IP address
```

### Windows - Server OS - 2x File Server - Core

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'b2_fs01' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:11' --StorageName 'node4_ssd_sdd' --VmDescription 'w2k22_fs01_Filer_core'

/opt/scripts/vm_create_uefi.sh --VmName 'b2_fs02' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:12' --StorageName 'node4_ssd_sde' --VmDescription 'w2k22_fs02_Filer_core'

```

Once the OS is installed, execute the code to mount the VMTools

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='b2_fs01'
xe vm-cd-insert vm='b2_fs01' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='b2_fs02'
xe vm-cd-insert vm='b2_fs02' cd-name='Citrix_Hypervisor_821_tools.iso'

```

Windows Server (regardsless if it is desktop experience or core) needs a reboot for the PV drivers to become available in the OS, then the disk can be added on the XCP-ng terminal. That's why it's a good time to install VMTools, which requires restart anyway.
Add Disk.  
Current DSC configuration configures the Filers as member servers, with no clustering and redudancy, so each drive has it's separate profile drive.

```bash
## the code works provided the vmtools are already installed, without PV drivers, it wont work
## Add Disk - this should be added only when the file servers plays role of the member servers and there is no clustering
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName 'b2_fs01' --storageName 'node4_hdd_sdc_lsi' --diskName 'fs01_PDrive' --deviceId 4 --diskGB 60  --description 'fs01_ProfileDrive'
/opt/scripts/vm_add_disk.sh --vmName 'b2_fs02' --storageName 'node4_hdd_sdc_lsi' --diskName 'fs02_PDrive' --deviceId 4 --diskGB 60  --description 'fs02_ProfileDrive'

```

The IP reservation on the DHCP server in the subnet are done, so get the IP address is known, otherwise login to the VM via XCP-ng console (no clipboard available) and get the IP address. Connect to the machine via RDP.
Note: Machine should have access to the internet to grab the content from github.

Then follow up with

```powershell
https://makeitcloudy.pl/windows-preparation/
# proceed with the code from paragraph 2.0.2
# run the code on the target node
# machine won't restart
```

```bash
xe vm-cd-eject vm='b2_fs01'
xe vm-cd-eject vm='b2_fs02'

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
# run first
Set-InitialConfigDsc -NewComputerName $env:ComputerName -Option Workgroup -Verbose
# then once finished (and the domain is already configured) run
Set-InitialConfigDsc -NewComputerName $env:ComputerName -Option Domain -Verbose

```

## Image Factory - OSD

### Windows - Desktop OS - Initial Configuration - ImageFactory Desktop

Node (Desktop) used to update the Desktop Based image OS'es

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName 'b2_osdD' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 90 --TemplateName 'Windows 10 (64-bit)' --IsoName 'w10ent_21H2_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:48' --StorageName 'node4_ssd_sdf' --VmDescription 'w10_osdD_imageFactory'

# After installation eject CD
# Run on XCP-ng
# eject installation media
xe vm-cd-eject vm='b2_osdD'
xe vm-cd-insert vm='b2_osdD' cd-name='Citrix_Hypervisor_821_tools.iso'

## Add Disk - Install XCP-ng tools upfront
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName 'b2_osdD' --storageName 'node4_hdd_sdc_lsi' --diskName 'b2_OSDd_dataDrive' --deviceId 4 --diskGB 120  --description 'b2_osdD_dataDrive'

```

### Windows - Server OS - Initial Configuration - ImageFactory Server

Node (Desktop) used to update the Server Based image OS'es

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName 'b2_osdS' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:38' --StorageName 'node4_ssd_sde' --VmDescription 'w2k22_osdS_imageFactory'

# After installation eject CD
# Run on XCP-ng
# eject installation media
xe vm-cd-eject vm='b2_osdS'
xe vm-cd-insert vm='b2_osdS' cd-name='Citrix_Hypervisor_821_tools.iso'

## Add Disk - Install XCP-ng tools upfront
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName 'b2_osdS' --storageName 'node4_hdd_sdc_lsi' --diskName 'b2_osdS_dataDrive' --deviceId 4 --diskGB 120  --description 'b2_osdS_dataDrive'

```


## Image Factory - Testing VM against the prepared ISO files

### Windows - Server OS - Core - w2k22 - BIOS

```bash
# Run on XCP-ng
#Windows 10 (64-bit)
#Windows Server 2022 (64-bit)
/opt/scripts/vm_create_bios.sh --VmName 'b2_w2k22cb' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2410_core_untd_nprmpt_bios.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:21' --StorageName 'node4_ssd_sdd' --VmDescription 'w2k22dtc_2410_core_untd_nprmpt_bios'
```

### Windows - Server OS - Core  - w2k22 - UEFI

```bash
# Run on XCP-ng
#Windows 10 (64-bit)
#Windows Server 2022 (64-bit)
/opt/scripts/vm_create_uefi.sh --VmName 'b2_w2k22cu' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2410_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:22' --StorageName 'node4_ssd_sde' --VmDescription 'w2k22dtc_2410_core_untd_nprmpt_uefi'
```

### Windows - Server OS - Desktop Experience - w2k22 - BIOS

```bash
# Run on XCP-ng
#Windows 10 (64-bit)
#Windows Server 2022 (64-bit)
/opt/scripts/vm_create_bios.sh --VmName 'b2_w2k22db' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2410_untd_nprmpt_bios.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:23' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22dtc_2410_desktopExperience_untd_nprmpt_bios'
```

### Windows - Server OS - Desktop Experience - w2k22 - UEFI

```bash
# Run on XCP-ng
#Windows 10 (64-bit)
#Windows Server 2022 (64-bit)
/opt/scripts/vm_create_uefi.sh --VmName 'b2_w2k22du' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2410_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:24' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22dtc_2410_desktopExperience_untd_nprmpt_bios'
```

### Windows - Desktop OS - w10 - 22H2 - BIOS

```bash
# Run on XCP-ng
#Windows 10 (64-bit)
#Windows Server 2022 (64-bit)
/opt/scripts/vm_create_bios.sh --VmName 'b2_w10b22H2' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 90 --TemplateName 'Windows 10 (64-bit)' --IsoName 'w10ent_22H2_2410_untd_nprmpt_bios.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:25' --StorageName 'node4_ssd_sdd' --VmDescription 'w10_22H2_2410_updates_bios'
```

### Windows - Desktop OS - w10 - 22H2 - UEFI

```bash
# Run on XCP-ng
#Windows 10 (64-bit)
#Windows Server 2022 (64-bit)
/opt/scripts/vm_create_uefi.sh --VmName 'b2_w10u22H2' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 90 --TemplateName 'Windows 10 (64-bit)' --IsoName 'w10ent_22H2_2410_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:26' --StorageName 'node4_ssd_sde' --VmDescription 'w10_22H2_2410_updates_uefi'
```

### Windows - Desktop OS - w10 - 21H2 - BIOS

```bash
# Run on XCP-ng
#Windows 10 (64-bit)
#Windows Server 2022 (64-bit)
/opt/scripts/vm_create_bios.sh --VmName 'b2_w10b21H2' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 90 --TemplateName 'Windows 10 (64-bit)' --IsoName 'Win10 x64 21H2 19044.2604_bios.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:27' --StorageName 'node4_ssd_sdd' --VmDescription 'w10-21H2_2410_updates_bios'
```

### Windows - Desktop OS - w10 - 21H2 - UEFI

```bash
# Run on XCP-ng
#Windows 10 (64-bit)
#Windows Server 2022 (64-bit)
/opt/scripts/vm_create_uefi.sh --VmName 'b2_w10u21H2' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 90 --TemplateName 'Windows 10 (64-bit)' --IsoName 'Win10 x64 21H2 19044.2604_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:28' --StorageName 'node4_ssd_sde' --VmDescription 'w10-21H2_2410_updates_uefi'
```