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

## XCP-ng - HomeLab - VMTools

```bash
# atuomated installation of the VMTools works - provided there is only one iso on SR with such name
# .iso should be available in following location: 
# /var/opt/xen/ISO_Store      - custom local iso storage created during the XCPng setup
# /opt/xensource/packages/iso - default iso storage with XCPng tools
```

## Management Node

Configuration Data for the Desired State Configuration (DSC) is stored in the [HomeLab](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigData.psd1) Git repository.

### Windows - Desktop OS - Management Node - w10mgmt - Provisioning

Node (Desktop) used to manage the environment and author DSC configurations - Starting Point

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName 'b2_w10mgmt' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 90 --TemplateName 'Windows 10 (64-bit)' --IsoName 'w10ent_21H2_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:49' --StorageName 'node4_ssd_sdf' --VmDescription 'b2_w10mgmt_MgmtNode'

# After installation eject CD
# Run on XCP-ng
# eject installation media
xe vm-cd-eject vm='b2_w10mgmt'
xe vm-cd-insert vm='b2_w10mgmt' cd-name='Citrix_Hypervisor_821_tools.iso'
```

### Windows - Desktop OS - Management Node - w10mgmt - Initial Configuration after Installation

Then follow up with:
* Login to the VM via RDP (devolutions)
* xentools asks for the PV drivers installation, hit yes and restart the VM

```powershell
https://makeitcloudy.pl/windows-preparation/
# proceed with the code from paragraph 2.0.2 it leads to

https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/README.md#run_initialsetupps1
# 1. run the code from the section #run_initialsetup.ps1
# 2. you are asked for the new name of the node, use b2-w10mgmt
# 3. machine restarts
```

### Windows - Desktop OS - Management Node - w10mgmt - Eject Media

```bash
xe vm-cd-eject vm='b2_w10mgmt'
```

### Windows - Desktop OS - Management Node - w10mgmt - Add Disk

```bash
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName 'b2_w10mgmt' --storageName 'node4_hdd_sdc_lsi' --diskName 'b2_w10mgmt_dataDrive' --deviceId 4 --diskGB 40  --description 'b2_w10mgmt'
```

https://makeitcloudy.pl/windows-preparation/ - describes the steps for the mgmt node setup

### Windows - Desktop OS - Management Node - w10mgmt - Workgroup / Domain Join

For the domain join usecase - proceed with the code (provided the domain controllers are in place, and DNS can resolve the names properly.)

```powershell
https://makeitcloudy.pl/windows-DSC/
# proceed with the code from paragraph 2.2
# the code available in that paragraph runs the Set-InitialConfigDsc function which triggers the the code 
https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc.ps1

# scenario - workgroup - run first
Set-InitialConfigDsc -NewComputerName $NodeName -Option Workgroup -Verbose
# scenario - domain - when the domain is already configured
$domainName = 'lab.local'  #FIXME
Set-InitialConfigDsc -NewComputerName $env:computername -Option Domain -DomainName $domainName -Verbose

# when the VM is provisioned login via XCP-ng console unless you know the IP address
# Restart-Computer for the succesfull installation of the PV-Tools
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
/opt/scripts/vm_add_disk.sh --vmName 'b2_osdD' --storageName 'node4_hdd_sdc_lsi' --diskName 'b2_OSDd_dataDrive' --deviceId 4 --diskGB 160  --description 'b2_osdD_dataDrive'

```

### Windows - Server OS - Initial Configuration - ImageFactory Server

Node (Desktop) used to update the Server Based image OS'es

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName 'b2_osdS' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:38' --StorageName 'node4_ssd_sdb' --VmDescription 'w2k22_osdS_imageFactory'

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
/opt/scripts/vm_create_uefi.sh --VmName 'b2_w2k22du' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2410_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-B2-vlan1342' --Mac '12:B2:13:42:02:24' --StorageName 'node4_ssd_sdb' --VmDescription 'w2k22dtc_2410_desktopExperience_untd_nprmpt_bios'
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