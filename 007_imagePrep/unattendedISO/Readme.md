**#Unattended.xml**<br><br>

Windows System Image Manager is your way to go (WSIM). It's part of the Windows Assesment and Deployment kit (ADK).<br>
ADK is available here: (https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install). It can be installed on your windows 10 device, where the RSAT tools are already available, which is also your authoring (DSC) and managment node. Following blog post, explains how to preapare the image for the unattended installation (https://taylor.dev/how-to-create-an-automated-install-for-windows-server-2019/). In our scenario, the overall outcome is really simple, not too much customizations, as the further config will happen on the DSC level, and the iso is supposed to be as generic as possible.<br>
WSIM will create files with .clg extension, which are worth to be collected for further projects if any.<br>
Some details how the UEFI works can be found here (https://www.happyassassin.net/posts/2014/01/25/uefi-boot-how-does-that-actually-work-then/)
+ UEFI boots requires different partitions tha BIOS boot<br>
+ UEFI boots has their implications on the PVS (DHCP options, and TFTP boot)<br>
+ Passwords within the unattended.xml file have Base64 encoding within passwords stored for users<br>
+ Unattended iso may require your attention, to press key to Boot from CD or DVD...<br><br>
+ SeguraOSD tools produce iso, updated with latest updates comming from microsoft, which can be used as bare image for your lab VM installations.
+ I'm not recommending installing the SeguraOSD on the authoring/mgmt node, as it needs plenty amount of disk space to perform updating the images. Preferably SeguraOSD tooling is installed on another VM, as DISM which is being used undearneath, does not really take the benefit of what the CPU can offer, and as per my understanding is single threaded. Based on the observation, updating one image, from the iso downloaded from microsoft webpage, requires around 20GB, the image is copied in few places, as well as at the end the iso is created. The VM could have 1vCPU, RAM 4GB (8GB preffered), and 20GB multiplied by amount of images you'd like the SeguraOSD to process.<br>
+ Updating the image, takes roughly between 1 and 1,5 hour.<br>
+ If I'm not mistaken and recall properly it also requires the ADK to be installed, so it can create the iso file.<br>

**#Removing "press any key" prompts for GPT/UEFI Windows install**
Once the iso Replacing cdboot.efi and efisys.bin
+ Maching which is used to burn the image with oscdimg, should have at least such amount of space to keep two iso's. First is the one copied from the mounted iso, second one is the iso burned with the oscdimg.
+ Oscdimg documentation can be found here (https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/oscdimg-command-line-options)<br>
+ Oscdimg details which gives more insight (https://oofhours.com/2021/12/25/how-does-uefi-boot-from-a-cd/)<br>
