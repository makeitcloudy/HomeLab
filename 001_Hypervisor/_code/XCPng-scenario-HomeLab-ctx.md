## CTX SETUP

### CTX - VM Provisioning

#### Windows - Server OS - Broker

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'b2_ctx01B' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2410_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-vlan1342' --Mac '12:B2:13:42:02:33' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_Broker'

/opt/scripts/vm_create_uefi.sh --VmName 'b2_ctx02B' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2410_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-vlan1342' --Mac '12:B2:13:42:02:34' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_Broker'
```

#### Windows - Server OS - FAS

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'b2_ctx01F' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2410_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-vlan1342' --Mac '12:B2:13:42:02:37' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_FAS'

/opt/scripts/vm_create_uefi.sh --VmName 'b2_ctx02F' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2410_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-vlan1342' --Mac '12:B2:13:42:02:38' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_FAS'
```

#### Windows - Server OS - Misc / License Server

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'b2_ctx01L' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2410_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-vlan1342' --Mac '12:B2:13:42:02:31' --StorageName 'node4_ssd_sdd' --VmDescription 'w2k22_License'

/opt/scripts/vm_create_uefi.sh --VmName 'b2_ctx02L' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2410_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-vlan1342' --Mac '12:B2:13:42:02:32' --StorageName 'node4_ssd_sde' --VmDescription 'w2k22_License'
```

#### Windows - Server OS - PVS

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'b2_ctx01P' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2410_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-vlan1342' --Mac '12:B2:13:42:02:41' --StorageName 'node4_ssd_sdd' --VmDescription 'w2k2_PVS'

/opt/scripts/vm_create_uefi.sh --VmName 'b2_ctx02P' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2410_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-vlan1342' --Mac '12:B2:13:42:02:42' --StorageName 'node4_ssd_sde' --VmDescription 'w2k22_PVS'
```

#### Windows - Server OS - StoreFront

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'b2_ctx01S' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2410_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-vlan1342' --Mac '12:B2:13:42:02:35' --StorageName 'node4_ssd_sdd' --VmDescription 'w2k22_storeFront'

/opt/scripts/vm_create_uefi.sh --VmName 'b2_ctx02S' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2410_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-vlan1342' --Mac '12:B2:13:42:02:36' --StorageName 'node4_ssd_sde' --VmDescription 'w2k22_storeFront'
```

### CTX - VM Tools - Inser Media

#### CTX - VM Tools - 01

```bash
xe vm-cd-eject vm='b2_ctx01B'
xe vm-cd-insert vm='b2_ctx01B' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='b2_ctx01F'
xe vm-cd-insert vm='b2_ctx01P' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='b2_ctx01L'
xe vm-cd-insert vm='b2_ctx01L' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='b2_ctx01P'
xe vm-cd-insert vm='b2_ctx01F' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='b2_ctx01S'
xe vm-cd-insert vm='b2_ctx01S' cd-name='Citrix_Hypervisor_821_tools.iso'
```

#### CTX - VM Tools - 02

```bash
xe vm-cd-eject vm='b2_ctx02B'
xe vm-cd-insert vm='b2_ctx02B' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='b2_ctx02F'
xe vm-cd-insert vm='b2_ctx02P' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='b2_ctx02L'
xe vm-cd-insert vm='b2_ctx02L' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='b2_ctx02P'
xe vm-cd-insert vm='b2_ctx02F' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='b2_ctx02S'
xe vm-cd-insert vm='b2_ctx02S' cd-name='Citrix_Hypervisor_821_tools.iso'
```

### CTX - Initial Setup

https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/README.md#run_initialsetupps1

It:
* install vmTools
* enables WinRM on Desktop OS
* it downloads PowerShell modules for further steps along with (AutomatedLab, AutomatedXCPng modueles)
* it does what is listed in paragraph 2.0.1 - https://makeitcloudy.pl/windows-preparation/

### CTX - VM Tools - Eject Media

#### CTX - VM tools - 01 - Eject Media

```bash
xe vm-cd-eject vm='b2_ctx01B'
xe vm-cd-eject vm='b2_ctx01F'
xe vm-cd-eject vm='b2_ctx01L'
xe vm-cd-eject vm='b2_ctx01P'
xe vm-cd-eject vm='b2_ctx01S'
```

#### CTX - VM Tools - 02 - Eject Media

```bash
xe vm-cd-eject vm='b2_ctx02B'
xe vm-cd-eject vm='b2_ctx02F'
xe vm-cd-eject vm='b2_ctx02L'
xe vm-cd-eject vm='b2_ctx02P'
xe vm-cd-eject vm='b2_ctx02S'
```

### CTX - Initial Setup - Domain Join

https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/README.md#run_initialconfigdsc_domainps1



It:
* It initialize all variables for succesfull code execution
* It creates the folders structure for the DSC compilations, etc - $env:SYSTEMDRIVE\dsc
* It downloads the powershell functions and configuration
It configures the LCM
It starts the actual configuration of the node

* it does what is listed in paragraph 3.0 - https://makeitcloudy.pl/windows-DSC/

## DaaS Extension

### Cloud Connector

### Windows - Server OS - 1x cloud connector - Desktop Experience

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'b2_cc01' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-vlan1342' --Mac '12:B2:13:42:02:43' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_cc01_cloudConnector'

/opt/scripts/vm_create_uefi.sh --VmName 'b2_cc02' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-vlan1342' --Mac '12:B2:13:42:02:44' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_cc02_cloudConnector'

```

