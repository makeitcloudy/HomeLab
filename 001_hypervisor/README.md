# XenServer SDK

Get the XCP-ng or XenServer installed on one of your nodes.<br>
https://github.com/citrix/xenserver-sdk/blob/master/docs/index.md<br>
https://developer-docs.citrix.com/projects/citrix-hypervisor-sdk/en/latest/<br>

Once downloaded into your management node (in case it is windows based) extract zip file<br>
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

Copy the XenPLModule into the same location as the one mentioned for XenServerPSModule
