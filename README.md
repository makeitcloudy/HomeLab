*the idea behind this project is to help new commers, as well as people who consider the way of automating deployment of the microsoft stack within their labs. it's one man effort. As of 2024.07 the initiative is still ongoing. It's educational purposes in home lab. Automation included in the surrounding modules are meant to save time. There are great alternative projects like Lability, LabBuilder, PS-AutoLab-Env, etc, this one is based on XCP-ng.*

# HomeLab - XCP-ng, Linux, Microsoft stack, Citrix, Remote Desktop Services, Hybrid Scenarios

Some could say CVAD (Citrix Virtual Apps and Desktops), never the less I will stick with the first string from the product name only, as you'll never know when the current name become the relict of the past. Where the word Citrix is still with us since 20y.


## Links

**(001)** Xcp-ng is based on RedHat, like regular XenServer is. In case you are still using windows desktop as your management station, there is an option called (https://github.com/xcp-ng/xenadmin/releases). Bare in mind that there are no toos available for windows VM which runs on top of xcp-ng, but in case you are so fortunate and have a mycitrix account, there is an option for you, to get rid of that issue, unless this is prevented. Apart from that if you decide to stick with the original stack, and you won't mix vmware, nutanix, or hyper-v with CVAD's, then you can take the benefit from the Citrix Hypervisor SDK (available in PowerShell) which will allow you automating the provisioning of the VM's, so you don't have to click within the XenCenter / XenAdmin Centre. The Xen API does not belong to the easiest one, especially if you decide to perform something a bit more complicated. Thankfully there are github projects like AXL wchich may make it easier to construct your own functions which are hopefully idempotent.

* https://github.com/ZachThurmond/Automated-XenServer-Labs - AXL github repo
* https://www.criticaldesign.net/post/automating-lab-builds-with-xenserver-powershell-part-1-understanding-the-requirements - AXL documentation 1 (there is something wrong with indexing and when you try to navigate over the menu on their webpage it is showing error 404, but those links should poiny your correctly)
* https://www.criticaldesign.net/post/automating-lab-builds-with-xenserver-powershell-part-2-creating-a-custom-iso - AXL documentation part 2
+ https://www.criticaldesign.net/post/automating-lab-builds-with-xenserver-powershell-part-3-unlimited-vm-creation - AXL documentation part 3
+ https://www.criticaldesign.net/post/automating-lab-buildouts-with-xenserver-powershell-part-4-roles-features-and-other-components - AXL documentation part 4

**(002)** If you decide to go with physical route for your network infrastructure, there are great second hand product available, like aruba switches (10G switches ethernet based) and not yet that cheap in 2021. In short distances, DAC (Direct Attach Coooper) would be better choice, than going with transceivers and using light. Mellanox Connect cards may support you, those are still easily recognizable by linux and windows (at least in 2021), another option is Chelsio, the 110-1159-40 is easily recognizable by Freenas. I'm not a big fan of having plenty of different vendors which compose your infrastructure, as it causes life even more interesting, so maybe it is a good idea to stick with mikrotik products with their series of CRS-3XX. With RouterOS which give you possibility to manage via winbox or ssh, those can act as L2 on the bridge level if you configure vlans, and only the logical interface of the device itself, which allows you managing it will reside in L3. The configuration from ground zero is a bit tricky for w newbe, never the less the overall performance for the price is not too bad for a home lab. On top of your switching network you'll still need a router, may be virtualized on a stick or again some physical hardware. In case your architecture require much of bandwidth being routed between vlans then CCR (Cloud Core) series for the rescue. In case it is not, then VyOs or pfSense should be enough.

**(003)** Your network topology can allow you emulate different sites, instead of keeping each element in the same broadcast domain. It will also help you setting up the firewall or observe what type of traffic is being spread from particular elements of your infrastructure. Similar can be achieved with Wireshark or uberAgent  directly on the VM's, but it seems that proper network topology with VLAN's will be usefull you anyway. In case Mikrotik is your choice, there is great channel on youtube called *The Network Berg*, who offers Free MCTNA course, covering the content which will be sufficient to setup the network infrastructure for your homelab, and more (https://www.youtube.com/watch?v=a_XTHHPXbuk&list=PLJ7SGFemsLl3XQhO8g0hHCrKnC6J3KURk).

**(004)** SQL is brain of your CVAD infrastructure, automating (https://ali-ahmed-jdawms.medium.com/how-to-perform-sql-server-2019-developer-edition-unattended-silent-installation-354f6341dfc7). For Citrix you'll need SQL Standard or more in case Alwasy On cluster is taken into account.

**(005)** There is a great book from Freek Berson (https://github.com/fberson) and Claudio Rodrigues - RDS - The Complete Guide: Everything you need to know about RDS. And more. - (https://www.amazon.com/RDS-Complete-Guide-Everything-about-ebook/dp/B07C6849WD/ref=sr_1_1?ie=UTF8&qid=1525462416&sr=8-1&keywords=rds+complete+guide). Installation of the RDS was also automated with AutomatedRDS and some other projects in the internet. On top of that the configuration piece is left for you. Configuring the windows 10 for the SSO (Single Sing On) experience on top of RDS, will make you busy. As it was said, you may let the cogel mogel begins, by provisioning the RDSH (Remote Session Hosts) by PVS (Citrix Provisioning Services) which is not a bad idea, especially for RDS infrastructures which have plenty of Collections (https://citrixguyblog.com/2021/10/07/citrix-pvs-deploy-microsoft-remote-desktop-session-hosts-with-citrix-provisioning-services/).

Apart from that there is a great resource for the FMA (Flexcast Management Architecture) offered for free which is a fruit of all the efforts but into it by Bas van Kaam (https://www.basvankaam.com/2016/12/15/the-citrix-xenapp-xendesktop-fma-services-complete-overview-new-7-12-services-included/), available here (https://www.basvankaam.com/wp-content/uploads/2019/03/Inside-Citrix-The-FlexCast-Management-Architecture.pdf). Big Kudos!

**(006)** With Fremium you'll gain some hands on experience with the Citrix ADC which is FreeBSD based. Even if you give up with CVAD, at least you may have some interesting time with certificates, perform a lot of binding, and HTTP/HTTPS protocol itself.

**(007)** Unattended file, if this is home lab, you'll find plenty of examples in the internet with the GVLK keys (https://docs.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys), please do not follow them. If you decide constructing your xml answer file, leave this parameter blank, and focus on updating the .wim file with OSD from Mr. Segura (https://osdupdate.osdeploy.com/) - who brought this fantastic product which will save your time and make your life easier.

**OSBuilder** - (https://osbuilder.osdeploy.com/docs)

Once you download the image of your LTSC windows release, it will contain Standard and Datacenter versions, in Core (no GUI - Graphical User Interface in windows) and Desktop Experience (GUI which you got used to during all the years). The sources can be downloaded from the Microsoft webpage (https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019), the downloaded iso will contain the .wim file. If you decide to use another ways, like Windows Media Creation Tool, then you'll end up with the iso or other format, which contain .esd file instead of .wim file. Up to my knowledge, you'll have to convert it to .wim if you'd like to make use of it in Windows ADK. ADK goes hand in hand with releases of windows, there is different verison of ADK for 2022, 2019, 2012R2 etc. ADK details can be found here (https://docs.microsoft.com/pl-pl/windows-hardware/get-started/what-s-new-in-kits-and-tools).

* https://www.technig.com/install-adk-mdt-in-windows-server-2016/
In case you consider downloading a bunch of windows releases there is an interesting project (https://github.com/AveYo/MediaCreationTool.bat) - it should save you some struggle and time.

A bit of powershell will give you the possibility to remove from the wim file, the versions of the OS release you are not going to use in your lab. Please consider Core, your skills and OS understanding will raise, and you'll gain a better understanding how does the system work.
Few elements in your citrix home lab may be based on core editions of the windows servers. If I'm not mistaken it is advised to put your PKI on servers with Desktop Based experience, but elements like your domain controllers, citrix license servers may run on core. You may be tempted to use Windows Admin Center - it has great marketing, but still left much to be desired, so please follow the route of combining old and still good mmc's along with Server Manager and RSAT tools, which may reside on your management machine. The machine may be desktop based.

Good starting point for the automated answer file is this link: (https://www.windowscentral.com/how-create-unattended-media-do-automated-installation-windows-10), it will guarantee the creation of the correct structure, and give you some bit of understanding, how does those windows popping up during the installation, reflects the xml structure. UEFI needs 4 partitions, BIOS boot 2. There are two approaches, you can follow the path of templates on the hypervisor level, or the automated installation of a regular machine without any customizations and on top of that execute a bit of DSC (Desired State Configuration), choice is yours. My preference is second option as then you are not tight to the hypervisor and it is a bit easier at the end, even though it cost you more work at the beggining.

As of the unattended xml creation, this blog is also worth reading (https://taylor.dev/how-to-create-an-automated-install-for-windows-server-2019/)

Once the VM's are installed, if you search for particular KB or Cummulative update, like the one for .NET those can be found here (https://www.catalog.update.microsoft.com/Search.aspx?q=windows%20Server%202016%20framework)

**(008)** Depending from the scenario, there are solutions which are worse and better match. Powershell for the rescue in MS world, that's for sure, still some products like MEM (Microsoft Endpoint Manager) may make it easier you to manage Microsoft Endpoints, MDT (Microsoft Deployment Toolkit) or modules brought by the communities within the PowerShell Gallery itself. First you need to find them, and get a bit of hands on experience, as not all of them are very well documented, never the less again in some cases getting them to know, will pay you off with some time savings.

Atomizing actions within your scripts is your way to go, do not put to much of features into one function / script, as it make your life harder. It's easier to say than do, but it will come with the pitfals made during your attempts. Let those objects created within your code be passed in the pipeline, and be consumed by another tool which fits the purpose.

Starting from scratch will cost you a great amount of effort, so take the benefit of community work and great guys which shares with us their knowledge and efforts produced very often in nights, and dozen of attempts to make it work. Frequently, what they share is extra work, brought to us apart from their regular full time jobs.

It may be hard to start directly from IaC (Infrastructure as Code), but there are products like Hydration Kits (https://www.deploymentresearch.com/hydration-kit-for-windows-server-2019-sql-server-2017-and-configmgr-current-branch/) along with some customizations like (https://github.com/JM2K69/HydrationKit).
If you prefer staying the purist, then your option is DSC, there are plenty of modules available behind a bit of a learning curve. It's worth spending some time with it, as it brings idempotency, it scales quite well and once you get handy with it your lab, it can be consumed in Azure.

**(009)** When you consider Hybrid scenario and falling apart from regular love shared with CVAD by getting closer to WVD, get a bit familiar with storage solutions on Azure with the Azure Ephemeral Disks - (https://getnerdio.com/academy/azure-ephemeral-os-disks-what-are-they-and-how-do-they-benefit-msps/). Nerdio should also ring the bell, there are great guys behind the scenes. Freek Berson shines here again with his bicep, which will make your life easier with ARM templates (https://github.com/Azure/bicep).

Clouds changes rapidly, you'll get far better experience cooperating with them when you strive towards IaaC, than GUI.

**(010)** Actually besides trying EverGreen in your lab, along with appMasking from FSlogix, I do not have very much to say about that layer in context of lab.

**(011)** There is a great book which will explain the GPU virtualization topic written by Jan Hendrik Meier - GPU Powered VDI (https://www.amazon.com/GPU-powered-VDI-Virtual-Desktops/dp/1983043311), and interesting blogpost series available one (https://www.poppelgaard.com/blog).

* **AD / AD - Ask the Directory Services Team** - (https://docs.microsoft.com/en-us/archive/blogs/askds/configuring-an-authoritative-time-server-with-group-policy-using-wmi-filtering)
* **AD / Carl Webster Active Directory Presentations** - (https://carlwebster.com/category/conference-presentations/)
* **AD / GPO Automation** - (https://jm2k69.github.io/2020/02/GPO-from-zero-to-hero-GPO-and-PowerShell.html)
* **AD / GPO Automation** - (https://carlwebster.com/creating-a-group-policy-using-microsoft-powershell-to-configure-the-authoritative-time-server/)
* **AD / GPO** - (https://admx.help) | (https://pspeditor.azurewebsites.net/)
* **AD / GPO Troubleshooting** - (https://evotec.xyz/the-only-command-you-will-ever-need-to-understand-and-fix-your-group-policies-gpo/)
* **Image Preparation** - BIS-F (https://eucweb.com/download-bis-f | https://github.com/EUCweb/BIS-F) - big thank you to Mathias and all guys who brought this to life
* **Image Preparation** - Evergreen (https://github.com/Deyda/Evergreen-Script | https://github.com/aaronparker/Evergreen)
* **Logon Optimization** - (https://james-rankin.com/features/the-ultimate-guide-to-windows-logon-time-optimizations-part-11/)
* **Profiles** - (https://github.com/FSLogix) | UPD | massive products like Ivanti | Roaming Mandatory Profiles
* **Applications** - FsLogix AppMasking - thank you Benny Tritsch (https://www.youtube.com/watch?v=vCtnhTsdAaQ)
* **OS Layer / Uber Agent** - (https://uberagent.com/download/) - Helge Klein - (https://helgeklein.com/) shares great insights, worth following him 
* **WMI/CIM is your friend** - (https://0xinfection.github.io/posts/wmi-basics-part-1/)
* **RDS** - RDS-O-Matic, along with all links provided on this webpage (https://www.rdsgurus.com/scripts/) - @crod - thank you for presenting this to the world!
* **RDS** - (https://mehic.se/category/remote-desktop-services-2016/) - great series which is nice supplement for the RDS book mentioned before
* **PVS vs Pester** - (https://www.youtube.com/watch?v=3xOHpiKEpn8) - Synergy 2017 #SYN306 - this is a perfect example how the building blocks can be glued together

## Product documentation

* The DSC community - https://github.com/dsccommunity - plenty of interesting modules which release from reinventing things from scratch
* Powershell gallery - https://www.powershellgallery.com/
* Technet gallery - https://docs.microsoft.com/en-us/samples/browse/?redirectedfrom=TechNet-Gallery
* XCP-ng documentation - https://xcp-ng.org/docs/
* *Citrix Github* - https://github.com/citrix
* *Citrix Developer* - (https://developer.cloud.com/ | https://developer.citrix.com)
* *Citrix Tech Zone* - (https://docs.citrix.com/en-us/tech-zone/build/deployment-guides/windows-10-deployment.html?utm_content=buffere2e95&utm_medium=social%2520media%2520-%2520organic&utm_source=twitter&utm_campaign=CVAD)
* *Citrix Supportability pack* - (https://support.citrix.com/article/CTX203082)
* *Citrix Optimizer* - (https://support.citrix.com/article/CTX224676)

## Books

* https://www.basvankaam.com/wp-content/uploads/2019/03/Inside-Citrix-The-FlexCast-Management-Architecture.pdf
* https://www.amazon.com/RDS-Complete-Guide-Everything-about-ebook/dp/B07C6849WD/ref=sr_1_1?ie=UTF8&qid=1525462416&sr=8-1&keywords=rds+complete+guide
* https://www.manning.com/books/learn-sql-server-administration-in-a-month-of-lunches - *a bit of sql knowledge wont' harm*
* https://www.manning.com/books/learn-windows-iis-in-a-month-of-lunches - *worth to grasp some details about iis, it will pay off from time to time*
* https://www.manning.com/books/learn-powershell-in-a-month-of-lunches?query=powershell%20in%20month - *month of launches series*
* https://www.manning.com/books/learn-powershell-scripting-in-a-month-of-lunches?query=powershell%20in%20month - *month of launches series*
* https://leanpub.com/the-dsc-book
* https://leanpub.com/pesterbook
* https://leanpub.com/thebigbookofpowershellerrorhandling
* https://leanpub.com/powershell101
* https://leanpub.com/azurebicep
* https://www.amazon.com/Byte-Sized-design-principles-architectural-recommendations/dp/1797692100

## Supportive channels with structuralized content

* https://www.pluralsight.com/ along with their full time author and evangelist Greg Shields and his great courses - he will share a virtual hand and equip you with brilliant tips, which make it easier, going through the installations and configurations of your virtual estate. Extremely patient guy, who is not scared of repeating the same topics as many times until your subscription expires
* https://www.youtube.com/ - search for the sesoins of Cláudio Rodrigues, in youtube you'll have to follow his name with BriForum suffix, otherwise you'll be shown with non relevant materials, (https://www.youtube.com/watch?v=msK6n7049ig) - video from 2012
* https://www.youtube.com/user/briforum - BriForum sessions may be a great foreground for a newcomer, there is dozens of details shared by EUC (End User Computing) engaged colleagues, which can help laying down some foreground for the newer knowledge. Bare in mind that the products by itself didn't changed that much. It's rather the Access Layer which is evolving by prism of Authorization, Authentication and Zero Trust
* https://github.com/yt-dlp/yt-dlp - this will support your youtube activities

## Bunch of usefull links, with a bit more scattered knowledge

* https://www.reddit.com/r/Citrix/
* https://stackoverflow.com/
* https://serverfault.com/

## Podcasts

* https://www.eucdigest.com/episodes/
* https://cloudskills.fm/
* https://runasradio.com/

## Conferences

* https://www.youtube.com/c/PowerShellConferenceEU - PowerShell source, apart from that search for Jeffrey Snover presentations, they way he describes things is straightforward and intelligeble, which proofs his well understanding of the topic ;)
* https://xenappblog.com/agenda/ - virtual expo - it is taking place two times in a year - it is a great initiative which was invented by Trond Haavarstein, with fabolous speakers and presentations
* https://cloudcamp.ie/

## Automated Lab provisioning

* https://github.com/PlagueHO/LabBuilder
* https://github.com/VirtualEngine/Lability
* https://github.com/pluralsight/PS-AutoLab-Env
* https://github.com/ZachThurmond/Automated-XenServer-Labs

## Community shares - lab approaches

* Carl Webster Lab - (https://carlwebster.com/building-websters-lab-v2/)
* Nicolas Ignoto - (https://www.citrixguru.com/category/lab/)
* https://mybrokencomputer.net/t/setup-a-citrix-home-lab-in-sixty-minutes/28

## Community shares

* World of EUC slack - (https://t.co/EVrMXepANH)
* World of EUC discord - (https://t.co/zE0QTpANZQ)
* EUC weekly digest - (https://www.carlstalhood.com/category/euc-weekly-digest/)
* MyCugc with all the webinars recoreded - (https://www.mycugc.org/events/webinars)
* There is an interesting mission behind the scenes - (https://www.go-euc.com/)
* ViaMonstra Academy - (https://academy.viamonstra.com/collections)

Two Carl's - let's list them alphabetically: Carl Webster and Carl Stalhood

* Building Carl Webster lab - (https://carlwebster.com/01-building-websters-lab-v2-introduction/ | https://carlwebster.com/building-websters-lab-v2-pdf/) - his guide contains 1335 pages. Imagine how much of an errort was made to bring this to life. It's available for free...
* Carl Stalhood - (https://www.carlstalhood.com/about-carl-stalhood/) - great resources and fair amount of links to other places which may bring you up to speed, along with tips for solving many of the issues which may arise, which are not well documented somewhere else.
* Claudio Rodriguez - (http://blog.wtslabs.com/), apart from that there were RAS university initiative (http://ras.euc.university/) - but for some reason this is no longer active
* Freek Berson - (https://github.com/fberson | http://microsoftplatform.blogspot.com/) - his blog post are great to lay down the foreground for Citrix which is nothing else than RDS (Remote Desktop Services), it seems to be good idea to start with Terminal Services and RDS which help structualize knowledge needed for a Citrix guy
* MsFreaks - (https://msfreaks.wordpress.com/)
* Bas van Kaam - (https://www.basvankaam.com/) - he is one of the Nerdio evangelist, who shared great green book called the FMA Architecture.
* Denis Span - (https://dennisspan.com/) - he was my inspiration for some automation topics around PVS etc. His blog is full of examples how the installation of the components building CVAD can be automated. You may customize those scripts for your preference, for instance including the Error and Verbose streams, they are great starting point.
* Jonathan Pitre - (https://github.com/JonathanPitre)
* Dennis Mohrmann - (https://github.com/Mohrpheus78/)
* Trond Erik Haavarstein - (https://xenappblog.com/ | https://github.com/Haavarstein/Applications)
* Guy Leech - (https://twitter.com/guyrleech) - there is no better place to be inspired in powershell area ;)
* Johannes Norz - (https://norz.at/blog | https://www.wonderkitchen.tech/) - here you can benefit for your Citrix ADC skilset
* Esther Barthel - (https://github.com/cognitionit) - if you are interested in REST API, Nitro for Citrix ADC and topics around automation, she is the one to follow
* Julian Jakob - (https://www.julianjakob.com/)
* Julien Mooren - (https://citrixguyblog.com | https://github.com/citrixguyblog) - he was my inspiration to fork his AutomatedRDS release back in 2017.
* James Kindon - (https://github.com/JamesKindon | https://jkindon.com/)
* James Ranklin - (https://james-rankin.com/) - amazing content is produced by James, no doubts
* Daniel Fehler - (https://virtualfeller.com/)
* René Bigler - (https://dreadysblog.com/)
* Marco Zimmermann - (http://marcozimmermann.com/)
* Manuel Winkel - (https://www.deyda.net/index.php/en/
* Matthias Schlimm - (https://eucweb.com/)
* Ben Gelens - (https://bgelens.nl/)
* Kristin Griffin - (https://www.rdsgurus.com/author/grokker99/) - her contribution in RDS area seems to be not that well known, but still she brought added value value to the EUC community
* Kris Davis - (https://xenapplepie.com/)
* John Billekens - (https://blog.j81.nl/)
* George Spiers - (https://www.jgspiers.com/) - his blog is towards, you getting handy with NetScaler and topics on your OS layer
* Lee Jeffries - (https://www.leeejeffries.com/blog/)
* Ravikanth C - (https://github.com/rchaganti) - in context of DSC, great source, if I'm not mistaken he had authored one of the DSC books available

Many of abovementioned EUC experts, links on their blogs shares great tools which may improve your skills in your daily work, and reveal knowledge, which you'll never get on the trainings guarateed by the vendor, exposing their experience from the field. There are many more, please forgive me I can not enumerate them all here. Depending from the area, many are CTP's or MVP's, but there are also grey eminence personas who share valuable information.

## Tools

* https://feedly.com/ - RSS agregator
* https://freedns.afraid.org/subdomain/ - fantastic freeDNS service
* https://www.cloudflare.com/ - can bring great improvement for your web services
* ShareX - (https://getsharex.com/) - fantastic project for a screen capturing, producing GIF's for your webpage (thank you Josh Duffney! - https://duffney.io/)
* CIM/WMI Explorer - (https://www.sapien.com/software/cimexplorer | https://www.ks-soft.net/hostmon.eng/wmi/index.htm)
* Chocolatey - (https://chocolatey.org/ | https://github.com/chocolatey/choco)
* Ninite - (https://ninite.com/) - Install and Update your apps at once
* BoxStarter - (https://boxstarter.org/)
* WizTree - (https://diskanalyzer.com/) - TreeSize alternative, which is just faster
* Glaswire - (https://www.glasswire.com/)
* Shut up 10 - (https://www.oo-software.com/en/shutup10)

It's impossible to list all names of great people who produce the valuable content and link it in one place, never the less it is a good starting point. The question which remains is the order to lay this down, constructively in memory. Apart from that each of us has it's topics which attacts him or her more than other and it is the Team who builds the Virtual Workplace solutions, not the lonesome wariors or stars.
Keep calm and do puzzles (https://www.redbubble.com/shop/jackson+pollock+jigsaw-puzzles).

