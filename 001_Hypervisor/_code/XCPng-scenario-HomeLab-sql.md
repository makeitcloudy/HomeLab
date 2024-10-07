# SQL

## SQL Server

### Windows - Server OS - 2x SQL Server - Desktop Experience

Node (Server) used to test the DSC code for Active Directory Domain Setup - Desktop Experience

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'b2_sql01' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-vlan1342' --Mac '12:B2:13:42:02:08' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_sql01_SQL2019'

/opt/scripts/vm_create_uefi.sh --VmName 'b2_sql02' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-vlan1342' --Mac '12:B2:13:42:02:09' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_sql02_SQL2019'

```

Once VM's are ready, hit yes for the autodiscovery, pick No for the PV restart.


```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='b2_sql01'
xe vm-cd-insert vm='b2_sql01' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='b2_sql02'
xe vm-cd-insert vm='b2_sql02' cd-name='Citrix_Hypervisor_821_tools.iso'

```

Run in the elevated powershell session (VM).

* [run_InitialSetup.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/_blogPost/windows-preparation/run_initialSetup.ps1), when asked, put the *sql01* and *sql02* for the second VM
* VM should reboot now

The step mentioned above is described in the [https://makeitcloudy.pl/windows-preparation/](https://makeitcloudy.pl/windows-preparation/) blog post, paragraph 2.0.2.

Eject VMTools installation media. Run bash code (XCP-ng terminal over SSH)

```bash
xe vm-cd-eject vm='b2_sql01'
xe vm-cd-eject vm='b2_sql02'

```

Add extra disk for the database storage

```bash
/opt/scripts/vm_add_disk.sh --vmName 'b2_sql01' --storageName 'node4_ssd_sdd' --diskName 'b2_sql01_Sdrive' --deviceId 5 --diskGB 30  --description 'Sdrive_SQLDBdrive'
/opt/scripts/vm_add_disk.sh --vmName 'b2_sql02' --storageName 'node4_ssd_sde' --diskName 'b2_sql02_Sdrive' --deviceId 5 --diskGB 30  --description 'Sdrive_SQLDBdrive'

```

**Note:**

```code
# in case the disk is added or substracted, such modification should be adjusted in ConfigureNode.ps1
# ConfigureNode.ps1 - has the DSC configuration which initialize disks
# it bases on ConfigData.psd1 for the drive letter, label, format etc

# 0. https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/windows-DSC/run_initialConfigDsc_domain.ps1
# 0. https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/windows-DSC/run_initialConfigDsc_workgroup.ps1

# _domain.ps1 or _workgroup.ps1, initiates

# 1. https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc.ps1

# InitialConfigDsc.ps1, initiates

# 2. https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigureNode.ps1
# 2. https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigData.psd1

# it contains DSC script and configuration, for the initial configuration of the node
```

Run DSC configuration - for the initial setup.  
Details are described in the [https://makeitcloudy.pl/windows-DSC/](https://makeitcloudy.pl/windows-DSC/) blog post, paragraph 2.2.  
SQL server should be domain joined, so the -DomainName parameter is passed.  
It 

```
$domainName = 'lab.local'  #FIXME
Set-InitialConfigDsc -NewComputerName $env:computername -Option Domain -DomainName $domainName -Verbose

```

It:

* sets the disk structure
* set the static IP address
* join the VM to the domain

**Note:**

```
# Set-InitialConfigDsc function is part of the AutomatedLab,
# https://github.com/makeitcloudy/AutomatedLab

# it launches 
# https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc.ps1
# which triggers
# https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration\ConfigureNode.ps1
# which gets configuration data from 
# https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration\ConfigData.psd1
```


Mount SQL Server 2019 installation media

```bash
xe vm-cd-eject vm='b2_sql01'
xe vm-cd-insert vm='b2_sql01' cd-name='SQLServer2019-x64-ENU.iso'
xe vm-cd-eject vm='b2_sql02'
xe vm-cd-insert vm='b2_sql02' cd-name='SQLServer2019-x64-ENU.iso'

```

It is assumed that mamanagement tools are installed on the mgmt node.

Proceed with the SQL installation

```powershell

```


**TODO:** https://makeitcloudy.pl/windows-DSC/ paragraph 2.2 - the computername is already set, though still should be passed as a parameter into script, never the less not needed anymore to put it manually, grab it as an environmental variable / Check if that paramater is needed at all.

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
/opt/scripts/vm_create_uefi.sh --VmName 'b2_sql01' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-vlan1342' --Mac '12:B2:13:42:02:08' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_sql01_SQL2019_core'

/opt/scripts/vm_create_uefi.sh --VmName 'b2_sql02' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'eth1-vlan1342' --Mac '12:B2:13:42:02:09' --StorageName 'node4_ssd_sdg' --VmDescription 'w2k22_sql02_SQL2019_core'

```