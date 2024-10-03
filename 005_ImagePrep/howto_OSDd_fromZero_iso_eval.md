
```powershell
#region uninstall OSDBuilder, OSD, OSDSUS
Uninstall-Module -RequiredVersion 23.2.21.1 -Name OSDBuilder


#update-module OSD -Force
#Update-OSDSUS
#endregion

#region install OSDBuilder, OSD, OSDSUS
####
#https://github.com/OSDeploy/OSDBuilder
#https://github.com/OSDeploy/OSD
#https://github.com/OSDeploy/OSDSUS

# as of 2024.10.03 - the latest release is: 
Find-Module -Name OSDBuilder -AllVersions #23.2.21.1  OSDBuilder                          PSGallery 
Find-Module -Name OSD -AllVersions        #24.10.1.1  OSD                                 PSGallery
Find-Module -Name OSDSUS -AllVersions     #24.9.13.1  OSDSUS                              PSGallery

Install-Module -Name OSDBuilder -MinimumVersion 23.2.21.1 -Verbose
# 2024.10.03 - once the OSDBuilder is installed the OSD Module is 24.9.30.1
# the latest release of OSD Module is 24.10.1.1

Get-Module -Name OSD -ListAvailable #Script     24.10.1.1  OSD  
Get-Module -Name OSDSUS -ListAvailable #Script     24.9.13.1  OSDSUS

# update OSD
OSDBuilder -UpdateModule

#install OSDSUS
Install-Module OSDSUS -MinimumVersion 24.9.13.1 -Force
#update OSDSUS
Update-OSDSUS

# at this point the tooling shuold be in it's latest releases as of 2024.10.03

### close powershell session

# once powershell is run again
Uninstall-Module -Name OSD -RequiredVersion 24.9.30.1 -Force
Get-Module -Name OSDBuilder,OSD,OSDSUS -ListAvailable
#ModuleType Version    Name  
#Script     24.10.1.1  OSD
#Script     23.2.21.1  OSDBuilder
#Script     24.9.13.1  OSDSUS

Import-Module -Name OSDBuilder,OSD,OSDSUS -Force -Verbose
#Import-Module -Name OSD -Force -Verbose
#Import-Module -Name OSDSUS -Force -Verbose
#endregion


#0. Create Folder Structure - IF the folders are there skip this step
New-Item -ItemType Directory -Path 'O:\ISO\notUpdated_evalCenter\w10'
New-Item -ItemType Directory -Path 'O:\ISO\notUpdated_evalCenter\w11'

New-Item -ItemType Directory -Path 'O:\ISO\updated_unattended\w10'
New-Item -ItemType Directory -Path 'O:\ISO\updated_unattended\w11'

New-Item -ItemType Directory -Path "O:\Temp\w10\efi\microsoft\boot\"
New-Item -ItemType Directory -Path "O:\Temp\w11\efi\microsoft\boot\"


#1. Download from the Eval Center ISO's to isoFolder - if the iSO are there skip it
#2. Initialize variables
$osType        = "w10"                             # w10, w11

$date          = Get-Date -Format ('yyyyMMdd')
$dateISOName   = Get-Date -Format ('yyMM')
$taskName      = "$($date)_$($osType)_patching"  # taskName will vary depending from the OS release and Date (w10_21H2_LTSC, w10_22H2, w11_23H2)
$isoFolder     = "O:\ISO\notUpdated_evalCenter\$($osType)"
Get-ChildItem -Path $isoFolder | Select-Object Length,LastWriteTime,Name

$isoName = 'w10_22H2_19045.2006.220908-0225.iso'

$isoSourcePath = Join-Path -Path $isoFolder -ChildPath $isoName

Mount-DiskImage -ImagePath $isoSourcePath -Verbose

# 2. Import iso
# ImageIndex 1: Windows 10 Enterprise LTSC Evaluation
# ImageIndex 2: Windows 10 Enterprise N LTSC Evaluation
# Import-OSMedia -Index 2 - this applies to LTSC w 10 ?
Import-OSMedia -Index 1 -SkipGrid #only one index in w10_22H2_19045.2006.220908-0225.iso
#2024-10-03-051542 -> 2024-10-03-052411

# Unmount Diskimage
Dismount-DiskImage -ImagePath $isoSourcePath -Verbose

#Get-OSMedia -GridView -Verbose
Get-OSMedia | Where-Object {$_.MediaType -eq 'OSImport'} | Select-Object MediaType,ModifiedTime,Superseded,Revision,Name | Format-Table
(Get-OSMedia -Newest).Name
#pick:
#MediaType: OSImport
#Superseded: False
#Revision: OK
#Name: Goes hand in hand with $isoName code - 19045.2006

#$imageName = 'Windows 10 Enterprise x64 21H2 19044.2604' # it is a result of the (Get-OSMedia -Newest).Name
#$imageName = 'Windows 10 Enterprise Evaluation x64 22H2 19045.2006'
$imageName = 'Windows 10 Enterprise Evaluation x64 22H2 19045.4894'

## here before proceeding make sure your OSDBuilder version uses the latest OSD and OSDSUS releases
# find in psgallery
@('OSDSUS','OSDBuilder','OSD').ForEach({
    Find-Module -Name $_ -AllVersions | Select-Object -First 1 
})
# find the versions installed locally
Get-Module -Name OSDBuilder,OSD,OSDSUS -ListAvailable | Select-Object Version,Name,ModuleType,ExportedCommands | Sort-Object -Descending Name


## if the versions are not in sync, update the OSD, and OSDSUS
#Install-Module OSDSUS -MinimumVersion 24.9.13.1 -Force
#Install-Module OSD -MinimumVersion 24.10.1.1 -Force

## if modules are loaded close powershell session, reopen it and run
# where the versions should be the numbers of the modules installed locally on the machine
#Uninstall-Module -Name OSD -RequiredVersion 24.9.30.1 -Force
#Uninstall-Module -Name OSDSUS -RequiredVersion 24.9.13.1 -Force

## it should be reflected in the filesystem: 
## C:\Program Files\WindowsPowerShell\Modules\OSD
## C:\Program Files\WindowsPowerShell\Modules\OSDSUS


#Update-OSMedia -Download -Execute
# OS Media does not have the latest WSUSXML (MS Updates)
# Use the following command before furnning New-OSBuild
Update-OSMedia -Name $imageName -Download -Execute
#2024-10-03-062957 -> 2024-10-03-091438

# Now that the OS Media is imported and updated, you must create a task that you’ll use to re-run the monthly updates with any features you enable or disable.
# Run this command to create a new task (or re-run a previously created task). 
# In my case, I’m planning to enable .NET 3.5 SP1 so I’ve created the task name as shown below. 
# Create the name that makes sense for you.
New-OSBuildTask -TaskName $taskName -EnableNetFX3

New-OSBuild -Download -Execute -ByTaskName $taskName
#2024-10-03-095139 -> 2024-10-03-103946

# copy the autounatted.xml here (decide if this is BIOS of UEFI)
Invoke-Item -Path "O:\OSDBuilder\OSBuilds\$($imageName)\OS"

Get-OSBuilds

## get rid of the press any key button

#1) Delete efisys.bin and cdboot.efi in extracted setup media in \efi\microsoft\boot
Get-ChildItem -Path "O:\OSDBuilder\OSBuilds\$($imageName)\OS\efi\microsoft\boot"


Move-Item -Path "O:\OSDBuilder\OSBuilds\$($imageName)\OS\efi\microsoft\boot\efisys.bin" -Destination "O:\Temp\$($osType)\efi\microsoft\boot\efisys.bin"
Move-Item -Path "O:\OSDBuilder\OSBuilds\$($imageName)\OS\efi\microsoft\boot\cdboot.efi" -Destination "O:\Temp\$($osType)\efi\microsoft\boot\cdboot.efi"

Copy-Item -Path "O:\OSDBuilder\OSBuilds\$($imageName)\OS\efi\microsoft\boot\efisys_noprompt.bin" -Destination "O:\Temp\$($osType)\efi\microsoft\boot\efisys_noprompt.bin"
Copy-Item -Path "O:\OSDBuilder\OSBuilds\$($imageName)\OS\efi\microsoft\boot\cdboot_noprompt.efi" -Destination "O:\Temp\$($osType)\efi\microsoft\boot\cdboot_noprompt.efi"

#2) Rename efisys_noprompt.bin to efisys.bin
Rename-Item -Path "O:\OSDBuilder\OSBuilds\$($imageName)\OS\efi\microsoft\boot\efisys_noprompt.bin" -NewName "O:\OSDBuilder\OSBuilds\$($imageName)\OS\efi\microsoft\boot\efisys.bin"
#3) Rename cdboot_noprompt.efi to cdboot.efi
Rename-Item -Path "O:\OSDBuilder\OSBuilds\$($imageName)\OS\efi\microsoft\boot\cdboot_noprompt.efi" -NewName "O:\OSDBuilder\OSBuilds\$($imageName)\OS\efi\microsoft\boot\cdboot.efi"


#region autounattend - BIOS
Copy-Item -Path "O:\Temp\autounattend\desktop_bios\autounattend.xml" -Destination "O:\OSDBuilder\OSBuilds\$($imageName)\OS\autounattend.xml"

#burn the updated iso, with the unattended XML file included
New-OSBMediaISO -FullName "O:\OSDBuilder\OSBuilds\$($imageName)"
#New-OSBMediaISO -FullName "O:\OSDBuilder\OSBuilds\$windowsServer2022ReleaseName"
#pick OSBuild - (pushed up all updates, and enabled netfx)

#ISO should be stored in following directory:
Invoke-Item -Path "O:\OSDBuilder\OSBuilds\$($imageName)\ISO"

#move ISO to the centralized repository of updated iso files - still on the OSDS server

$updatedIsoName = (Get-ChildItem -Path "O:\OSDBuilder\OSBuilds\$($imageName)\ISO").Name
Test-Path -Path "O:\OSDBuilder\OsBuilds\$($imageName)\ISO\$($updatedIsoName)"

#BIOS - core
Move-Item -Path "O:\OSDBuilder\OsBuilds\$($imageName)\ISO\$($updatedIsoName)" -Destination "O:\ISO\updated_unattended\$($osType)\$($osType)ent_$($dateISOName)_untd_nprmpt_bios.iso" -Verbose

#copy file to the ISO repository (NFS share)
Invoke-Item -Path "O:\ISO\updated_unattended\$($osType)"
#endregion

#region autounattended - UEFI
Copy-Item -Path "O:\Temp\autounattend\desktop_uefi\autounattend.xml" -Destination "O:\OSDBuilder\OSBuilds\$($imageName)\OS\autounattend.xml"

#burn the updated iso, with the unattended XML file included
New-OSBMediaISO -FullName "O:\OSDBuilder\OSBuilds\$($imageName)"
#New-OSBMediaISO -FullName "O:\OSDBuilder\OSBuilds\$windowsServer2022ReleaseName"
#pick OSBuild - (pushed up all updates, and enabled netfx)

#ISO should be stored in following directory:
Invoke-Item -Path "O:\OSDBuilder\OSBuilds\$($imageName)\ISO"

#move ISO to the centralized repository of updated iso files - still on the OSDS server

$updatedIsoName = (Get-ChildItem -Path "O:\OSDBuilder\OSBuilds\$($imageName)\ISO").Name
Test-Path -Path "O:\OSDBuilder\OsBuilds\$($imageName)\ISO\$($updatedIsoName)"

#UEFI - core
Move-Item -Path "O:\OSDBuilder\OsBuilds\$($imageName)\ISO\$($updatedIsoName)" -Destination "O:\ISO\updated_unattended\$($osType)\$($osType)ent_$($dateISOName)_untd_nprmpt_uefi.iso" -Verbose

#UEFI - desktop experience
#Move-Item -Path "O:\OSDBuilder\OsBuilds\$($imageName)\ISO\$($updatedIsoName)" -Destination "O:\ISO\updated_unattended\$($osType)\$($osType)dtc_$($dateISOName)_untd_nprmpt_uefi.iso" -Verbose


#copy file to the ISO repository (NFS share)
Invoke-Item -Path "O:\ISO\updated_unattended\$($osType)"

#endregion

#Copy the image to your ISO repository
```