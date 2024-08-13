# XCP-ng - HomeLab

It contains the code which creates the VM on the XCP-ng hypervisor. It has the dependencies on the following scripts, which should exist on the XCP-ng in */opt/scripts*. Details are described in the [blogpost](https://makeitcloudy.pl/windows-preparation/), which is also available [here](https://github.com/makeitcloudy/makeitcloudy.github.io/blob/master/_posts/2022-05-13-windows-preparation.md).

* [AutomatedXCP-ng](https://github.com/makeitcloudy/AutomatedXCP-ng/)
* AutomatedXCP-ng [/opt/scripts/vm_create_bios.sh](https://github.com/makeitcloudy/AutomatedXCP-ng/blob/main/bash/vm_create_bios.sh)
* AutomatedXCP-ng [/opt/scripts/vm_create_uefi.sh](https://github.com/makeitcloudy/AutomatedXCP-ng/blob/main/bash/vm_create_uefi.sh)
* AutomatedXCP-ng [/opt/scripts/vm_create_uefi_secureBoot.sh](https://github.com/makeitcloudy/AutomatedXCP-ng/blob/main/bash/vm_create_uefi_secureBoot.sh)
* AutomatedXCP-ng [/opt/scripts/vm_add_disk.sh](https://github.com/makeitcloudy/AutomatedXCP-ng/blob/main/bash/vm_add_disk.sh)

## XCP-ng - HomeLab - Assumptions

It is assumed:

1. that the storage and network is configured on the XCP-ng.
2. there is Storage Repository which keeps the ISO's used for the VM installations
3. there is a DHCP server within the network, so it is possible to RDP to the VM's (Xen Orchestra used to login to the VM's via virtual console, at this stage does not offer the clipboard)
4. the ISO's are unattended - [blog post](https://makeitcloudy.pl/OSDBuilder-offline-servicing-updates/) - describing the process

## Management Node

Configuration Data for the Desired State Configuration (DSC) is stored in the [HomeLab](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigData.psd1) Git repository.

### Windows - Desktop OS - Initial Configuration - Management Node - w10mgmt

Node (Desktop) used to manage the environment and author DSC configurations - Starting Point

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName 'c1_w10mgmt' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 90 --TemplateName 'Windows 10 (64-bit)' --IsoName 'w10ent_21H2_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:C1:00:19' --StorageName 'node4_ssd_sdg' --VmDescription 'c1_w10mgmt'

# After installation eject CD
# Run on XCP-ng
# eject installation media
xe vm-cd-eject vm='c1_w10mgmt'
xe vm-cd-insert vm='c1_w10mgmt' cd-name='Citrix_Hypervisor_821_tools.iso'

## Add Disk
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName 'c1_w10mgmt' --storageName 'node4_hdd_sdc_lsi' --diskName 'c1_w10mgmt_dataDrive' --deviceId 4 --diskGB 20  --description 'c1_w10mgmt'
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
/opt/scripts/vm_create_uefi.sh --VmName 'c1_dc01' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:C1:00:01' --StorageName 'node4_ssd_sdd' --VmDescription 'w2k22_dc01_ADDS_core'

/opt/scripts/vm_create_uefi.sh --VmName 'c1_dc02' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:C1:00:02' --StorageName 'node4_ssd_sde' --VmDescription 'w2k22_dc02_ADDS_core'
```

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='c1_dc01'
xe vm-cd-insert vm='c1_dc01' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='c1_dc02'
xe vm-cd-insert vm='c1_dc02' cd-name='Citrix_Hypervisor_821_tools.iso'
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

### Windows - Server OS - 1x ADCS Root, 1x ADCS Sub - DesktopExperience

Desktop Experience - 'w2k22dtc_2302_untd_nprmpt_uefi.iso'
Core - 'w2k22dtc_2302_core_untd_nprmt_uefi.iso'

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'adcsR_dexp' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:19' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_dhcp01_ADCS_Root_desktopExperience'

/opt/scripts/vm_create_uefi.sh --VmName 'adcsS_dexp' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:18' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_dhcp02_ADCS_Sub_desktopExperience'
```

Once the OS is installed, execute the code to mount the VMTools

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='adcsR_dexp'
xe vm-cd-insert vm='adcsR_dexp' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='adcsS_dexp'
xe vm-cd-insert vm='adcsS_dexp' cd-name='Citrix_Hypervisor_821_tools.iso'
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
xe vm-cd-eject vm='adcsR_dexp'
xe vm-cd-eject vm='adcsS_dexp'
```

```powershell
#repeat those steps for fs01 and fs02
Rename-Computer -NewName 'adcsR' -Restart -Force #FIXME: the computername 
Rename-Computer -NewName 'adcsS' -Restart -Force #FIXME: the computername 
```

Proceed with the code

* adcsR - is a root CA - do not add it to the domain
* adcsS - is subCA - add it to the domain

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
/opt/scripts/vm_create_uefi.sh --VmName 'dhcp01_core' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:11' --StorageName 'node4_ssd_sdd' --VmDescription 'w2k22_dhcp01_DHCPServer_core'

/opt/scripts/vm_create_uefi.sh --VmName 'dhcp02_core' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:12' --StorageName 'node4_ssd_sde' --VmDescription 'w2k22_dhcp02_DHCPServer_core'
```

Once the OS is installed, execute the code to mount the VMTools

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='dhcp01_core'
xe vm-cd-insert vm='dhcp01_core' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='dhcp02_core'
xe vm-cd-insert vm='dhcp02_core' cd-name='Citrix_Hypervisor_821_tools.iso'
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
xe vm-cd-eject vm='dhcp01_core'
xe vm-cd-eject vm='dhcp02_core'
```

```powershell
#repeat those steps for fs01 and fs02
Rename-Computer -NewName 'dhcp01' -Restart -Force #FIXME: the computername 
Rename-Computer -NewName 'dhcp02' -Restart -Force #FIXME: the computername 
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

## File Services

Desktop Experience OR Core

### Windows - Server OS - 1x File Server - iSCSI target - Desktop Experience

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'iscsi_dexp' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:09' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_iscsi_FileServer_desktop_experience'

# once the VM is installed add drives
# do not initialize them - do that from the failover cluster console

/opt/scripts/vm_add_disk.sh --vmName "iscsi_dexp" --storageName "node4_hdd_sdc_lsi" --diskName "w2k22_iscsi_quorumDrive" --deviceId 5 --diskGB 20  --description "w2k22_quorumDrive"
/opt/scripts/vm_add_disk.sh --vmName "iscsi_dexp" --storageName "node4_hdd_sdc_lsi" --diskName "w2k22_iscsi_vhdxClusterStorageDrive" --deviceId 6 --diskGB 100  --description "w2k22_vhdxClusterStorageDrive"

# add network interfaces to the VM, so there is cluster and storage network
```

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='iscsi_dexp'
xe vm-cd-insert vm='iscsi_dexp' cd-name='Citrix_Hypervisor_821_tools.iso'
```

Proceed further with

```powershell
https://makeitcloudy.pl/windows-preparation/
# proceed with the code from paragraph 2.0.2
# run the code on the target node
# machine won't restart
```

```bash
xe vm-cd-eject vm='iscsi_dexp'
```

At this point rename the computer and reboot it.

```powershell
Rename-Computer -NewName 'iscsi' -Restart -Force #FIXME: the computername 
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

File Server - cluster - 'w2k22dtc_2302_untd_nprmpt_uefi.iso'

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'fs01_core' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:21' --StorageName 'node4_ssd_sdd' --VmDescription 'w2k22_fs01_FileServer_core'

/opt/scripts/vm_create_uefi.sh --VmName 'fs02_core' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:22' --StorageName 'node4_ssd_sde' --VmDescription 'w2k22_fs02_FileServer_core'
```

Once the OS is installed, execute the code to mount the VMTools

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='fs01_core'
xe vm-cd-insert vm='fs01_core' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='fs02_core'
xe vm-cd-insert vm='fs02_core' cd-name='Citrix_Hypervisor_821_tools.iso'
```

Add Disk. The current DSC configuration configures the Filers as member servers, with no clustering and redudancy, so each drive has it's separate profile drive.

```bash
## Add Disk
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName 'fs01_core' --storageName 'node4_hdd_sdc_lsi' --diskName 'fs01_PDrive' --deviceId 4 --diskGB 60  --description 'fs01_ProfileDrive'
/opt/scripts/vm_add_disk.sh --vmName 'fs02_core' --storageName 'node4_hdd_sdc_lsi' --diskName 'fs02_PDrive' --deviceId 4 --diskGB 60  --description 'fs02_ProfileDrive'
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
xe vm-cd-eject vm='fs01_core'
xe vm-cd-eject vm='fs02_core'
```

```powershell
#repeat those steps for fs01 and fs02
Rename-Computer -NewName 'fs01' -Restart -Force #FIXME: the computername 
Rename-Computer -NewName 'fs02' -Restart -Force #FIXME: the computername 
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

## SQL Server

Desktop Experience OR Core

### Windows - Server OS - 2x SQL Server - Desktop Experience

Node (Server) used to test the DSC code for Active Directory Domain Setup - Desktop Experience

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'sql01_dexp' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:31' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_sql01_SQLServer_desktop_experience'

/opt/scripts/vm_create_uefi.sh --VmName 'sql02_dexp' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:32' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_sql02_SQLServer_desktop_experience'
```

Once VM's are ready, hit yes for the autodiscovery, pick No for the PV restart.

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='sql01_dexp'
xe vm-cd-insert vm='sql01_dexp' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='sql02_dexp'
xe vm-cd-insert vm='sql02_dexp' cd-name='Citrix_Hypervisor_821_tools.iso'
```

Add extra disk for the database storage

```bash
/opt/scripts/vm_add_disk.sh --vmName "sql01_dexp" --storageName "node4_ssd_sdd" --diskName "w2k22_sql01_Sdrive" --deviceId 5 --diskGB 30  --description "w2k22_Sdrive_SQLDBdrive"
/opt/scripts/vm_add_disk.sh --vmName "sql02_dexp" --storageName "node4_ssd_sde" --diskName "w2k22_sql02_Sdrive" --deviceId 5 --diskGB 30  --description "w2k22_Sdrive_SQLDBdrive"
# in case the drive size is adjusted, it should be also updated in the ConfigureNode.ps1 file
# which keeps the DSC script for the initial configuration of the nodes
```

Then proceed with

```powershell
https://makeitcloudy.pl/windows-preparation/
# proceed with the code from paragraph 2.0.2
# run the code on the target node
# machine won't restart
```

```bash
xe vm-cd-eject vm='sql01_dexp'
xe vm-cd-insert vm='sql01_dexp' cd-name='SQLServer2019-x64-ENU.iso'
xe vm-cd-eject vm='sql02_dexp'
xe vm-cd-insert vm='sql02_dexp' cd-name='SQLServer2019-x64-ENU.iso'
```

At this point rename the computer and reboot it.

```powershell
Rename-Computer -NewName 'sql01' -Restart -Force #FIXME: the computername
Rename-Computer -NewName 'sql02' -Restart -Force #FIXME: the computername
```

This should take place after the installation of the Management Tools, anyway.
Once the computer is renamed, proceed with the code

TODO: Integrate the Set-InitialConfigDsc with the AutomatedLab powershell module
TODO: https://makeitcloudy.pl/windows-DSC/ paragraph 2.2 - the computername is already set, though still should be passed as a parameter into script, never the less not needed anymore to put it manually, grab it as an environmental variable

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

### Windows - Server OS - 2x SQL Server - Core

SQL Server can be installed on Windows Server Core.

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'a_sql01_core' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:31' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_sql01_SQLServer_core'

/opt/scripts/vm_create_uefi.sh --VmName 'a_sql02_core' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:32' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_sql02_SQLServer_core'
```

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='a_sql01_core'
xe vm-cd-insert vm='a_sql01_core' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='a_sql02_core'
xe vm-cd-insert vm='a_sql02_core' cd-name='Citrix_Hypervisor_821_tools.iso'
```

## Image Factory - OSD

### Windows - Desktop OS - Initial Configuration - ImageFactory Desktop

Node (Desktop) used to update the Desktop Based image OS'es

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName 'a_OSDd' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 90 --TemplateName 'Windows 10 (64-bit)' --IsoName 'w10ent_21H2_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:48' --StorageName 'node4_ssd_sdf' --VmDescription 'w10_imageFactory_for_DesktopOS'

# After installation eject CD
# Run on XCP-ng
# eject installation media
xe vm-cd-eject vm='a_OSDd'
xe vm-cd-insert vm='a_OSDd' cd-name='Citrix_Hypervisor_821_tools.iso'

## Add Disk
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName 'a_OSDd' --storageName 'node4_hdd_sdc_lsi' --diskName 'aOSDd_dataDrive' --deviceId 4 --diskGB 120  --description 'aOSDd_dataDrive'
```

### Windows - Server OS - Initial Configuration - ImageFactory Server

Node (Desktop) used to update the Server Based image OS'es

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName 'a_OSDs' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:47' --StorageName 'node4_ssd_sde' --VmDescription 'w2k22_imageFactory_for_ServerOS'

# After installation eject CD
# Run on XCP-ng
# eject installation media
xe vm-cd-eject vm='a_OSDs'
xe vm-cd-insert vm='a_OSDs' cd-name='Citrix_Hypervisor_821_tools.iso'

## Add Disk
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName "a_OSDs" --storageName "node4_hdd_sdc_lsi" --diskName "aOSDs_dataDrive" --deviceId 4 --diskGB 120  --description "aOSDs_dataDrive"
```

## Cloud Connector

### Windows - Server OS - 1x cloud connector - Desktop Experience

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'a_cloudC' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:23' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_sql01_cloudConnector_core'

## Misc

### Windows - Server OS - Initial Configuration - Testing Node - Desktop Experience

Node (Server) used to test the DSC code for joining the domain

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName '_w2k22d' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:20' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_desktop_experience_node'

# After installation eject CD
# Run on XCP-ng
# eject installation media
xe vm-cd-eject vm=_w2k22d

## Add Disk
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName "_w2k22d" --storageName "node4_hdd_sdc_lsi" --diskName "w2k22_dataDrive" --deviceId 4 --diskGB 20  --description "w2k22_dataDrive"
```

### Windows - Server OS - Initial Configuration - Testing Node - Core

Node (Server) used to test the DSC code for joining the domain

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName '_w2k22c' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:21' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_core_node'

# After installation eject CD
# Run on XCP-ng
# eject installation media
xe vm-cd-eject vm=_w2k22c

## Add Disk
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName "_w2k22c" --storageName "node4_hdd_sdc_lsi" --diskName "w2k22_dataDrive" --deviceId 4 --diskGB 20  --description "w2k22_dataDrive"
```