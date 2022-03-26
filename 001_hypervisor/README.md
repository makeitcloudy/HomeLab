#XenServer SDK

**1.** Get the XCP-ng or XenServer installed on one of your nodes.<br>
https://github.com/citrix/xenserver-sdk/blob/master/docs/index.md<br>
https://developer-docs.citrix.com/projects/citrix-hypervisor-sdk/en/latest/<br>

**2.** Once downloaded into your management node (in case it is windows based) extract zip file<br>

  $env:USERPROFILE\Documents\WindowsPowerShell\Modules<br>
  $env:PROGRAMFILES\WindowsPowerShell\Modules<br>
  $env:SystemRoot\system32\WindowsPowerShell\v1.0\Modules<br>

**3.** Import the Module

  Import-Module XenServerPSModule
