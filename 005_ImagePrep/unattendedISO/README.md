# Unattended

## Links

#unattended xml files for the LTSC iso's which can be downloaded from the microsoft webpage

* [OSDBuilder howto](https://github.com/ibeerens/osdbuilder)
* [Rufus - Increase time showing "Press any key to boot from USB" to e.g. 30 seconds](https://github.com/pbatard/rufus/issues/1077)
* [offline servicing Windows Server 2012R2](https://serverfault.com/questions/979174/how-can-i-do-an-offline-update-of-a-new-windows-2012-r2-server)
* https://citrixguyblog.com/2019/03/19/osdbuilder-reference-image-on-steroids/
* [unattended xml bios and uefi for windows 10](https://github.com/larytet/auto-win/tree/master/autounattend)
* [PVS Admin Toolkit](https://github.com/Mohrpheus78/Citrix/tree/main/PVS%20Admin%20Toolkit)
* [MSIX packaging](https://flexxible.com/automating-msix-packaging-with-powershell/)

## .

+ KMS key <Product Key> need to go hand in hand with the version of the Windows (https://learn.microsoft.com/en-us/windows/release-health/release-information)

+ worth to configure the unatended file this way that for your destkop OS which follows the modern management idea, and acts as a authoring machine for your DSC configurations, preconfigure it this way that there is user which can be used to login via RDP to the newly provisioned machine, it will benefit especially when your lab is in remote location (over VPN).
+ the overall performance and end user experience in case you manipulate over the GUI is much better when the RDP is in use than the VNC. RDP is not a preffered way, it can be easily disabled anytime, never the less it may bring benefit in case you'd like to run sconfig, over the VPN wire, using the built in VNC within the xcpn-ng.
+ in case you do not have a code in hand, and need to prepare something within the GUI, use regular mstsc instead of the console view built into the xen / xcp-ng - within local area network, you won't see much of difference, never the less perspective gonna change in remote usecase scenario
