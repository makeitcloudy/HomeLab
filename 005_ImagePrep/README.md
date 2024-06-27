**# Download iso files**

+ at this stage you downloaded the iso files with (https://github.com/AveYo/MediaCreationTool.bat) and drop them on the nfs storage repository, which is exposed via nfs and smb for your management node. It will help you downloading Windows10 iso files. You can rename the bat file instead of using the GUI, and the execution of such .bat file, will launch the download (unless you have 8GB of space left on your hard drive).

```
enterpriseN iso 21H2 MediaCreationTool.bat
```

**# Creating unattended updated iso which become sources for the virtual machines**<br><br>
+ Microsoft iso which can be sources for current excercise, can be found here (https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019)<br><br>

**# Unattended.xml**

Windows System Image Manager is your way to go (WSIM). It's part of the Windows Assesment and Deployment kit (ADK).<br>
ADK is available here: (https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install). It can be installed on your windows 10 device, where the RSAT tools are already available, which is also your authoring (DSC) and managment node. Following blog post, explains how to preapare the image for the unattended installation (https://taylor.dev/how-to-create-an-automated-install-for-windows-server-2019/). In our scenario, the overall outcome is really simple, not too much customizations, as the further config will happen on the DSC level, and the iso is supposed to be as generic as possible.<br>
WSIM will create files with .clg extension, which are worth to be collected for further projects if any.<br>
Some details how the UEFI works can be found here (https://www.happyassassin.net/posts/2014/01/25/uefi-boot-how-does-that-actually-work-then/)
+ UEFI boot requires different partitioning than BIOS boot<br>
+ UEFI boot has their implications on the PVS (DHCP options, and TFTP boot)<br>
+ Passwords within the unattended.xml file have Base64 encoding within passwords stored for users<br>
+ Unattended iso may require your attention, to press any key to Boot from CD or DVD..., this can be changed with oscdimg, by pointing towards noprompt efi file<br><br>
+ RENAME *autounattend-uefi-ServerOS.xml* or *autounattend-bios-ServerOS.xml* to *autounattend.xml* and you are good to go for unatended installation of **Windows Server** operating system
+ RENAME *autounattend-uefi-DesktopOS.xml* or *autounattend-bios-DesktopOS.xml* to *autounattend.xml* and you are good to go for unatended installation of **Windows Desktop** operating system
+ *Be aware that passwords stored in autounattend.xml are stored unencrypted, never the less still the goal is to automate your deployment of the gold image, in your lab this way that those needs zero attention during installation. Once those are provisioned, and you got access to the vm over the network, those can be changed with DSC or via winRM*<br><br>
+ WSIM is a bit of overhead for preparing simple xml file which helps creating the unattended iso, never the less if you create it for the first time and do not have any building blocks, it's really helpfull.
+ Unattended xml are compatible across operating systems (tested the same xml on 2016, 2019 2022 and it works), same applies for desktop operating systems (never the less I have not tested compatibility of the xml between windows 7, 8.1 and 10), still any version of w10 handle the desktop unattended xml file.<br><br>

**# SeguraOSD**

+ SeguraOSD tools produce iso, updated with latest updates comming from Microsoft, which can be used as bare image for your lab VM installations (https://osdbuilder.osdeploy.com/).
+ I'm not recommending installing the SeguraOSD on the authoring/mgmt node, as it needs plenty amount of disk space to perform updating the images. Preferably SeguraOSD tooling is installed on another VM, as DISM which is being used undearneath, does not really take the benefit of what the CPU can offer, and as per my understanding is single threaded. Based on the observation, updating one image, from the iso downloaded from microsoft webpage, requires around 20GB, the image is copied in few places, as well as at the end the iso is created. The VM could have 1vCPU, RAM 4GB (8GB preffered), and 20GB multiplied by amount of images you'd like the SeguraOSD to process.
+ If you do not like expanding your C drive, the easiest way would be mounting another drive as folder on the operating system level, as 
+ Updating the image, takes roughly between 1 and 1,5 hour.
+ OSDBuilder does support Server 2012R2 under following conditions (https://osdbuilder.osdeploy.com/docs/legacy/windows-server-2012-r2)
+ It requires the ADK to be installed, so it can create the iso file with oscdimg.exe.
+ Machine which is used to burn the image with oscdimg, should have at least such amount of space to keep two iso's. First is the one copied from the mounted iso, second one is the iso burned with the oscdimg.
+ Quick Start Guide Windows 10 WaaS Servicing Updates via OSDBuilder - (https://www.moderndeployment.com/quick-start-guide-windows-10-waas-servicing-updates-via-osdbuilder/)<br>

**# Install OSDBuilder on your image servicing vm**
+ Install module
```
Install-Module -Name OSDBuilder
```
+ Import module
```
Import-Module OSDBuilder
```
+ Get details about the version and it's configuration
```
Import-Module OSDBuilder
```
+ it would be wise to store the OSDBuilder efforts on second drive which is attached to your servicing VM (it make sense to split your management/authoring node, from the image servicing machine), in case you consider servicing 2016, 2019, 2022 and windows 10, then plan at least 180GB, especially under the condition when you rewrite the updated iso with the autounattended.xml files.
```
Get-OSDBuilder -SetHome O:\OSDBuilder
```
+ create paths (it will prepare the structure of the folders, for your OSMedia, OSBuilds, updates, and other elements like ISO)
```
Get-OSDBuilder -CreatePaths
```
**# Update image with OSDBuilder - first time**
+ mount the iso file which is planned to be updated with the latest updates
```
$isoWindows2016ImagePath = 'C:\LabResourcesIso\org\w2k16.iso'
Mount-DiskImage -ImagePath $isoWindows2016ImagePath -StorageType ISO -Verbose
```
+ Import a supported Operating System into the OSDBuilder OSImport directory
```
Import-OSMedia -Update -BuildNetFX
```
+ Apply the updates
```
Update-OSMedia -Download -Execute
```
+ Burn Iso
```
New-OSBMediaIso
```
+ *The iso produced here is ready to be used, **as the source** to drop autounattended.xml file into it, **and reburn it again** for unattended installations*

**# Update image with OSDBuilder - subsequent update**
+ Update OSDBuilder first (provided you are working with fresh supported operating system)
```
OSDBuilder -UpdateModule
```
+ Get the OS Media - it will list the names of the media which has been processed by OSDBuilder on current servicing node
```
Get-OSMedia | Where-Object {$_.MediaTYpe -match 'OSMedia'} | Select-Object MediaType,ModifiedTime,SuperSeded,NeedsUpdate,Revision,Updates,Name
```
+ Run this to install latest updates - your OSMedia builds are located in OSDBuilder\OSMedia, abovementioned commandlet list them all for you
```
Update-OSMedia -Name 'Windows Server 2019 Datacenter Evaluation x64 1809 17763.2686' -Download -Execute
```
+ Create build out of updated media
```
New-OSBuild -Name 'Windows Server 2019 Datacenter Evaluation x64 1809 17763.2686' -Download -EnableNetFX -Execute -CreateISO
```
+ Burn Iso
```
New-OSBMediaIso
```

**# Removing "press any key" prompts for GPT/UEFI Windows install**<br>
+ Once the Iso is ready it is stored within the location
```
O:\OSDBuilder\OSBuilds\Windows Server 2019 Datacenter Evaluation x64 1809 17763.2686\ISO\Server 10.0.17763.2686.iso
```
+ Mount the iso
+ Copy it's content to some location of the filesystem (2022.03.27 - not sure if this step is really necessary, need to test it)
+ drop the autounattended.xml file respectively for server/desktop uefi/bios
+ run following command (try to follow this https://www.deploymentresearch.com/a-good-iso-file-is-a-quiet-iso-file/) - as of 2022.03.27 - not tested yet, used anothe way of doing this which did the trick
```
<#
.Synopsis
    Sample script for Deployment Research
    For UEFI Deployments, modifies a WinPE ISO to not ask for "Press Any Key To Boot From..."

.DESCRIPTION
    Created: 2020-01-10
    Version: 1.0
     
    Author : Johan Arwidmark
    Twitter: @jarwidmark
    Blog   : https://deploymentresearch.com
 
    Disclaimer: This script is provided "AS IS" with no warranties, confers no rights and 
    is not supported by the author or DeploymentArtist..

.NOTES
    Requires Windows ADK 10 to be installed

.EXAMPLE
    N/A
#>

# Settings
$WinPE_Architecture = "amd64" # Or x86
$WinPE_InputISOfile = "C:\ISO\Zero Touch WinPE 10 x64.iso"
$WinPE_OutputISOfile = "C:\ISO\Zero Touch WinPE 10 x64 - NoPrompt.iso"
 
$ADK_Path = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit"
$WinPE_ADK_Path = $ADK_Path + "\Windows Preinstallation Environment"
$OSCDIMG_Path = $ADK_Path + "\Deployment Tools" + "\$WinPE_Architecture\Oscdimg"

# Validate locations
If (!(Test-path $WinPE_InputISOfile)){ Write-Warning "WinPE Input ISO file does not exist, aborting...";Break}
If (!(Test-path $ADK_Path)){ Write-Warning "ADK Path does not exist, aborting...";Break}
If (!(Test-path $WinPE_ADK_Path)){ Write-Warning "WinPE ADK Path does not exist, aborting...";Break}
If (!(Test-path $OSCDIMG_Path)){ Write-Warning "OSCDIMG Path does not exist, aborting...";Break}

# Mount the Original ISO (WinPE_InputISOfile) and figure out the drive-letter
Mount-DiskImage -ImagePath $WinPE_InputISOfile
$ISOImage = Get-DiskImage -ImagePath $WinPE_InputISOfile | Get-Volume
$ISODrive = [string]$ISOImage.DriveLetter+":"

# Create a new bootable WinPE ISO file, based on the Original ISO, but using efisys_noprompt.bin instead
$BootData='2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$OSCDIMG_Path\etfsboot.com","$OSCDIMG_Path\efisys_noprompt.bin"
   
$Proc = Start-Process -FilePath "$OSCDIMG_Path\oscdimg.exe" -ArgumentList @("-bootdata:$BootData",'-u2','-udfver102',"$ISODrive\","`"$WinPE_OutputISOfile`"") -PassThru -Wait -NoNewWindow
if($Proc.ExitCode -ne 0)
{
    Throw "Failed to generate ISO with exitcode: $($Proc.ExitCode)"
}

# Dismount the Original ISO
Dismount-DiskImage -ImagePath $WinPE_InputISOfile
```


+ Oscdimg documentation can be found here (https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/oscdimg-command-line-options)<br>
+ Oscdimg details which gives more insight than the MS documentation (https://oofhours.com/2021/12/25/how-does-uefi-boot-from-a-cd/)<br>
+ howto is avaialble here (https://williamlam.com/2016/06/quick-tip-how-to-create-a-windows-2016-iso-supporting-efi-boot-wo-prompting-to-press-a-key.html)<br>

1. https://gist.github.com/misheska/2af4f9d17206326889b44c3c1f50e277#file-copywindowsiso-ps1<br>
2. https://gist.github.com/misheska/035c52cf7e7a47087c013cd346d9d5d1#file-nopromptswitch-ps1<br>
3. https://gist.github.com/misheska/2c3b032eaf529b1b5176bfa1560a10d5#file-createnopromptiso-ps1<br>

**# Valuable materials**

+ https://www.deploymentresearch.com/w10guide-thankyou/
+ https://www.windowscentral.com/how-create-unattended-media-do-automated-installation-windows-10
+ https://williamlam.com/2016/06/quick-tip-how-to-create-a-windows-2016-iso-supporting-efi-boot-wo-prompting-to-press-a-key.html
+ https://www.deploymentresearch.com/a-good-iso-file-is-a-quiet-iso-file/
