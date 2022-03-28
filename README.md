*the idea behind this project is to help new commers, as well as people who consider the way of automating deployment of the microsoft stack within their labs. it's one man effort, who is trying to glue together the community shares comming from other EUC members in one place. As of 2022.03 the initiative is still ongoing, there could be bugs, but still there is plenty of usefull code which can be used for anyone who is keen on learning.*<br><br>
# AutomatedCitrix

Some could say CVAD (Citrix Virtual Apps and Desktops), never the less I will stick with the first string from the product name only, as you'll never know when the current name become the relict of the past. Where the word Citrix is still with us since 20y.<br>

Okay so you decided to spend some time with this product, but you do not want spend too much of your precious time with setting up the vm's at first place..
You may ask, where to start, well the knowledge is scattered over the internet, it's just perfectly schattered into pieces, there are few well known places which tries to accomodate the most important details in one place, one of them is Carl Stalhood (https://www.carlstalhood.com/), he rocks. It all goes with experience, but still the best way to learn something is to give it a spin and at least try and fail, without giving up.<br>

Below are areas which should be taken into account, along with my attempt to give some insight to those of you who may be seeking for those type of details, and are curious about the possibilities. It does not gather are possibilities, as each scenario and homelab is different and there are so many possibilities that here I'm basing on my own experience.<br>

**001.** Think of the hypervisor vendor, you'll bring into your lab. Your option may be xcp-ng (https://xcp-ng.org/). It's free, it's based on Xen. There is also Hyper-V Server 2019 LTSC (Long-Term Servicing Channel) also a good bet especially if one tend to stay in Microsoft Stack (according to some revelations this is the last free version of this product which is supported until 2029, so there is some time to evaluate Azure Stack HCI. Another option is might be Azure, but at the time of writing this, nested virtualization for the giant's world where we are with citrix is not very well suited with Azure Labs. If you count the cost of storage and compute, it may not be that cheap overall, especially if you spend time doing things manually. It seems that your first hard stop may be with the space on the storage. That's why for fresh home labbers I'm still opting for energy efficient solution (Intel Nuc or some new releases of Xeons) which is based on-premise. In my opinion clouds are towards contenerization and webservices which scales far better than virtual machine based scenarios.<br>
**002.** Consider 10G network connectivity for your storage, then the provisioning should be much faster. Unless you got it virtualized already, and you dont' have to take care about this aspect.<br>
**003.** Consider splitting your regular network for the VM traffic, that you end up with different possible scenarios for deployment (especially if you are interested with ending up with more than one site), and some specific use cases.<br>
**004.** Think about the PKI infrastructure, then you can get some hands on experience with FAS (Federated Authentication Services), TLS 1.x - and you'll gain some hands on experience with openSSL, and you can take the benefit of that piece for the regular RDS (Remote Desktop Infrastructure).<br>
**005.** Spin up Remote Desktop Services Session Hosts, with the regular PVS (Citrix Provisioning Services) infrastructure (https://citrixguyblog.com/2021/10/07/citrix-pvs-deploy-microsoft-remote-desktop-session-hosts-with-citrix-provisioning-services/). Please check the licensing constrains, which will help you assessing which version of the PVS you may be utilizing for the usecase. There are/were some differences..<br>
**006.** Consider the Freemium version of the Citrix Netscaler (Citrix ADC), starting version 13.0 of the product, the freemium version equals with the features previous standard releases, so it should at least give you the possibilities to get some hands on experience with SSL offloading, Load Balancing, Context switching, and some other interesting things, without a chance to set the Gateway for your CVAD infrastructure (https://docs.citrix.com/en-us/citrix-adc/13/deploying-vpx/deploy-vpx-faq.html#hypervisor). Let's see what the 2022 bring for home labbers as Citrix is promissing some improvements in that area, and some special licenses / options. Again you may remain with Citrix stack, unless decided that pfsense is your way to go, or another mixture of components.<br>
**007.** Consider preparing the unattended iso's for the Server and Desktop OS'es - it will help you spinning up new vm's.<br>
**008.** Consider automating the deployment of the core elements which are the backbone of your VM infrastructure, like AD, GPO's, certificates and other stuff which will come into play, especially when in disposal of 180days evaluation products. Time is passing by fast, especially when you try to keep up in balance. Stil IaC (Infrastructure as a Code) which is your goal, requires a lot of work, and it does not often scales well, but stil better than manual clicks.<br>
**009.** If you think about going hybrid for the WVD (Windows Virtual Desktop) usecase, bare in mind Azure Ephemeral Disks.<br>
**010.** Applications - There is AppLayering from citrix, never the less let's be fair, I have not seen a vendor who is doing all the things right and have the best possible solutions to spin up the environment, especially considering such amount of usecases, and different angles. It has been said, if you decide to go with AppLayering then you should cover all your apps. The question is how much effort will that cost you comparing to other solutions available on the market like App-v or SCCM/MEM or rewriting those to be served as web apps. It's hard to suggest anything here, but bare in mind the binary methodology here 1 or 0. The worse thing you can do for yourself is to bring different ways of provisioning for your applicaiton layer. Keep it simple, and tend to use solutions which lasts.<br>
**011.** In case it is not enough, there is a possibility for the GPU Virtualization, there are some geeks on the internet who perform this with regular Nvidia GTX cards, since Nvidia released drivers for GeForce GPU Passthrough for Windows Virtual Machine (Beta) (https://nvidia.custhelp.com/app/answers/detail/a_id/5173/~/geforce-gpu-passthrough-for-windows-virtual-machine-%28beta%29) it's a bit easier. If you think of going Tesla or Quaddro way you'll need extra licenses from nvidia.<br><br>

**(001)** Xcp-ng is based on RedHat, like regular XenServer is. In case you are still using windows desktop as your management station, there is an option called (https://github.com/xcp-ng/xenadmin/releases). Bare in mind that there are no toos available for windows VM which runs on top of xcp-ng, but in case you are so fortunate and have a mycitrix account, there is an option for you, to get rid of that issue, unless this is prevented. Apart from that if you decide to stick with the original stack, and you won't mix vmware, nutanix, or hyper-v with CVAD's, then you can take the benefit from the Citrix Hypervisor SDK (available in PowerShell) which will allow you automating the provisioning of the VM's, so you don't have to click within the XenCenter / XenAdmin Centre. The Xen API does not belong to the easiest one, especially if you decide to perform something a bit more complicated. Thankfully there are github projects like AXL wchich may help you constructing your own functions which are hopefully idempotent.<br>
+ https://github.com/ZachThurmond/Automated-XenServer-Labs - AXL github repo
+ https://www.criticaldesign.net/post/automating-lab-builds-with-xenserver-powershell-part-1-understanding-the-requirements - AXL documentation 1 (there is something wrong with indexing and when you try to navigate over the menu on their webpage it is showing error 404, but those links should poiny your correctly)<br>
+ https://www.criticaldesign.net/post/automating-lab-builds-with-xenserver-powershell-part-2-creating-a-custom-iso - AXL documentation part 2<br>
+ https://www.criticaldesign.net/post/automating-lab-builds-with-xenserver-powershell-part-3-unlimited-vm-creation - AXL documentation part 3<br>
+ https://www.criticaldesign.net/post/automating-lab-buildouts-with-xenserver-powershell-part-4-roles-features-and-other-components - AXL documentation part 4<br>

**(002)** If you decide to go with physical route for your network infrastructure, there are great second hand product available, like aruba switches (10G switches ethernet based) and not yet that cheap in 2021. In short distances, DAC (Direct Attach Coooper) would be better choice, than going with transceivers and using light. Mellanox Connect cards may support you, those are still easily recognizable by linux and windows (at least in 2021), another option is Chelsio, the 110-1159-40 is easily recognizable by Freenas. I'm not a big fan of having plenty of different vendors which compose your infrastructure, as it causes life even more interesting, so maybe it is a good idea to stick with mikrotik products with their series of CRS-3XX. With RouterOS which give you possibility to manage via winbox or ssh, those can act as L2 on the bridge level if you configure vlans, and only the logical interface of the device itself, which allows you managing it will reside in L3. The configuration from ground zero is a bit tricky for w newbe, never the less the overall performance for the price is not too bad for a home lab. On top of your switching network you'll still need a router, may be virtualized on a stick or again some physical hardware. In case your architecture require much of bandwidth being routed between vlans then CCR (Cloud Core) series for the rescue. In case it is not, then VyOs or pfSense should be enough.<br>

**(003)** Your network topology can helping you emulate different sites, instead of keeping each element in the same broadcast domain. It will also help you setting up the firewall or observe what type of traffic is being spread from particular elements of your infrastructure. Similar can be achieved with Wireshark or uberAgent  directly on the VM's, but it seems that proper network topology with VLAN's will help you anyway. In case Mikrotik is your choice, there is great channel on youtube called *The Network Berg*, who offers Free MCTNA course, covering the content which will be sufficient to setup the network infrastructure for your homelab, and more (https://www.youtube.com/watch?v=a_XTHHPXbuk&list=PLJ7SGFemsLl3XQhO8g0hHCrKnC6J3KURk).<br>

**(004)** SQL is brain of your CVAD infrastructure, automating (https://ali-ahmed-jdawms.medium.com/how-to-perform-sql-server-2019-developer-edition-unattended-silent-installation-354f6341dfc7). For Citrix you'll need SQL Standard or more in case Alwasy On cluster is taken into account.<br>

**(005)** There is a great book from Freek Berson (https://github.com/fberson) and Claudio Rodrigues - RDS - The Complete Guide: Everything you need to know about RDS. And more. - (https://www.amazon.com/RDS-Complete-Guide-Everything-about-ebook/dp/B07C6849WD/ref=sr_1_1?ie=UTF8&qid=1525462416&sr=8-1&keywords=rds+complete+guide). Installation of the RDS was also automated with AutomatedRDS and some other projects in the internet. On top of that the configuration piece is left for you. Configuring the windows 10 for the SSO (Single Sing On) experience on top of RDS, will make you busy. As it was said, you may let the cogel mogel begins, by provisioning the RDSH (Remote Session Hosts) by PVS (Citrix Provisioning Services) which is not a bad idea, especially for RDS infrastructures which have plenty of Collections (https://citrixguyblog.com/2021/10/07/citrix-pvs-deploy-microsoft-remote-desktop-session-hosts-with-citrix-provisioning-services/).<br>
Apart from that there is a great resource for the FMA (Flexcast Management Architecture) offered for free which is a fruit of all the efforts but into it by Bas van Kaam (https://www.basvankaam.com/2016/12/15/the-citrix-xenapp-xendesktop-fma-services-complete-overview-new-7-12-services-included/), available here (https://www.basvankaam.com/wp-content/uploads/2019/03/Inside-Citrix-The-FlexCast-Management-Architecture.pdf). Big Kudos!<br>

**(006)** With Fremium you'll gain some hands on experience with the Citrix ADC which is FreeBSD based. Even if you give up with CVAD, at least you may have some interesting time with certificates, perform a lot of binding, and HTTP/HTTPS protocol itself.<br>

**(007)** Unattended file, if this is home lab, you'll find plenty of examples in the internet with the GVLK keys (https://docs.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys), please do not follow them. If you decide constructing your xml answer file, leave this parameter blank, and focus on updating the .wim file with OSD from Mr. Segura (https://osdupdate.osdeploy.com/) - who brought this fantastic product which will save your time and make your life easier.<br>
*** OSBuilder *** - (https://osbuilder.osdeploy.com/docs)<br>

Once you download the image of your LTSC windows release, it will contain Standard and Datacenter versions, in Core (no GUI - Graphical User Interface in windows) and Desktop Experience (GUI which you got used to during all the years). The sources can be downloaded from the Microsoft webpage (https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019), the downloaded iso will contain the .wim file. If you decide to use another ways, like Windows Media Creation Tool, then you'll end up with the iso or other format, which contain .esd file instead of .wim file. Up to my knowledge, you'll have to convert it to .wim if you'd like to make use of it in Windows ADK. ADK goes hand in hand with releases of windows, there is different verison of ADK for 2022, 2019, 2012R2 etc. ADK details can be found here (https://docs.microsoft.com/pl-pl/windows-hardware/get-started/what-s-new-in-kits-and-tools).<br>
+ https://www.technig.com/install-adk-mdt-in-windows-server-2016/<br>
In case you consider downloading a bunch of windows releases there is an interesting project (https://github.com/AveYo/MediaCreationTool.bat) - it should save you some struggle and time.<br>

A bit of powershell will give you the possibility to remove from the wim file, the versions of the OS release you are not going to use in your lab. Please consider Core, your skills and OS understanding will raise, and you'll gain a better understanding how does the system work.<br>
Few elements in your citrix home lab may be based on core editions of the windows servers. If I'm not mistaken it is advised to put your PKI on servers with Desktop Based experience, but elements like your domain controllers, citrix license servers may run on core. You may be tempted to use Windows Admin Center - it has great marketing, but still left much to be desired, so please follow the route of combining old and still good mmc's along with Server Manager and RSAT tools, which may reside on your management machine. The machine may be desktop based.<br>

Good starting point for the automated answer file is this link: (https://www.windowscentral.com/how-create-unattended-media-do-automated-installation-windows-10), it will help you creating the correct structure, and give you some bit of understanding, how does those windows popping up during the installation, reflects the xml structure. UEFI needs 4 partitions, BIOS boot 2. There are two approaches, you can follow the path of templates on the hypervisor level, or the automated installation of a regular machine without any customizations and on top of that execute a bit of DSC (Desired State Configuration), choice is yours. My preference is second option as then you are not tight to the hypervisor and it is a bit easier at the end, even though it cost you more work at the beggining.
As of the unattended xml creation, this blog is also great help (https://taylor.dev/how-to-create-an-automated-install-for-windows-server-2019/)<br>

Once the VM's are installed, if you search for particular KB or Cummulative update, like the one for .NET those can be found here (https://www.catalog.update.microsoft.com/Search.aspx?q=windows%20Server%202016%20framework)<br><br>

**(008)** Depending from the scenario, there are solutions which are worse and better match. Powershell for the rescue in MS world, that's for sure, still some products like MEM (Microsoft Endpoint Manager) may help you managint Microsoft Endpoints, MDT (Microsoft Deployment Toolkit) or modules brought by the communities within the PowerShell Gallery itself. First you need to find them, and get a bit of hands on experience, as not all of them are very well documented, never the less again in some cases getting them to know, will pay you off with some time savings.<br>
Atomizing actions within your scripts is your way to go, do not put to much of features into one function / script, as it make your life harder. It's easier to say than do, but it will come with the pitfals made during your attempts. Let those objects created within your code be passed in the pipeline, and be consumed by another tool which fits the purpose.<br>
Starting from scratch will cost you a great amount of effort, so take the benefit of community work and great guys which shares with us their knowledge and efforts produced very often in nights, and dozen of attempts to make it work. Frequently, what they share is extra work, brought to us apart from their regular full time jobs.<br>
It may be hard to start directly from IaC (Infrastructure as Code), but there are products like Hydration Kits (https://www.deploymentresearch.com/hydration-kit-for-windows-server-2019-sql-server-2017-and-configmgr-current-branch/) along with some customizations like (https://github.com/JM2K69/HydrationKit).
If you prefer staying the purist, then your option is DSC, there are plenty of modules available behind a bit of a learning curve. It's worth spending some time with it, as it brings idempotency, it scales quite well and once you get handy with it your lab, it can be consumed in Azure.<br><br>

**(009)** When you consider Hybrid scenario and falling apart from regular love shared with CVAD by getting closer to WVD, get a bit familiar with storage solutions on Azure with the Azure Ephemeral Disks - (https://getnerdio.com/academy/azure-ephemeral-os-disks-what-are-they-and-how-do-they-benefit-msps/). Nerdio should also ring the bell, there are great guys behind the scenes. Freek Berson shines here again with his bicep, which will make your life easier with ARM templates (https://github.com/Azure/bicep).<br>
Clouds changes rapidly, you'll get far better experience cooperating with them when you strive towards IaaC, than GUI.<br>

**(010)** Actually besides trying EverGreen in your lab, along with appMasking from FSlogix, I do not have very much to say about that layer in context of lab.<br><br>
**(011)** There is a great book which will explain the GPU virtualization topic written by Jan Hendrik Meier - GPU Powered VDI (https://www.amazon.com/GPU-powered-VDI-Virtual-Desktops/dp/1983043311), and interesting blogpost series available one (https://www.poppelgaard.com/blog).<br><br>

** AD / AD - Ask the Directory Services Team ** - (https://docs.microsoft.com/en-us/archive/blogs/askds/configuring-an-authoritative-time-server-with-group-policy-using-wmi-filtering)<br>
** AD / Carl Webster Active Directory Presentations ** - (https://carlwebster.com/category/conference-presentations/)<br>
** AD / GPO Automation ** - (https://jm2k69.github.io/2020/02/GPO-from-zero-to-hero-GPO-and-PowerShell.html)<br>
** AD / GPO Automation ** - (https://carlwebster.com/creating-a-group-policy-using-microsoft-powershell-to-configure-the-authoritative-time-server/)
** AD / GPO ** - (https://admx.help) | (https://pspeditor.azurewebsites.net/)<br>
** AD / GPO Troubleshooting ** - (https://evotec.xyz/the-only-command-you-will-ever-need-to-understand-and-fix-your-group-policies-gpo/)<br>
** Image Preparation ** - BIS-F (https://eucweb.com/download-bis-f | https://github.com/EUCweb/BIS-F) - big thank you to Mathias and all guys who brought this to life <br>
** Image Preparation ** - Evergreen (https://github.com/Deyda/Evergreen-Script | https://github.com/aaronparker/Evergreen)<br>
** Logon Optimization ** - (https://james-rankin.com/features/the-ultimate-guide-to-windows-logon-time-optimizations-part-11/)<br>
** Profiles ** - (https://github.com/FSLogix) | UPD | massive products like Ivanti | Roaming Mandatory Profiles<br>
** Applications ** - FsLogix AppMasking - thank you Benny Tritsch (https://www.youtube.com/watch?v=vCtnhTsdAaQ)
** OS Layer / Uber Agent ** - (https://uberagent.com/download/) - Helge Klein - (https://helgeklein.com/) shares great insights, worth following him <br><br>
** WMI/CIM is your friend ** - (https://0xinfection.github.io/posts/wmi-basics-part-1/)<br>

** RDS ** - RDS-O-Matic, along with all links provided on this webpage (https://www.rdsgurus.com/scripts/) - @crod - thank you for presenting this to the world!<br>
** RDS ** - (https://mehic.se/category/remote-desktop-services-2016/) - great series which is nice supplement for the RDS book mentioned before<br>

** PVS vs Pester ** - (https://www.youtube.com/watch?v=3xOHpiKEpn8) - Synergy 2017 #SYN306 - this is a perfect example how the building blocks can be glued together, to help you out<br>

**Product documentation**<br>
+ Citrix Github - https://github.com/citrix<br>
+ Citrix Developer - (https://developer.cloud.com/ | https://developer.citrix.com)<br>
+ The DSC community - https://github.com/dsccommunity - plenty of interesting modules which release from reinventing things from scratch<br>
+ Powershell gallery - https://www.powershellgallery.com/<br>
+ Technet gallery - https://docs.microsoft.com/en-us/samples/browse/?redirectedfrom=TechNet-Gallery<br>
+ XCP-ng documentation - https://xcp-ng.org/docs/<br><br>
** *Citrix Tech Zone* ** - (https://docs.citrix.com/en-us/tech-zone/build/deployment-guides/windows-10-deployment.html?utm_content=buffere2e95&utm_medium=social%2520media%2520-%2520organic&utm_source=twitter&utm_campaign=CVAD)<br>
** *Citrix Supportability pack* ** - (https://support.citrix.com/article/CTX203082)<br>
** *Citrix Optimizer* ** - (https://support.citrix.com/article/CTX224676)<br>

**Books**<br>
+ https://www.basvankaam.com/wp-content/uploads/2019/03/Inside-Citrix-The-FlexCast-Management-Architecture.pdf<br>
+ https://www.amazon.com/RDS-Complete-Guide-Everything-about-ebook/dp/B07C6849WD/ref=sr_1_1?ie=UTF8&qid=1525462416&sr=8-1&keywords=rds+complete+guide<br>
+ https://www.manning.com/books/learn-sql-server-administration-in-a-month-of-lunches *a bit of sql knowledge is helpfull for citrix guy*<br>
+ https://www.manning.com/books/learn-windows-iis-in-a-month-of-lunches *worth to grasp some details about iis, turns out to be helpful from time to time*<br>
+ https://www.manning.com/books/learn-powershell-in-a-month-of-lunches?query=powershell%20in%20month *month of launches series*<br>
+ https://www.manning.com/books/learn-powershell-scripting-in-a-month-of-lunches?query=powershell%20in%20month *month of launches series*<br>
+ https://leanpub.com/the-dsc-book<br>
+ https://leanpub.com/pesterbook<br>
+ https://leanpub.com/thebigbookofpowershellerrorhandling<br>
+ https://leanpub.com/powershell101<br>
+ https://leanpub.com/azurebicep<br>
+ https://www.amazon.com/Byte-Sized-design-principles-architectural-recommendations/dp/1797692100<br>

**Supportive channels which can help you gaining structuralized content**<br>
+ https://www.pluralsight.com/ along with their full time author and evangelist Greg Shields and his great courses - he will share a virtual hand and equip you with brilliant tips, helping you going through the installations and configurations of your virtual estate. Extremely patient guy, who is not scared of repeating the same things and topics as many times until your subscription expires.<br>
+ https://www.youtube.com/ - search for the sesoins of Cláudio Rodrigues, in youtube you'll have to follow his name with BriForum suffix, otherwise you'll be shown with non relevant materials, time is passing by fast, but in context of EUC this guy had and has very much to say - referencing video from 2012 (https://www.youtube.com/watch?v=msK6n7049ig). It's a pity he is no longer a regular EUC contractor, as it was very interesting to read his opinions comming from the field. This session from 10y ago is really good even though it is almost an extinct spieces ;). <br>
+ https://www.youtube.com/user/briforum - BriForum sessions may be a great foreground for a newcomer, there is dozens of details shared by EUC (End User Computing) engaged colleagues, which can help laying down some foreground for the newer knowledge. Bare in mind that the products by itself didn't changed that much. It's rather the Access Layer which is evolving by prism of Authorization, Authentication and Zero Trust.<br>
+ https://github.com/yt-dlp/yt-dlp - this will support your youtube activities<br><br>

**Places which will help you a lot, but a bit more scattered**<br>
+ https://www.reddit.com/r/Citrix/<br>
+ https://stackoverflow.com/<br>
+ https://serverfault.com/<br><br>

**Podcast**<br>
+ https://www.eucdigest.com/episodes/<br>
+ https://cloudskills.fm/<br>
+ https://runasradio.com/<br>

**Conferences**<br>
+ https://www.youtube.com/c/PowerShellConferenceEU - PowerShell source, apart from that search for Jeffrey Snover presentations, they way he describes things is straightforward and intelligeble, which proofs his well understanding of the topic ;)<br>
+ https://xenappblog.com/agenda/ - virtual expo - it is taking place two times in a year - it is a great initiative which was invented by Trond Haaverstein, with fabolous speakers and presentations<br>
+ https://cloudcamp.ie/<br><br>

**Community shares - lab approaches**<br>
* Carl Webster Lab - (https://carlwebster.com/building-websters-lab-v2/)<br>
* Nicolas Ignoto - (https://www.citrixguru.com/category/lab/)<br>
* https://mybrokencomputer.net/t/setup-a-citrix-home-lab-in-sixty-minutes/28<br><br>

**Community shares**<br>
* World of EUC slack - (https://t.co/EVrMXepANH)<br>
* World of EUC discord - (https://t.co/zE0QTpANZQ)<br>
* EUC weekly digest - (https://www.carlstalhood.com/category/euc-weekly-digest/)<br>
* MyCugc with all the webinars recoreded - (https://www.mycugc.org/events/webinars)<br>
* There is an interesting mission behind the scenes - (https://www.go-euc.com/)<br>
Two Carl's - let's list them alphabetically: Carl Webster and Carl Stalhood<br>
* Building Carl Webster lab - (https://carlwebster.com/01-building-websters-lab-v2-introduction/ | https://carlwebster.com/building-websters-lab-v2-pdf/) - his guide contains 1335 pages. Imagine how much of an errort was made to bring this to life. It's available for free...<br>
* Carl Stalhood - (https://www.carlstalhood.com/about-carl-stalhood/) - great resources and fair amount of links to different places which may help you getting up to speed, and solving many of the issues which may arise. It will also help installing the product itslef.<br>
* Bas van Kaam - (https://www.basvankaam.com/) - he is one of the Nerdio evangelist, who shared great green book called the FMA Architecture.<br>
* Denis Span - (https://dennisspan.com/) - he was my inspiration for some automation topics around PVS etc. His blog is full of examples how the installation of the components building CVAD can be automated. You may customize those scripts for your preference, for instance including the Error and Verbose streams, they are great starting point.<br>
* Julien Mooren - (https://citrixguyblog.com | https://github.com/citrixguyblog) - he was my inspiration to fork his AutomatedRDS release back in 2017.<br>
* Manuel Winkel - (https://www.deyda.net/index.php/en/<br>
* Claudio Rodriguez - (http://blog.wtslabs.com/), apart from that there were RAS university initiative (http://ras.euc.university/) - but for some reason this is no longer active<br>
* MsFreaks - (https://msfreaks.wordpress.com/)<br>
* Freek Berson - (https://github.com/fberson | http://microsoftplatform.blogspot.com/) - his blog post are great to lay down the foreground for Citrix which is nothing else than RDS (Remote Desktop Services), it seems to be good idea to start with Terminal Services and RDS which help structualize knowledge needed for a Citrix guy<br>
* Kristin Griffin - (https://www.rdsgurus.com/author/grokker99/) - her contribution in RDS area seems to be not that well known, but still she brought added value value to the EUC community<br>
* Esther Barthel - (https://github.com/cognitionit) - if you are interested in REST API, Nitro for Citrix ADC and topics around automation, she is the one to follow<br>
* Guy Leech - (https://twitter.com/guyrleech) - there is no better place to be inspired in powershell area ;)<br>
* James Ranklin - (https://james-rankin.com/) - amazing content is produced by James, no doubts<br>
* James Kindon - (https://github.com/JamesKindon | https://jkindon.com/)<br>
* Daniel Fehler - (https://virtualfeller.com/)<br>
* Johannes Norz - (https://norz.at/blog | https://www.wonderkitchen.tech/) - here you can benefit for your Citrix ADC skilset<br>
* Trond Eirik Haavarstein - (https://xenappblog.com/)<br>
* John Billekens - (https://blog.j81.nl/)<br>
* Marco Zimmermann - (http://marcozimmermann.com/)<br>
* Matthias Schlimm - (https://eucweb.com/)<br>
* Dennis Mohrmann - (https://github.com/Mohrpheus78/)<br>
* René Bigler - (https://dreadysblog.com/)<br>
* George Spiers - (https://www.jgspiers.com/) - his blog will help you getting handy with NetScaler and topics on your OS layer<br>
* Lee Jeffries - (https://www.leeejeffries.com/blog/)<br>
* Ravikanth C - (https://github.com/rchaganti) - in context of DSC, great source, if I'm not mistaken he had authored one of the DSC books available<br>

Many of abovementioned EUC experts, links on their blogs to great tools which help you with your daily work, and reveal knowledge, which you'll never get on the trainings guarateed by the vendor, exposing their experience from the field. There are many more, please forgive me I can not enumerate them all here. Depending from the area, many are CTP's or MVP's, but there are also grey eminence personas who share valuable information.<br>

**.**<br>
+ https://feedly.com/ - RSS agregator<br>
+ https://freedns.afraid.org/subdomain/ - fantastic freeDNS service<br>
+ https://www.cloudflare.com/ - can bring great improvement for your web services<br>

**tools**
+ ShareX - (https://getsharex.com/) - will help you with screen capture, and producing GIF's for your webpage (thank you Josh Duffney! - https://duffney.io/)<br>
+ CIM/WMI Explorer - (https://www.sapien.com/software/cimexplorer | https://www.ks-soft.net/hostmon.eng/wmi/index.htm)<br>
+ Chocolatey - (https://chocolatey.org/ | https://github.com/chocolatey/choco)<br>
+ Ninite - (https://ninite.com/) - Install and Update your apps at once<br>
+ BoxStarter - (https://boxstarter.org/)<br>
+ WizTree - (https://diskanalyzer.com/) - TreeSize alternative, which is just faster<br>
+ Glaswire - (https://www.glasswire.com/)<br>
+ Shut up 10 - (https://www.oo-software.com/en/shutup10)<br>

It's impossible to list all names of great people who produce the valuable content and link it in one place, never the less it is a good starting point. The question which remains is the order to lay this down, constructively in memory. Apart from that each of us has it's topics which attacts him or her more than other and it is the Team who builds the Virtual Workplace solutions, not the lonesome wariors or stars.<br>
Keep calm and do puzzles (https://www.redbubble.com/shop/jackson+pollock+jigsaw-puzzles).<br><br>

**Hybrid / Azure**<br>
** Why should you become Azure certified - (https://www.thomasmaurer.ch/2019/08/why-you-should-become-microsoft-azure-certified/)<br>
** Hybrid / Trond advises for building hybrid scenarios - (https://xenappblog.com/2021/building-hybrid-cloud-on-nutanix-community-edition/)<br>
** Cloud / WVD (Windows Virtual Desktop) - AIB | (Azure Image Builder) vs Packer - (https://www.youtube.com/channel/UCjUtHlDsAIasXffpiORfwUA) and (https://github.com/JimMoyle/YouTube-WVD-Image-Deployment)<br>
** Cloud / WVD - Travis Roberts has his course on Udemy - VWD from zero to hero, as well as on youtube - (https://www.youtube.com/playlist?list=PLnWpsLZNgHzXMtKjaQJf4Rn64W86nUDv1)<br>
** Cloud / Azure - Thomas Maurer study guides:<br>
+ 2022 Azure study guide - (https://www.thomasmaurer.ch/2022/01/how-to-learn-microsoft-azure-in-2022/)<br>
this should be a sufficient amount of knowledge to be prepared for studying to AZ-140<br>
+ AZ-900 - (https://www.thomasmaurer.ch/2020/03/az-900-study-guide-microsoft-azure-fundamentals-2021/)<br>
+ AZ-900 - (https://microsoftlearning.github.io/AZ-900T0x-MicrosoftAzureFundamentals/)<br>
+ AZ-104 - (https://www.thomasmaurer.ch/2020/03/az-104-study-guide-azure-administrator/)<br>
+ AZ-104 - (https://microsoftlearning.github.io/AZ-104-MicrosoftAzureAdministrator/)<br>
* onboard to Azure - https://github.com/johnthebrit/CertificationMaterials<br>
* Azure trainings by John Savil - (https://www.youtube.com/c/NTFAQGuy/playlists)<br>
* Azure Virtual Desktop by Travis Roberts - (https://www.youtube.com/c/TravisRoberts/playlists | https://www.youtube.com/watch?v=V8PjtCTTT6c&list=PLnWpsLZNgHzXMtKjaQJf4Rn64W86nUDv1)<br>
