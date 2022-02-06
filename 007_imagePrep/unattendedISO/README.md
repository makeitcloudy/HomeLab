**# Creating unattended updated iso which become sources for the virtual machines**<br><br>
+ Microsoft iso which can be sources for current excercise, can be found here (https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019)<br><br>

**# Unattended.xml**<br>
Windows System Image Manager is your way to go (WSIM). It's part of the Windows Assesment and Deployment kit (ADK).<br>
ADK is available here: (https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install). It can be installed on your windows 10 device, where the RSAT tools are already available, which is also your authoring (DSC) and managment node. Following blog post, explains how to preapare the image for the unattended installation (https://taylor.dev/how-to-create-an-automated-install-for-windows-server-2019/). In our scenario, the overall outcome is really simple, not too much customizations, as the further config will happen on the DSC level, and the iso is supposed to be as generic as possible.<br>
WSIM will create files with .clg extension, which are worth to be collected for further projects if any.<br>
Some details how the UEFI works can be found here (https://www.happyassassin.net/posts/2014/01/25/uefi-boot-how-does-that-actually-work-then/)
+ UEFI boot requires different partitioning than BIOS boot<br>
+ UEFI boot has their implications on the PVS (DHCP options, and TFTP boot)<br>
+ Passwords within the unattended.xml file have Base64 encoding within passwords stored for users<br>
+ Unattended iso may require your attention, to press any key to Boot from CD or DVD..., this can be changed with oscdimg, by pointing towards noprompt efi file<br><br>
+ RENAME *autounattend-ServerOS.xml* to *autounattend.xml* and you are good to go for unatended installation of **Windows Server** operating system<br>
+ RENAME *autounattend-DesktopOS.xml* to *autounattend.xml* and you are good to go for unatended installation of **Windows Server** operating system<br>
+ *Be aware that passwords stored in autounattend.xml are stored unencrypted, never the less still the goal is to automate your deployment of the gold image, in your lab this way that those needs zero attention during installation. Once those are provisioned, and you got access to the vm over the network, those can be changed with DSC or via winRM*<br><br>

**# SeguraOSD**<br>
+ SeguraOSD tools produce iso, updated with latest updates comming from Microsoft, which can be used as bare image for your lab VM installations.<br>
+ I'm not recommending installing the SeguraOSD on the authoring/mgmt node, as it needs plenty amount of disk space to perform updating the images. Preferably SeguraOSD tooling is installed on another VM, as DISM which is being used undearneath, does not really take the benefit of what the CPU can offer, and as per my understanding is single threaded. Based on the observation, updating one image, from the iso downloaded from microsoft webpage, requires around 20GB, the image is copied in few places, as well as at the end the iso is created. The VM could have 1vCPU, RAM 4GB (8GB preffered), and 20GB multiplied by amount of images you'd like the SeguraOSD to process.<br>
+ If you do not like expanding your C drive, the easiest way would be mounting another drive as folder on the operating system level, as 
+ Updating the image, takes roughly between 1 and 1,5 hour.<br>
+ If I'm not mistaken and recall properly it also requires the ADK to be installed, so it can create the iso file.<br>
+ Machine which is used to burn the image with oscdimg, should have at least such amount of space to keep two iso's. First is the one copied from the mounted iso, second one is the iso burned with the oscdimg.<br><br>

**# Removing "press any key" prompts for GPT/UEFI Windows install**<br>
+ Oscdimg documentation can be found here (https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/oscdimg-command-line-options)<br>
+ Oscdimg details which gives more insight than the MS documentation (https://oofhours.com/2021/12/25/how-does-uefi-boot-from-a-cd/)<br>
+ howto is avaialble here (https://williamlam.com/2016/06/quick-tip-how-to-create-a-windows-2016-iso-supporting-efi-boot-wo-prompting-to-press-a-key.html)<br>

1. https://gist.github.com/misheska/2af4f9d17206326889b44c3c1f50e277#file-copywindowsiso-ps1<br>
2. https://gist.github.com/misheska/035c52cf7e7a47087c013cd346d9d5d1#file-nopromptswitch-ps1<br>
3. https://gist.github.com/misheska/2c3b032eaf529b1b5176bfa1560a10d5#file-createnopromptiso-ps1<br>

**# Valuable materials**<br>
+ https://www.deploymentresearch.com/w10guide-thankyou/<br>
+ https://www.windowscentral.com/how-create-unattended-media-do-automated-installation-windows-10<br><br>
