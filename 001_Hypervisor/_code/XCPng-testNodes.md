# XCPng - Test Nodes

## Initial Setup

### Windows - Desktop OS - Initial Configuration - Testing Node

Node (Desktop) used to test the DSC code - Starting Point

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName '_w10' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 90 --TemplateName 'Windows 10 (64-bit)' --IsoName 'w10ent_21H2_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:19' --StorageName 'node4_ssd_sde' --VmDescription 'w10_node'

# After installation eject CD
# Run on XCP-ng
# eject installation media
xe vm-cd-eject vm=_w10

## Add Disk
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName "_w10" --storageName "node4_hdd_sdc_lsi" --diskName "w10_node_dataDrive" --deviceId 4 --diskGB 20  --description "w10_node_dataDrive"
```

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

## Active Directory Domain Services

### Windows - Server OS - 2x Domain Controller - Desktop Experience

Node (Server) used to test the DSC code for Active Directory Domain Setup - Desktop Experience

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'dc01_dexp' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '5E:16:3e:5d:1f:01' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_dc01_desktop_experience'

/opt/scripts/vm_create_uefi.sh --VmName 'dc02_dexp' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '5E:16:3e:5d:1f:02' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_dc02_desktop_experience'
```

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='dc01_dexp'
xe vm-cd-insert vm='dc01_dexp' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='dc02_dexp'
xe vm-cd-insert vm='dc02_dexp' cd-name='Citrix_Hypervisor_821_tools.iso'
```

### Windows - Server OS - 2x Domain Controller - Core

Node (Server) used to test the DSC code for Active Directory Domain Setup - Desktop Experience

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'dc01_core' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '5E:16:3e:5d:1f:01' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_dc01_core'

/opt/scripts/vm_create_uefi.sh --VmName 'dc02_core' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '5E:16:3e:5d:1f:02' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_dc02_core'
```

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='dc01_core'
xe vm-cd-insert vm='dc01_core' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='dc02_core'
xe vm-cd-insert vm='dc02_core' cd-name='Citrix_Hypervisor_821_tools.iso'
```

## File Services

### Windows - Server OS - 2x File Server - Desktop Experience / Core

## SQL Server

### Windows - Server OS - Desktop Experience / Core