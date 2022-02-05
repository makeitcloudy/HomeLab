**#Unattended.xml**<br>
+ worth to configure the unatended file this way that for your destkop OS which follows the modern management idea, and acts as a authoring machine for your DSC configurations, preconfigure it this way that there is user which can be used to login via RDP to the newly provisioned machine, it will benefit especially when your lab is in remote location (over VPN).<br>
+ the overall performance and end user experience in case you manipulate over the GUI is much better when the RDP is in use than the VNC. RDP is not a preffered way, it can be easily disabled anytime, never the less it may bring benefit in case you'd like to run sconfig, over the VPN wire, using the built in VNC within the xcpn-ng.<br>
+ in case you do not have a code in hand, and need to prepare something within the GUI, use regular mstsc instead of the console view built into the xen / xcp-ng - within local area network, you won't see much of difference, never the less perspective gonna change in remote usecase scenario<br><br>

**#Pvs**<br>
+ https://www.carlstalhood.com/pvs-master-device-preparation/<br>
