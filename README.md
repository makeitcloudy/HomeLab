# AutomatedCitrix

Some could say CVAD (Citrix Virtual Apps and Desktops), never the less I will stick with the first string from the product name only, as you'll neve know when the current name become the relict of the past. Where the word Citrix is still with us since 20y.

Okay so you decided to spend some time with this product, but you do not want spend too much of your precious time with setting up the vm's at first place..
1. Think of the hypervisor vendor, you'll bring into your lab. Your option may be xcp-ng (https://xcp-ng.org/). It's free, it's based on Xen. Surely you may consider Azure, but at the time of writing this, nested virtualization for the giant's world where we are with citrix is not very well suited with Azure Labs. If you count the cost of storage and compute, it may not be that cheap overall, especially if you spend time doing things manually. It seems that your first hard stop may be with the space on the storage. That's why for fresh home labbers I'm still opting for energy efficient solution which is based on-premise. In my opinion clouds are towards contenerization and webservices which scales far better than virtual machine based scenarios.
2. Consider 10G network connectivity for your storage, then the provisioning should be much faster. Unless you got it virtualized already, and you dont' have to take care about this aspect.
3. Consider splitting your regular network for the VM traffic, that you end up with different possible scenarios for deployment (especially if you are interested with ending up with more than one site), and some specific use cases.
4. Think about the PKI infrastructure, then you can get some hands on experience with FAS (Federated Authentication Services), TLS 1.x - and you'll gain some hands on experience with openSSL, and you can take the benefit of that piece for the regular RDS (Remote Desktop Infrastructure).
5. Check the internet against the possibility of spinnig up Remote Desktop Services Session Hosts, with the regular PVS (Citrix Provisioning Services) infrastructure. Please check the licensing constrains, which will help you assessing which version of the PVS you may be utilizing for the usecase. There are/were some differences..
6. Consider the Freemium version of the Citrix Netscaler (Citrix ADC), starting version 13.0 of the product, the freemium version equals with the features previous standard releases, so it should at least give you the possibilities to get some hands on experience with SSL offloading, Load Balancing, Context switching, and some other interesting things, without a chance to set the Gateway for your CVAD infrastructure... Let's see what the 2022 bring for home labbers as Citrix is promissing some improvements in that area, and some special licenses / options.
7. Consider preparing the unattended iso's for the Server and Desktop OS'es - it will help you spinning up new vm's.
8. Consider automating the deployment of the core elements which are the backbone of your VM infrastructure, like AD, GPO's, certificates and other stuff which will come into play, especially when in disposal of 180days keys. Time is passing by fast, especially when you try to keep up in balance. Stil IaC (Infrastructure as a Code) which is your goal, requires a lot of work, and it does not often scales well, but stil better than manual clicks.

(1) Xcp-ng is based on RedHat, like regular XenServer is. In case you are still using windows desktop as your management station, there is an option called (https://github.com/xcp-ng/xenadmin/releases). Bare in mind that there are no toos available for windows VM which runs on top of xcp-ng, but in case you are so fortunate and have a mycitrix account, there is an option for you, to get rid of that issue, unless this is prevented. Apart from that if you decide to stick with the original stack, and you won't mix vmware, nutanix, or hyper-v with CVAD's, then you can take the benefit from the Citrix Hypervisor SDK (available in PowerShell) which will allow you automating the provisioning of the VM's, so you don't have to click within the XenCenter / XenAdmin Centre. The Xen API does not belong to the easiest one, especially if you decide to perform something a bit more complicated. Thankfully there are github projects like ALX wchich may help you constructing your own functions which are hopefully idempotent.

(2) If you decide to go with physical route for your network infrastructure, there are great second hand product available, like aruba switches (10G switches ethernet based) and not yet that cheap in 2021. I'm not a big fan of having plenty of different vendors which compose your infrastructure, as it causes life even more interesting, so maybe it is a good idea to stick with mikrotik products with their series of CRS-3XX. With RouterOS which give you possibility to manage via winbox or ssh, those can act as L2 on the bridge level if you configure vlans, and only the logical interface of the device itself, which allows you managing it will reside in L3. The configuration from ground zero is a bit tricky for w newbe, never the less the overall performance for the price is not too bad for a home lab. On top of your switching network you'll still need a router, may be virtualized on a stick or again some physical hardware. In case your architecture require much of bandwidth being routed between vlans then CCR (Cloud Core) series for the rescue. In case it is not, then VyOs or pfSense should be enough.

(4) SQL is brain of your CVAD infrastructure, automating (https://ali-ahmed-jdawms.medium.com/how-to-perform-sql-server-2019-developer-edition-unattended-silent-installation-354f6341dfc7). For Citrix you'll need SQL Standard or more in case Alwasy On cluster is taken into account.

(5) There is a great book from Freek Berson (https://github.com/fberson) and Claudio Rodrigues - RDS - The Complete Guide: Everything you need to know about RDS. And more. - (https://www.amazon.com/RDS-Complete-Guide-Everything-about-ebook/dp/B07C6849WD/ref=sr_1_1?ie=UTF8&qid=1525462416&sr=8-1&keywords=rds+complete+guide). Installation of the RDS was also automated with AutomatedRDS and some other projects in the internet. On top of that the configuration piece is left for you. Configuring the windows 10 for the SSO (Single Sing On) experience on top of RDS, will make you busy. As it was said, you may let the cogel mogel begins, by provisioning the RDSH (Remote Session Hosts) by PVS (Citrix Provisioning Services) which is not a bad idea, especially for RDS infrastructures which have plenty of Collections.

(6) With Fremium you'll gain some hands on experience with the Citrix ADC which is FreeBSD based. Even if you give up with CVAD, at least you may have some interesting time with certificates, perform a lot of binding, and HTTP/HTTPS protocol itself.

(7) Unattended file, if this is home lab, you'll find plenty of examples in the internet with the GVLK keys (https://docs.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys), please do not follow them. If you decide constructing your xml answer file, leave this parameter blank, and focus on updating the .wim file with OSD from Mr. Segura (https://osdupdate.osdeploy.com/) - who brought this fantastic product which will save your time and make your life easier.
*** OSBuilder: https://osbuilder.osdeploy.com/docs/untitled-3/task-naming


Once you download the image of your LTSC windows release, it will contain Standard and Datacenter versions, in Core (no GUI - Graphical User Interface in windows) and Desktop Experience (GUI which you got used to during all the years). The sources can be downloaded from the Microsoft webpage (https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019), the downloaded iso will contain the .wim file. If you decide to use another ways, like Windows Media Creation Tool, then you'll end up with the iso or other format, which contain .esd file instead of .wim file. Up to my knowledge, you'll have to convert it to .wim if you'd like to make use of it in Windows ADK. ADK goes hand in hand with releases of windows, there is different verison of ADK for 2022, 2019, 2012R2 etc. ADK details can be found here (https://docs.microsoft.com/pl-pl/windows-hardware/get-started/what-s-new-in-kits-and-tools).<br>
In case you consider downloading a bunch of windows releases there is an interesting project (https://github.com/AveYo/MediaCreationTool.bat) - it should save you some struggle and time.

A bit of powershell will give you the possibility to remove the versions of the OS release you are not going to use in your lab. Please consider Core, your skills and OS understanding will raise, and you'll gain a better understanding how does the system work.<br>
Few elements in your citrix home lab may be based on core editions of the windows servers. If I'm not mistaken it is advised to put your PKI on servers with Desktop Based experience, but elements like your domain controllers, citrix license servers may run on core. You may be tempted to use Windows Admin Center - it has great marketing, but still left much to be desired, so please follow the route of combining old and still good mmc's along with Server Manager, anlong with RSAT tools, which may reside on your management machine. The machine may be desktop based.<br>

Good starting point for the automated answer file is this link: (https://www.windowscentral.com/how-create-unattended-media-do-automated-installation-windows-10), it will help you creating the correct structure, and give you some bit of understanding, how does those windows popping up during the installation, reflects the xml structure. UEFI needs 4 partitions, BIOS boot 2.<br>
This blog is also great help (https://taylor.dev/how-to-create-an-automated-install-for-windows-server-2019/)

Once the VM's are installed, if you search for particular KB or Cummulative update, like the one for .NET those can be found here (https://www.catalog.update.microsoft.com/Search.aspx?q=windows%20Server%202016%20framework)

(8) Depending from the scenario, there are solutions which are worse and better match. Powershell for the rescue in MS world, that's for sure, still some products like MEM (Microsoft Endpoint Manager) may help you managint Microsoft Endpoints, MDT (Microsoft Deployment Toolkit) or modules brought by the communities within the PowerShell Gallery itself. First you need to find them, and get a bit of hands on experience, as not all of them are very well documented, never the less again in some cases getting them to know, will pay you off with some time savings.<br>
Atomizing actions within your scripts is your way to go, do not put to much of features into one function / script, as it make your life harder. It's easier to say than do, but it will come with the pitfals made during your attempts. Let those objects created within your code be passed in the pipeline, and be consumed by another tool which fits the purpose.<br>
Starting from scratch will cost you a great amount of effort, so take the benefit of community work and great guys which shares with us their knowledge and efforts produced very often in nights, and dozen of attempts to make it work. Frequently, what they share is extra work, brought to us apart from their regular full time jobs.<br>
It may be hard to start directly from IaC (Infrastructure as Code), but there are products like Hydration Kits (https://www.deploymentresearch.com/hydration-kit-for-windows-server-2019-sql-server-2017-and-configmgr-current-branch/) along with some customizations like (https://github.com/JM2K69/HydrationKit).
If you prefer staying the purist, then your option is DSC (Desired State Configuration), there are plenty of modules available behind a bit of a learning curve. It's worth spending some time with it, as it brings idempotency, it scales quite well and once you get handy with it your lab, it can be consumed in Azure.<br><br>
** AD - Ask the Directory Services Team ** (https://docs.microsoft.com/en-us/archive/blogs/askds/configuring-an-authoritative-time-server-with-group-policy-using-wmi-filtering)
** Carl Webster Active Directory Presentations ** - (https://carlwebster.com/category/conference-presentations/)<br>
** Trond advises for building hybrid scenarios ** - (https://xenappblog.com/2021/building-hybrid-cloud-on-nutanix-community-edition/)<br>
** WVD (Windows Virtual Desktop) - AIB | (Azure Image Builder) vs Packer ** - (https://www.youtube.com/channel/UCjUtHlDsAIasXffpiORfwUA) and (https://github.com/JimMoyle/YouTube-WVD-Image-Deployment)<br>

