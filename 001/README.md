#Hypervisor Layer<br><br>

**disclaimer** - *in majority the code available within those sections won't be idempotent and won't stop you from causing damage on your existing configuration, never the less it will greatly reduce the amount of clicks, during the time when machines will be recreated*.<br><br>

Citrix Hypervisor formely XenServer is redhat based. There is free distribution called CentOS, having much in common with redhat, if you get some skills with it, it will help you with transition, in case this turns out to be your way. XenServer is closed so you won't install any packages on top of it, xcp-ng will allow you doing it. Xen's xe api is in use to interact with the hypervisor, or querrying details, for the management apart from the API available products are: XenCenter, Admin Center (xcp-ng), XOA (xcp-ng).<br>
Citrix ADC formely Netscaler is FreeBSD based. There is great online documentation for BSD, never the less on top of that there is logic produced by Citrix who bought this product if I'm not mistaken in 2005 from some skilled guy, who introduced the NetScaler engine. BSD knowledge may help you anyway, never the less there are quirks comming from Citrix ADC, it stands with binding, you will bind a lot of objects to make it work.<br>

It will be beneficial to get a bit of storage knowledge about lvm (logical volume manager), zfs (zettabyte file system) in case you plan to setup your own NAS (Network Attached Storage) for the homelab. In case you decide to stick with Microsoft world, Storage Spaces may become your friend (for this you'll need the DataCenter edition of the operating system if I'm not mixing things).<br>

Choice is yours as it goes for the hypervisor vendor. You may go nutanix way (smart way ;)), vmware (which is probably the most popular in the enterprises), hyper-v (here you have the free option Hyper-v Server, which can be managed remotelly with RSAT (Remote Server Administration Tools) or Windows Admin Center, or pure powershell / DSC). Bare in mind that if you decide to spend some time with MCS, you'll need SCVMM (System Centre Virtual Machine Manager), as there is no other way known to me, for the pure Hyper-V to consume the MCS API, like it is for other vendors mentioned above. There is also Proxmox, or KVM, but it seems there is no direct integration with Citrix for those. Those are great but the target and it's usecases is different.<br>

Another option is to go with Vmware Player or Vmware Workstation, you can construct quite a nice lab with it, but if you decide setting it up on a laptop, your limiting factor may first become the storage. Again no MCS as those products can not consume the commands send from Citrix to spin up machines.<br>

As it goes for the automation, there is XenServer SDK available, which also talks with XCP-ng. If you spin a lot of machines on Vmware Workstation, there is Vmxtoolkit (https://github.com/bottkars/vmxtoolkit), which may help you getting released from a need of clicking through the GUI to bring the skeleton for the VM, or mounting the iso's and other things. It is really usefull.<br>
The integration between Hyper-V and DSC is great, there is a bit of learning curve but it pays off once you setup your little framework.<br>

**Hypervisor automation**<br><br>
+ https://github.com/ZachThurmond/Automated-XenServer-Labs - AXL github repo<br><br>
+ https://www.criticaldesign.net/post/automating-lab-builds-with-xenserver-powershell-part-1-understanding-the-requirements<br>
+ https://www.criticaldesign.net/post/automating-lab-builds-with-xenserver-powershell-part-2-creating-a-custom-iso<br>
+ https://www.criticaldesign.net/post/automating-lab-builds-with-xenserver-powershell-part-3-unlimited-vm-creation<br>
+ https://www.criticaldesign.net/post/automating-lab-buildouts-with-xenserver-powershell-part-4-roles-features-and-other-components<br><br>
+ https://github.com/santiagocardenas/xenserver-powershell-scripts/blob/master/Set-XenServerVMResources.ps1<br>


**#Compute Layer**<br><br>
Try sticking with Intel when you go bare metal with type 1 virtualization. AMD will be okay in case you go type 2.<br>
**CPU** - There are plenty of xeon's which will suffice, especially the L series, will be friendly by prism of energy getting utilized.<br> Within the bios settings of your motherboard try using the Energy Efficient option, it will slow down your CPU, and limir the power draw significantly. With regular Citrix labbing you won't see that much difference which is worth paying more for energy. Newer xeon series are more energy efficient, but those also cost more. From time to time there are great deals and bargains, keep your eyes opened ;).<br>
If you go with type 2, then the settings on the windows 10 for the choosen power plan overwrites what you have set on the motherboard, so you can construct your own plan.<br> 
**RAM** - the more the better, there are interesting extended atx mobo's which have 12 or 24 slots for RAM, unless you can afford modules with great density, and stick with 4 or 8 slots. Speed does not differs that much, for regular labbing it will be hard to see the difference between 1333 and 1866, at least I had not noticed much.<br>
**Storage** - keep the balance between spinning drives HDD and SSD's. Invest in RAID, and reliable disks, unless you reached the IaC (Infrastructure as Code) level and you treat VM's like cattle not pets. HHD will be helpfull for the scenarios where you generate a lot of traffic, and you repeat that excercise due to some inconvenience which holds you back. SSD's and NVME's, will save your time, when you work on gold images or similar topics.<br>
Storage tiering is your friend, be generous for this layer.<br>
**Cooling** - try to arange it this way that it is quiet and reliable. You may invent your own way of cooling the system down, remember about dust filters, but here only imagination can stop you, unless your preference is to buy something from the market.<br>

Inspirations can be found here:<br>
+ https://www.servethehome.com/ - invaluable amount of helpful content<br>
+ https://www.youtube.com/watch?v=q-jKs62b6Co - Lawrence Systems shares great tips and tricks, those guys shares material of great quality in topics like pfsense, freenas, etc<br>
+ https://www.reddit.com/r/homelab/ - remember that each usecase is different<br>

**#Installation of XenTools**<br><br>
**Linux**<br>
+ XenServer 8.2 tools from Citrix does not recognize the Centos Stream 8 properly, never the less executing it this way do the trick [install.sh -d centos -m 8]<br>
+ Xcp-ng 8.2 tools does not have this issue<br>
+ in case you use linux operating systems for your core services within the lab - use the Xcp-ng tools, the installation is straightforward (https://xen-orchestra.com/blog/install-xenserver-tools-in-your-vm/)<br>

**Windows**<br>
+ XenServer 8.2 tools integrates well with Desktop and Server operating systems<br>
+ based on my experience at least two restarts are needed, then the hypervisor recognizes that all components of the tools are in place<br>
