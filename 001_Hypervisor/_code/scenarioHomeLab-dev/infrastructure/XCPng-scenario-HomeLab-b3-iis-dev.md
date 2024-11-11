# IIS - dev

## Internet Information Services

### Windows - Server OS - ADDS - 2x IIS - Server Core

```bash
# First domain controller - server core
/opt/scripts/vm_create_uefi.sh --VmName 'b3_iis01' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth2-B3-vlan1343' --Mac '2A:B3:13:43:02:21' --StorageName 'node4_ssd_sdd' --VmDescription 'w2k22_b3_dc01_IIS_core'

# Second domain controller - server core
/opt/scripts/vm_create_uefi.sh --VmName 'b3_iis02' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth2-B3-vlan1343' --Mac '2A:B3:13:43:02:22' --StorageName 'node4_ssd_sde' --VmDescription 'w2k22_b3_dc02_IIS_core'

# mount vmTools
xe vm-cd-eject vm='b3_iis01'
xe vm-cd-insert vm='b3_iis01' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='b3_iis02'
xe vm-cd-insert vm='b3_iis02' cd-name='Citrix_Hypervisor_821_tools.iso'

```