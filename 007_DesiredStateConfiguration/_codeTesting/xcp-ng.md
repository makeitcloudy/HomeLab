# Code used for testing, provisioning and what not

## XCP-ng

### windows - Desktop OS - w10tmgmt VM

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName '_w10t_mgmt' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 90 --TemplateName 'Windows 10 (64-bit)' --IsoName 'w10ent_21H2_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:39' --StorageName 'node4_ssd_sdg' --VmDescription 'w10_test_mgmt_node'

# After installation eject CD
# Run on XCP-ng
# eject installation media
xe vm-cd-eject vm=_w10t_mgmt

## Add Disk
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName "_w10t_mgmt" --storageName "node4_hdd_sdc_lsi" --diskName "w10_mgmt_dataDrive" --deviceId 4 --diskGB 20  --description "w10t_mgmt_dataDrive"
```

### windows - Desktop OS - adJoin VM

Node (Desktop) used to test the DSC code for joining the domain

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName '_djd' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 90 --TemplateName 'Windows 10 (64-bit)' --IsoName 'w10ent_21H2_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:19' --StorageName 'node4_ssd_sdf' --VmDescription 'w10_test_domainJoin'

# After installation eject CD
# Run on XCP-ng
# eject installation media
xe vm-cd-eject vm=_w10t_mgmt

## Add Disk
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName "_w10t_mgmt" --storageName "node4_hdd_sdc_lsi" --diskName "w10_mgmt_dataDrive" --deviceId 4 --diskGB 20  --description "w10t_mgmt_dataDrive"
```

## windows - Server OS - adJoin Vm

Node (Server) used to test the DSC code for joining the domain

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName '_djs' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 90 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1 - VLAN1342 untagged - up' --Mac '2A:47:41:D9:00:20' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_test_domainJoin'

# After installation eject CD
# Run on XCP-ng
# eject installation media
xe vm-cd-eject vm=_w10t_mgmt

## Add Disk
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName "_w10t_mgmt" --storageName "node4_hdd_sdc_lsi" --diskName "w10_mgmt_dataDrive" --deviceId 4 --diskGB 20  --description "w10t_mgmt_dataDrive"
```

##