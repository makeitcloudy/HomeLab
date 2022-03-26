# XenServer SDK

**1.** Get the XCP-ng or XenServer installed on one of your nodes.<br>
https://github.com/citrix/xenserver-sdk/blob/master/docs/index.md<br>
https://developer-docs.citrix.com/projects/citrix-hypervisor-sdk/en/latest/<br>

**2.** Once downloaded into your management node (in case it is windows based) extract zip file<br>
```
  $env:USERPROFILE\Documents\WindowsPowerShell\Modules
  $env:PROGRAMFILES\WindowsPowerShell\Modules
  $env:SystemRoot\system32\WindowsPowerShell\v1.0\Modules
```
**3.** Import the Module
```
  Import-Module XenServerPSModule
```
# XenPLModule

**4.** Copy the XenPLModule into the same location as the one mentioned for XenServerPSModule
```
  Import-Module XenPLModule
```
**5.** List the commands available within the XenPLModule
```
  Get-Command -Module XenPLModule
```
**6.** Start using the commands
  - enumerate the iso available on your iso storage
  - enumerte vm details like network IP and MAC, vcpu, storage etc
  - create the VM skeletons, bios, uefi, uefi secure boot, equipped with disks and dvd drives
  - add extra disk
  - start, reboot, shutdown vms
  - take a snapshot
  - scrap the vms

**7.** It allows you creating the VM from scratch without touching the xcp-ng Center / XEN Console GUI
**8.** Combined with an iso prepared as per SeguraOSD section, one will end up with unattended installation of running OS'es for your lab scenario.

Examples and video available soon.
