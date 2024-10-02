.

```powershell
# https://support.citrix.com/s/article/CTX224843-windows-10-11-compatibility-with-citrix-virtual-desktops-xendesktop?language=en_US

# https://www.microsoft.com/en-us/evalcenter/download-windows-10-enterprise

```


```powershell
$isoFolder = 'O:\ISO\notUpdated_evalCenter\w10'
$isoName = 'w10_21H2_LTSC_19044.1288.211006-0501.iso'  #w10_21H2_LTSC
#$isoName = 'w10_22H2_19045.2006.220908-0225.iso'      #w10_22H2

#$isoFolder = 'O:\ISO\updated\w10'
#$isoName = 'w10ent_21H2_2302_untd_nprmpt_uefi.iso'
$isoSourcePath = Join-Path -Path $isoFolder -ChildPath $isoName

$imageName = 'Windows 10 Enterprise x64 21H2 19044.2604' # it is a result of the (Get-OSMedia).Name
$taskName = '202410_w10_ent_updates'                     # taskName will vary depending from the OS release and Date (w10_21H2_LTSC, w10_22H2, w11_23H2)

Mount-DiskImage -ImagePath $isoSourcePath -Verbose

# 2. Import iso
# ImageIndex 1: Windows 10 Enterprise LTSC Evaluation
# ImageIndex 2: Windows 10 Enterprise N LTSC Evaluation
Import-OSMedia -Index 2

# Unmount Diskimage

Get-OSMedia -GridView -Verbose

#Update-OSMedia -Download -Execute
# OS Media does not have the latest WSUSXML (MS Updates)
# Use the following command before furnning New-OSBuild
Update-OSMedia -Name $imageName -Download -Execute

# Now that the OS Media is imported and updated, you must create a task that you’ll use to re-run the monthly updates with any features you enable or disable.
# Run this command to create a new task (or re-run a previously created task). 
# In my case, I’m planning to enable .NET 3.5 SP1 so I’ve created the task name as shown below. 
# Create the name that makes sense for you.
New-OSBuildTask -TaskName $taskName -EnableNetFX3

New-OSBuild -Download -Execute -ByTaskName $taskName
#pick the OSImport

# copy the autounatted.xml here - only if the source of the ISO is eval center
# in case the ISO has been already updated, the unattended XML should be already there
Invoke-Item -Path "O:\OSDBuilder\OSBuilds\$($imageName)\OS"

Get-OSBuilds

#https://www.ntlite.com/community/index.php?threads/how-to-remove-press-any-key-to-boot-from-cd-or-dvd.2147/
## Proceed with those steps for the UEFI build
#1) Delete efisys.bin and cdboot.efi in extracted setup media in \efi\microsoft\boot
#2) Rename efisys_noprompt.bin to efisys.bin
#3) Rename cdboot_noprompt.efi to cdboot.efi

## TODO - check if this is needed for the BIOS

New-OSBMediaISO -FullName "O:\OSDBuilder\OSBuilds\$($imageName)"
#New-OSBMediaISO -FullName "O:\OSDBuilder\OSBuilds\$windowsServer2022ReleaseName"
#pick OSBuild - (pushed up all updates, and enabled netfx)

#ISO should be stored in following directory:
Invoke-Item -Path "O:\OSDBuilder\OSBuilds\$($imageName)\ISO"

#Copy the image to your ISO repository
```