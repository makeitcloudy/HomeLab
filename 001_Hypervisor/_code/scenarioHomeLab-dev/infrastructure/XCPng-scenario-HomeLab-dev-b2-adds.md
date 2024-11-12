# ADDS - dev

## Active Directory Domain Services

### Windows - Server OS - ADDS - 2x Domain Controller - Server Core

```bash
# First domain controller - server core
/opt/scripts/vm_create_uefi.sh --VmName 'd_b2_dc01' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'dev-B2-vlan1542' --Mac '1A:B2:15:42:02:01' --StorageName 'node4_ssd_sdd' --VmDescription 'w2k22_dc01_ADDS_core'

# Second domain controller - server core
/opt/scripts/vm_create_uefi.sh --VmName 'd_b2_dc02' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'dev-B2-vlan1542' --Mac '1A:B2:15:42:02:02' --StorageName 'node4_ssd_sde' --VmDescription 'w2k22_dc02_ADDS_core'

# mount vmTools
xe vm-cd-eject vm='d_b2_dc01'
xe vm-cd-insert vm='d_b2_dc01' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='d_b2_dc02'
xe vm-cd-insert vm='d_b2_dc02' cd-name='Citrix_Hypervisor_821_tools.iso'

```

### Windows - Server OS - ADDS - Initial Configuration after Installation

```powershell
https://makeitcloudy.pl/windows-preparation/
# proceed with the code from paragraph 2.0.2 it leads to

https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/README.md#run_initialsetupps1
# 1. run the code from the section #run_initialsetup.ps1
# 2. vmtools are getting installed, along with few other configuration caveats, then you are asked for the new name of the node
# 3. machine restarts
# 4. proceed with installing updates -> sconfig -> 6 -> 1
# 5. once the patches are installed, proceed with setting up the ADDS role installation

```

### Windows - Server OS - ADDS - Eject VMTools

```bash
xe vm-cd-eject vm='d_b2_dc01'
xe vm-cd-eject vm='d_b2_dc02'
```

### Windows - Server OS - ADDS - Role Setup

```powershell

### take the snapshot of the VM (dc01, dc02)
# then follow up with paragraph 1.1.3 -> run_ADDS.ps1
https://makeitcloudy.pl/windows-role-active-directory/

# run the code on DC01 from, then once finished run the code on DC02
https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/README.md#run_adds-devps1

# run the configuration on DC02 - once the DC01 is available again after the reboot
# even if the the group policy client can take up some time (5min) - it stucks on the LogonUI.exe process for the logon to the machine
# the DSC configuration on DC02 can be run in parallel and the replication takes place properly

# again follow up with the steps described here: https://makeitcloudy.pl/windows-role-active-directory/ 15paragraph 1.1.3, run code:
https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/README.md#run_adds-devps1

# what does the code above do ?
# it executes: https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory-dev_demo.ps1
# which launches: https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory/ADDS-dev_setup.ps1

# at this point the code change the IP address from the DHCP pool reservation to static IP
# which is outside of the scope from the pool - the configuration is hardcoded among the configuration
# data available in the ADDS_setup.ps1 file

# the DSC configuration is available in this file, configurationData is in ADDS_setup.ps1
https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory/ADDS_configuration.ps1
```

### Windows - Server OS - ADDS - Structure and configuration

#### run_adds-dev_initialConfig.ps1

```powershell
# https://makeitcloudy.pl/windows-role-active-directory/
# continue with paragraph 1.1.5 - Initial Configuration - ADDS
# it leads to run_adds_initialconfig.ps1
# https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/README.md#run_adds_initialconfigps1

# it launches the domain is setup by running the file _ad_carlWebster_structure.ps1
https://raw.githubusercontent.com/makeitcloudy/HomeLab/refs/heads/feature/007_DesiredStateConfiguration/_blogPost/windows-role-active-directory/run_adds-dev_initialConfig.ps1
# everything apart from the Site configuration
# as of 2024.08.07 - still some users / groups needs fixes
# though this will be rewritten to the DSC configuration at some point anyway
```

#### run_adds_structure.ps1

```powershell
# https://makeitcloudy.pl/windows-role-active-directory/
# continue with paragraph 1.1.6 - Initial Logical Structure - ADDS
# https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/README.md#run_adds_structureps1

# it leads to run_adds_structure.ps1
# https://raw.githubusercontent.com/makeitcloudy/HomeLab/refs/heads/feature/007_DesiredStateConfiguration/_blogPost/windows-role-active-directory/run_adds_structure.ps1
```