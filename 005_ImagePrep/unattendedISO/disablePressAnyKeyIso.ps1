#region johan 
#Start-Process 'https://www.deploymentresearch.com/a-good-iso-file-is-a-quiet-iso-file/'
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
#endregion

#region william
# Start-Process 'https://williamlam.com/2016/06/quick-tip-how-to-create-a-windows-2016-iso-supporting-efi-boot-wo-prompting-to-press-a-key.html'
# Path to the Extracted or Mounted Windows ISO
$ISOMediaFolder = 'E:\'
# Path to new re-mastered ISO
$ISOFile = 'C:\iso\Windows2016.iso'
# Need to specify the root directory of the oscdimg.exe utility which you need to download
$PathToOscdimg = 'C:\Program Files\Windows AIK\Tools\PETools'
# Instead of pointing to normal efisys.bin, use the *_noprompt* instead
$BootData='2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$ISOMediaFolder\boot\etfsboot.com","$ISOMediaFolder\efi\Microsoft\boot\efisys_noprompt.bin"
# re-master Windows ISO - so it runs without press any key prompt**
Start-Process -FilePath "$PathToOscdimg\oscdimg.exe" -ArgumentList @("-bootdata:$BootData",'-u2','-udfver102',"$ISOMediaFolder","$ISOFile") -PassThru -Wait -NoNewWindow
#endregion

#region taylor
# Start-Process 'https://gist.github.com/misheska/2af4f9d17206326889b44c3c1f50e277#file-copywindowsiso-ps1'
# Start-Process 'https://gist.github.com/misheska/035c52cf7e7a47087c013cd346d9d5d1#file-nopromptswitch-ps1'

# Remove any previously-existing c:\iso directory
Remove-Item -Recurse -Force c:\iso
# Create c:\iso directory
New-Item -ItemType Directory -Force -Path c:\iso
# Copy exact contents of Windows ISO mounted on drive E:\ recurisvely
robocopy e:\ c:\iso /MIR
###
Rename-Item -Path c:\iso\efi\microsoft\boot\cdboot.efi -NewName cdboot-prompt.efi
Rename-Item -Path c:\iso\efi\microsoft\boot\cdboot_noprompt.efi -NewName cdboot.efi
Rename-Item -Path c:\iso\efi\microsoft\boot\efisys.bin -NewName efisys_prompt.bin
Rename-Item -Path c:\iso\efi\microsoft\boot\efisys_noprompt.bin -NewName efisys.bin
###
# Example creating a "noprompt" ISO from c:\iso with ocsdimg
oscdimg -m -o -u2 -udfver102 -bootdata:2#p0,e,b"c:\iso\boot\etfsboot.com"#pEF,e,b"c:\iso\efi\microsoft\boot\efisys.bin" "c:\iso" "%USERPROFILE%\Desktop\windows_noprompt.iso"

# -m Ignore the maximum size limit of the image
# -o Optimize by removing duplicate files
# -u2 UDF file system ISO image
# -udfver102 UDF version will be 1.02
# -bootdata:2 Specifies there will be two boot catalog entires, delimited by #
# p0,e,b<Path>
# p - Specifies value to use for platform ID in the El Torito catalog. 0x00 represents a BIOS system
# e - Disables floppy disk emulation in the El Torito catalog
# b - Specifies the El Torito boot sector file
# pEF,e,b<Path>
# p - Specifies value to use for platform ID in the El Torito catalog. 0XEF represents an EFI system
# e - Disables floppy disk emulation in the El Torito catalog
# b - Specifies the El Torito boot sector file
#endregion
