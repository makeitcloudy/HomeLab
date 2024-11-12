# MGMT - dev

## Management Node

Configuration Data for the Desired State Configuration (DSC) is stored in the [HomeLab](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigData-dev.psd1) Git repository.

### Windows - Desktop OS - Management Node - w10mgmt - Provisioning

```bash
# Run on XCP-ng
/opt/scripts/vm_create_uefi.sh --VmName 'd_b2_w10mgmt' --VCpu 4 --CoresPerSocket 2 --MemoryGB 8 --DiskGB 40 --ActivationExpiration 90 --TemplateName 'Windows 10 (64-bit)' --IsoName 'w10ent_21H2_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'dev-B2-vlan1542' --Mac '1A:B2:15:42:02:49' --StorageName 'node4_ssd_sdf' --VmDescription 'w10mgmt_MgmtNode'

# After installation eject CD
# Run on XCP-ng
# eject installation media
xe vm-cd-eject vm='d_b2_w10mgmt'
xe vm-cd-insert vm='d_b2_w10mgmt' cd-name='Citrix_Hypervisor_821_tools.iso'
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
xe vm-cd-eject vm='d_b2_w10mgmt'
```

### Windows - Desktop OS - Management Node - w10mgmt - Add Disk

```bash
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName 'd_b2_w10mgmt' --storageName 'node4_hdd_sdc_lsi' --diskName 'd_b2_w10mgmt_dataDrive' --deviceId 4 --diskGB 40  --description 'b2_w10mgmt'
```

https://makeitcloudy.pl/windows-preparation/ - describes the steps for the mgmt node setup

### Windows - Desktop OS - Management Node - w10mgmt - Workgroup / Domain Join

For the domain join usecase - proceed with the code (provided the domain controllers are in place, and DNS can resolve the names properly.)

```powershell
https://makeitcloudy.pl/windows-DSC/
# proceed with the code from paragraph 2.2
# the code available in that paragraph runs the Set-InitialConfigDsc function which triggers the the code 
https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/README.md#run_initialconfigdsc_domain-devps1

# which runs:
# https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc-dev.ps1

# scenario - workgroup - run first
Set-InitialConfigDevDsc -NewComputerName $NodeName -Option Workgroup -Verbose
# scenario - domain - when the domain is already configured
$domainName = 'd.local'  #FIXME
Set-InitialConfigDevDsc -NewComputerName $env:computername -Option Domain -DomainName $domainName -Verbose

# when the VM is provisioned login via XCP-ng console unless you know the IP address
# Restart-Computer for the succesfull installation of the PV-Tools
```

## continue with the software installation

```powershell
https://makeitcloudy.pl/windows-preparation/ 
# paragraph 4
```