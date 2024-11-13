# ADCS - dev

## Active Directory Certificate Services

### Windows - Server OS - 1x ADCS Root - DesktopExperience | 1x ADCS Sub - Core

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'd_b2_adcsR' --VCpu 4 --CoresPerSocket 2 --MemoryGB 4 --DiskGB 40 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'dev-B2-vlan1542' --Mac '1A:B2:15:42:02:03' --StorageName 'node4_ssd_sdf' --VmDescription 'w2k22_adcsR_ADCS_RootCA'

/opt/scripts/vm_create_uefi.sh --VmName 'd_b2_adcsS' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'dev-B2-vlan1542' --Mac '1A:B2:15:42:02:04' --StorageName 'node4_ssd_sdb' --VmDescription 'w2k22_adcsS_ADCS_IssuingCA'

```

### Windows - Server OS - 1x Web Server - Core

```bash
/opt/scripts/vm_create_uefi.sh --VmName 'd_b2_adcsWS' --VCpu 4 --CoresPerSocket 2 --MemoryGB 2 --DiskGB 32 --ActivationExpiration 180 --TemplateName 'Windows Server 2022 (64-bit)' --IsoName 'w2k22dtc_2302_core_untd_nprmpt_uefi.iso' --IsoSRName 'node4_nfs' --NetworkName 'dev-B2-vlan1542' --Mac '1A:B2:15:42:02:05' --StorageName 'node4_ssd_sdb' --VmDescription 'w2k22_adcsR_ADCS_WebEnrollment'
```

Once the OS is installed, execute the code to mount the VMTools

```bash
# it will work - provided there is only one iso on SR with such name
xe vm-cd-eject vm='d_b2_adcsWS'
xe vm-cd-insert vm='d_b2_adcsWS' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='d_b2_adcsR'
xe vm-cd-insert vm='d_b2_adcsR' cd-name='Citrix_Hypervisor_821_tools.iso'

xe vm-cd-eject vm='d_b2_adcsS'
xe vm-cd-insert vm='d_b2_adcsS' cd-name='Citrix_Hypervisor_821_tools.iso'

```

The IP reservation on the DHCP server in the subnet are done, otherwise login to the VM via XCP-ng console (no clipboard available) and get the IP address. Connect to the machine via RDP.
**Note:** Machine should have access to the internet to grab the content from github.  

Then follow up with (initial configuration - VMTools installation script, which also rename the machine and reboots it)

### ADCS - Initial Configuration - adcsR, adcsS, adcsWS

On adcsr, adcss, adcsws - run 
* [run_initialSetup.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/README.md#run_initialsetupps1) - details about the code are described in the blog post [windows-preparation](https://makeitcloudy.pl/windows-preparation/) - paragraph 2.0.2

Proceed with the code

* adcsR - is a root CA - do not add it to the domain
* adcsS - is subCA - add it to the domain
* adcsWS - is Web Enrollment - add it to the domain

```powershell
https://makeitcloudy.pl/windows-DSC/
# proceed with the code from paragraph 2.2
# the code available in that paragraph runs the Set-InitialConfigDsc function which triggers the the code 
https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc.ps1
# config data are grabbed from here
# for the domain scenario to work properly the DNS should be configured properly (DomainDnsServers)
# and goes hand in hand with the IP addresses of the domain controllers 
https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigData.psd1

$domainName = 'd.local'  #FIXME
Set-InitialConfigDevDsc -NewComputerName $env:computername -Option Domain -DomainName $domainName -Verbose
```

### ADCS - Initial Configuration - adcsR

```powershell
#once done run following code
Set-InitialConfigDevDsc -NewComputerName $env:ComputerName -Option Workgroup -Verbose
```

### ADCS - Initial Configuration - adcsS, adcsWS

```powershell
#once done run following code
$domainName = 'd.local'  #FIXME
Set-InitialConfigDevDsc -NewComputerName $env:ComputerName -Option Domain -DomainName $domainName -Verbose
```

### ADCS - Eject vmTools media

```bash
xe vm-cd-eject vm='d_b2_adcsWS'
xe vm-cd-eject vm='d_b2_adcsR'
xe vm-cd-eject vm='d_b2_adcsS'

```