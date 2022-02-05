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
