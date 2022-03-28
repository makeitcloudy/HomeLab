# XenServer SDK

**0.** Get the XCP-ng or XenServer installed on one of your nodes.

**1.** Download the XenServer SDK<br>
https://github.com/citrix/xenserver-sdk/blob/master/docs/index.md<br>
https://developer-docs.citrix.com/projects/citrix-hypervisor-sdk/en/latest/<br>

**2.** Once downloaded into your management node (in case it is windows based) extract zip file
```
  $env:USERPROFILE\Documents\WindowsPowerShell\Modules
  $env:PROGRAMFILES\WindowsPowerShell\Modules
  $env:SystemRoot\system32\WindowsPowerShell\v1.0\Modules
```
**3.** Import the Module<br>
```
  Import-Module XenServerPSModule
```
# XenPLModule

**4.** Copy the XenPLModule into the same location as the one mentioned for XenServerPSModule<br>
```
  Import-Module XenPLModule
```
Module wraps the XenServerPSModule with a bunch of functions which brings the functionality towards VM's provisioning

**5.** List the commands available within the XenPLModule<br>
```
  Get-Command -Module XenPLModule
```
**6.** Start using the commandlets<br>
  - enumerate the iso available on your iso storage
  - enumerte vm details like network IP and MAC, vcpu, storage etc
  - create the VM skeletons, bios, uefi, uefi secure boot, equipped with disks and dvd drives
  - add extra disk
  - start, reboot, shutdown vms
  - take a snapshot
  - scrap the vms

**7.** It allows you creating the VM from scratch without touching the xcp-ng Center / XEN Console GUI<br>
**8.** Combined with an iso prepared as per SeguraOSD section, one will end up with unattended installation of running OS'es for your lab scenario.<br>

Examples and video available soon.
