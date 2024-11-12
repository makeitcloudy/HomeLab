# File Services

## Windows File Server

### Windows - Server OS - 1x File Server - iSCSI target - Core

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'p_b2_iscsi' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'prod-B2-vlan1342' --Mac '16:B2:13:42:02:13' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_iscsi_Filer'

```

Once the OS is installed, execute the code to mount the VMTools

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='p_b2_iscsi'
xe vm-cd-insert vm='p_b2_iscsi' cd-name='Citrix_Hypervisor_821_tools.iso'

```

Then follow up with

* [run_initialSetup.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/README.md#run_initialsetupps1) - it asks for the new name of the vm, reboots the VM. Now it's time to add extra disk, so the DSC can succesfully executes.  

Windows Server (regardsless if it is desktop experience or core) needs a reboot for the PV drivers to become available in the OS, then the disk can be added on the XCP-ng terminal. That's why it's a good time to install VMTools, which requires restart anyway.  
Add Disk.  

* QuorumDrive - stores quorum disk - once clustering is setup
* vhdxClusterStorageDrive - stores the profile vhdx'es - once file cluster is setup

```bash
# once the VM is installed, and vmTools with the PVdrivers are there, add drives
# do not initialize them - do that from the failover cluster console

/opt/scripts/vm_add_disk.sh --vmName 'p_b2_iscsi' --storageName 'node4_hdd_sdc_lsi' --diskName 'p_b2_iscsi_quorumDrive' --deviceId 5 --diskGB 20  --description 'w2k22_quorumDrive'
/opt/scripts/vm_add_disk.sh --vmName 'p_b2_iscsi' --storageName 'node4_hdd_sdc_lsi' --diskName 'p_b2_iscsi_vhdxClusterStorageDrive' --deviceId 6 --diskGB 100  --description 'w2k22_vhdxClusterStorageDrive'

# add network interfaces to the VM
# * cluster network
# * storage network
```

* once the disks are added, run

```powershell
$domainName = 'lab.local'  #FIXME
Set-InitialConfigDsc -NewComputerName $env:computername -Option Domain -DomainName $domainName -Verbose
```

### File Services - iscsi - Eject installation media

```bash
xe vm-cd-eject vm='p_b2_iscsi'

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
/opt/scripts/vm_create_uefi.sh --VmName 'p_b2_fs01' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'prod-B2-vlan1342' --Mac '16:B2:13:42:02:11' --StorageName 'node4_ssd_sdb' --VmDescription 'w2k22_Filer_core'

/opt/scripts/vm_create_uefi.sh --VmName 'p_b2_fs02' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'prod-B2-vlan1342' --Mac '16:B2:13:42:02:12' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_Filer_core'

```

Once the OS is installed, execute the code to mount the VMTools

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='p_b2_fs01'
xe vm-cd-insert vm='p_b2_fs01' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='p_b2_fs02'
xe vm-cd-insert vm='p_b2_fs02' cd-name='Citrix_Hypervisor_821_tools.iso'

```

Then follow up with

* [run_initialSetup.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/README.md#run_initialsetupps1) - it ask for the new name of the vm, then the VM will be rebooted.  

Windows Server (regardless if it is desktop experience or core) needs a reboot for the PV drivers to become available in the OS, then the disk can be added on the XCP-ng terminal. That's why it's a good time to install VMTools, which requires restart anyway.  
Add Disk.  
Current DSC configuration configures the Filers as member servers, with no clustering and redudancy, so each drive has it's separate profile drive.  

```bash
## the code works provided the vmtools are already installed, without PV drivers, it wont work
## Add Disk - this should be added only when the file servers plays role of the member servers and there is no clustering
# run over SSH
/opt/scripts/vm_add_disk.sh --vmName 'p_b2_fs01' --storageName 'node4_hdd_sdc_lsi' --diskName 'p_fs01_PDrive' --deviceId 4 --diskGB 120  --description 'p_b2_fs01_ProfileDrive'
/opt/scripts/vm_add_disk.sh --vmName 'p_b2_fs02' --storageName 'node4_hdd_sdc_lsi' --diskName 'p_fs02_PDrive' --deviceId 4 --diskGB 120  --description 'p_b2_fs02_ProfileDrive'

```

* once the disks are added, run the following

```powershell
$domainName = 'lab.local'  #FIXME
Set-InitialConfigDsc -NewComputerName $env:computername -Option Domain -DomainName $domainName -Verbose
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
xe vm-cd-eject vm='p_b2_fs01'
xe vm-cd-eject vm='p_b2_fs02'

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


### PowerShell code

#### disable ipv6

```
Get-NetAdapterBinding -ComponentID ms_tcpip6
$interfaceName = @('Ethernet')

$interfaceName.foreach({Disable-NetAdapterBinding -Name $_ -ComponentID ms_tcpip6})
```