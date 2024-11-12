# MGMT - dev

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName 'd_b2_w10mgmt' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 90 --TemplateName 'Windows 10 (64-bit)' --IsoName 'w10ent_21H2_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'dev-B2-vlan1542' --Mac '1A:B2:15:42:02:49' --StorageName 'node4_ssd_sdf' --VmDescription 'w10mgmt_MgmtNode'

# After installation eject CD
# Run on XCP-ng
# eject installation media
xe vm-cd-eject vm='d_b2_w10mgmt'
xe vm-cd-insert vm='d_b2_w10mgmt' cd-name='Citrix_Hypervisor_821_tools.iso'
```