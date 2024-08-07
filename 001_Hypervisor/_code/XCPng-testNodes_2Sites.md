# XCPng - Test Nodes

## Management Node

### Windows - Desktop OS - Initial Configuration - Management Node - w10mgmt

Node (Desktop) used to manage the environment and author DSC configurations - Starting Point

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName 'w10mgmt' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 90 --TemplateName 'Windows 10 (64-bit)' --IsoName 'w10ent_21H2_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:49' --StorageName 'node4_ssd_sdg' --VmDescription 'w10mgmt'

# After installation eject CD
# Run on XCP-ng
# eject installation media
xe vm-cd-eject vm='w10mgmt'
xe vm-cd-insert vm='w10mgmt' cd-name='Citrix_Hypervisor_821_tools.iso'

## Add Disk
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName 'w10mgmt' --storageName 'node4_hdd_sdc_lsi' --diskName 'w10mgmt_dataDrive' --deviceId 4 --diskGB 20  --description 'w10mgmt_dataDrive'
```

Then follow up with

```bash
https://makeitcloudy.pl/windows-preparation/
# proceed with the code from paragraph 2.0.2

https://makeitcloudy.pl/windows-DSC/
# proceed with the code from paragraph 2.2


# when the VM is provisioned login via XCP-ng console unless you know the IP address
# Restart-Computer for the succesfull installation of the PV-Tools
```

## Active Directory Domain Services

### Windows - Server OS - 2x Domain Controller - Server Core

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'dc01_core' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:01' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_dc01_ADDS_core'

/opt/scripts/vm_create_uefi.sh --VmName 'dc02_core' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:02' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_dc02_ADDS_core'
```

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='dc01_core'
xe vm-cd-insert vm='dc01_core' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='dc02_core'
xe vm-cd-insert vm='dc02_core' cd-name='Citrix_Hypervisor_821_tools.iso'
```

```powershell
https://makeitcloudy.pl/windows-preparation/ #paragraph 2.0.2
# run the code from this link
https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/_blogPost/windows-preparation/run_initialSetup.ps1
# which downloads the code and execute the code available here
https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfig.ps1

# 1. it install management tools with I/O drivers
# 2. it adds the registry key for the reboot after the management tools installation: CTX292687
# 3. if target VM is a DesktopOS it configures winRM, install RSAT ADDS, in case of server it skips it
# 4. it downlaods AutomatedLab module
# 5. it downloads AutomatedXCPng module
# 6. it changes the power plan to high performance

### repeat those steps for dc01 and dc02
$newComputerName = 'dc01' #FIXME: the computername 
#region Rename Computer
Rename-Computer -NewName $newComputerName -Restart -Force

### take the snapshot of the VM (dc01, dc02)

# then follow up with paragraph 3.3
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

```

## File Services

Desktop Experience OR Core

### Windows - Server OS - 1x File Server - iSCSI target - Desktop Experience

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'a_iscsi_dexp' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:10' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_iscsi_FileServer_desktop_experience'

/opt/scripts/vm_add_disk.sh --vmName "a_iscsi_dexp" --storageName "node4_hdd_sdc_lsi" --diskName "w2k22_iscsi_vhdxClusterStorageDrive" --deviceId 5 --diskGB 20  --description "w2k22_vhdxClusterStorageDrive"
/opt/scripts/vm_add_disk.sh --vmName "a_iscsi_dexp" --storageName "node4_hdd_sdc_lsi" --diskName "w2k22_iscsi_quorumDrive" --deviceId 6 --diskGB 20  --description "w2k22_quorumDrive"
```

### Windows - Server OS - 2x File Server - Desktop Experience

Node (Server) used to test the DSC code for Active Directory Domain Setup - Desktop Experience

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'a_fs01_dexp' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:11' --StorageName 'node4_ssd_sdd' --VmDescription 'w2k22_fs01_FileServer_desktop_experience'

/opt/scripts/vm_create_uefi.sh --VmName 'a_fs02_dexp' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:12' --StorageName 'node4_ssd_sde' --VmDescription 'w2k22_fs02_FileServer_desktop_experience'
```

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='a_fs01_dexp'
xe vm-cd-insert vm='a_fs01_dexp' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='a_fs02_dexp'
xe vm-cd-insert vm='a_fs02_dexp' cd-name='Citrix_Hypervisor_821_tools.iso'
```

### Windows - Server OS - 2x File Server - Core

Node (Server) used to test the DSC code for Active Directory Domain Setup - Core

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'a_fs01_core' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:11' --StorageName 'node4_ssd_sdd' --VmDescription 'w2k22_fs01_FileServer_core'

/opt/scripts/vm_create_uefi.sh --VmName 'a_fs02_core' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:12' --StorageName 'node4_ssd_sde' --VmDescription 'w2k22_fs02_FileServer_core'
```

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='a_fs01_core'
xe vm-cd-insert vm='a_fs01_core' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='a_fs02_core'
xe vm-cd-insert vm='a_fs02_core' cd-name='Citrix_Hypervisor_821_tools.iso'
```

## SQL Server

Desktop Experience OR Core

### Windows - Server OS - 2x SQL Server - Desktop Experience

Node (Server) used to test the DSC code for Active Directory Domain Setup - Desktop Experience

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'a_sql01_dexp' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:21' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_sql01_FileServer_desktop_experience'

/opt/scripts/vm_create_uefi.sh --VmName 'a_sql02_dexp' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:22' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_sql02_FileServer_desktop_experience'
```

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='a_sql01_dexp'
xe vm-cd-insert vm='a_sql01_dexp' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='a_sql02_dexp'
xe vm-cd-insert vm='a_sql02_dexp' cd-name='Citrix_Hypervisor_821_tools.iso'
```

### Windows - Server OS - 2x SQL Server - Core

Node (Server) used to test the DSC code for Active Directory Domain Setup - Core

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'a_sql01_core' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:21' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_sql01_SQLServer_core'

/opt/scripts/vm_create_uefi.sh --VmName 'a_sql02_core' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:22' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_sql02_SQLServer_core'
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