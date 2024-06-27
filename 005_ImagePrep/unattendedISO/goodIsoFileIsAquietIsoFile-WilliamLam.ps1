# This piece of code comes from https://williamlam.com/2016/06/quick-tip-how-to-create-a-windows-2016-iso-supporting-efi-boot-wo-prompting-to-press-a-key.html

# Path to the Extracted or Mounted Windows ISO 
$ISOMediaFolder = 'E:\'

# Path to new re-mastered ISO
$ISOFile = 'C:\Users\lamw\Desktop\Windows2016.iso'

# Need to specify the root directory of the oscdimg.exe utility which you need to download
$PathToOscdimg = 'C:\Program Files\Windows AIK\Tools\PETools'

# Instead of pointing to normal efisys.bin, use the *_noprompt instead
$BootData='2#p0,e,b"{0}"#pEF,e,b"{1}"' -f "$ISOMediaFolder\boot\etfsboot.com","$ISOMediaFolder\efi\Microsoft\boot\efisys_noprompt.bin"

# re-master Windows ISO
Start-Process -FilePath "$PathToOscdimg\oscdimg.exe" -ArgumentList @("-bootdata:$BootData",'-u2','-udfver102',"$ISOMediaFolder","$ISOFile") -PassThru -Wait -NoNewWindow
