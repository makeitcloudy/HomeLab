
```powershell
#region OSDBuilder, OSD, OSDSUS - installation
#https://github.com/OSDeploy/

Set-ExecutionPolicy ByPass -Scope CurrentUser -Force
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

## here before proceeding make sure your OSDBuilder version uses the latest OSD and OSDSUS releases
# find in psgallery
@('OSDSUS','OSDBuilder','OSD').ForEach({
    Find-Module -Name $_ -AllVersions | Select-Object -First 1 | Select-Object Version,Name,Repository,Description
})
#24.9.13.1  OSDSUS      PSGallery  
#23.2.21.1  OSDBuilder  PSGallery  
#24.10.1.1  OSD         PSGallery  2024 October 24H2 Update

# find the versions installed locally
Get-Module -Name OSDBuilder,OSD,OSDSUS -ListAvailable | Select-Object Version,Name,ModuleType,ExportedCommands | Sort-Object -Descending Name

$osdsus_latestVersion     = '24.9.13.1'
$osdbuilder_latestVersion = '23.2.21.1'
$osd_latestVersion        = '24.10.1.1' #2024 October 24H2 Update

Get-Module -Name OSD -ListAvailable
$osd_defaultInstallVersion = '24.9.30.1'

Install-Module -Name OSDBuilder -MinimumVersion $osdbuilder_latestVersion -Verbose

## during the installation process, OSDBuilder installs the OSD within version 24.9.30.1
# OSD 24.9.30.1 - contains the 2024 September Update
# Find-Module -Name OSD -RequiredVersion 24.9.30.1
# Find-Module -Name OSD -RequiredVersion $osd_latestVersion
## hence uninstall the 
Uninstall-Module -Name OSD -RequiredVersion $osd_defaultInstallVersion -Force
Install-Module -Name OSD -MinimumVersion $osd_latestVersion  -Force

Install-Module OSDSUS -MinimumVersion $osdsus_latestVersion -Force

Get-OSDBuilder -SetHome O:\OSDBuilder
Get-OSDBuilder -CreatePaths
#endregion

#region - update - OSDBuilder, OSDSUS
OSDBuilder -UpdateModule
OSDBuilder -Update
Update-OSDSUS

###

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
#endregion

#region - update ISO
Import-Module -Name OSDBuilder,OSD,OSDSUS -Force
Get-Module -Name OSDBuilder,OSD,OSDSUS -ListAvailable | Select-Object Version,Name,ModuleType,ExportedCommands | Sort-Object -Descending Name
#endregion

#0. Create Folder Structure - IF the folders are there skip this step
New-Item -ItemType Directory -Path 'O:\ISO\notUpdated_evalCenter\w2k19'
New-Item -ItemType Directory -Path 'O:\ISO\notUpdated_evalCenter\w2k22'

# grab the windows server iso
#https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022

New-Item -ItemType Directory -Path 'O:\ISO\updated_unattended\w2k19'
New-Item -ItemType Directory -Path 'O:\ISO\updated_unattended\w2k22'

New-Item -ItemType Directory -Path "O:\Temp\w10\efi\microsoft\boot\"
New-Item -ItemType Directory -Path "O:\Temp\w11\efi\microsoft\boot\"
New-Item -ItemType Directory -Path "O:\Temp\w2k19\efi\microsoft\boot\"
New-Item -ItemType Directory -Path "O:\Temp\w2k22\efi\microsoft\boot\"

#1. Download from the Eval Center ISO's to isoFolder - if the iSO are there skip it
#2. Initialize variables
$osType        = "w2k22"                         # w2k19, w2k22

$date          = Get-Date -Format ('yyyyMMdd')
$dateISOName   = Get-Date -Format ('yyMM')
$taskName      = "$($date)_$($osType)_patching"  # taskName will vary depending from the OS release and Date (w10_21H2_LTSC, w10_22H2, w11_23H2)
$isoFolder     = "O:\ISO\notUpdated_evalCenter\$($osType)"
Get-ChildItem -Path $isoFolder | Select-Object Length,LastWriteTime,Name

$isoName = 'w2k22_eval.iso'

$isoSourcePath = Join-Path -Path $isoFolder -ChildPath $isoName

Mount-DiskImage -ImagePath $isoSourcePath -Verbose

# 2. Import iso
#WARNING: This version of OSDBuilder - 23.2.21.1 - only supports:
#WARNING: Windows 10 1607 - 21H2
#WARNING: Windows 11 21H2 - 22H2
#WARNING: Windows Server 2016 1607 - Windows Server 2022 21H1

# ImageIndex 1: Windows 2022 Standard
# ImageIndex 2: Windows 2022 Standard (Desktop Experience)
# ImageIndex 3: Windows 2022 Datacenter
# ImageIndex 4: Windows 2022 Datacenter (Desktop Experience)

#standard - core - 1
#standard - dexp - 2
#datacenter - core - 3
#datacenter - dexp - 4

Import-OSMedia -Index 3 -SkipGrid #4 indexes in windows server 2022, comparing to 1 for w10 22H2 (both from eval center)
# 2024.10.03 - 10.0.20348.587
# 2024-10-03-093811 -> 2024-10-03-094229

# Unmount Diskimage
Dismount-DiskImage -ImagePath $isoSourcePath -Verbose

#Get-OSMedia -GridView -Verbose
Get-OSMedia | Where-Object {$_.MediaType -eq 'OSImport'} | Select-Object MediaType,ModifiedTime,Superseded,Revision,Name | Format-Table
(Get-OSMedia -Newest).Name
#pick:
#MediaType: OSImport
#Superseded: False
#Revision: OK
#Name: Goes hand in hand with $isoName code - 20348.587

#$imageName = 'Windows Server 2022 Datacenter Evaluation x64 21H2 20348.587' # it is a result of the (Get-OSMedia -Newest).Name
$imageName = 'Windows Server 2022 Datacenter Evaluation x64 21H2 20348.587'

## here before proceeding make sure your OSDBuilder version uses the latest OSD and OSDSUS releases
## go to region update - OSDBuilder, OSDSUS


#Update-OSMedia -Download -Execute
# OS Media does not have the latest WSUSXML (MS Updates)
# Use the following command before furnning New-OSBuild
Update-OSMedia -Name $imageName -Download -Execute
#2024-10-03-095111 -> 2024-10-03-100426 #w2k22 core


# Now that the OS Media is imported and updated, you must create a task that you’ll use to re-run the monthly updates with any features you enable or disable.
# Run this command to create a new task (or re-run a previously created task). 
# In my case, I’m planning to enable .NET 3.5 SP1 so I’ve created the task name as shown below. 
# Create the name that makes sense for you.
New-OSBuildTask -TaskName $taskName -EnableNetFX3

New-OSBuild -Download -Execute -ByTaskName $taskName
#2024-10-03-100702 -> 2024-10-03-101939
#pick the OSImport

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
Copy-Item -Path "O:\Temp\autounattend\server_bios\autounattend.xml" -Destination "O:\OSDBuilder\OSBuilds\$($imageName)\OS\autounattend.xml"

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
Move-Item -Path "O:\OSDBuilder\OsBuilds\$($imageName)\ISO\$($updatedIsoName)" -Destination "O:\ISO\updated_unattended\$($osType)\$($osType)dtc_$($dateISOName)_core_untd_nprmpt_bios.iso" -Verbose

#BIOS - desktop experience
#Move-Item -Path "O:\OSDBuilder\OsBuilds\$($imageName)\ISO\$($updatedIsoName)" -Destination "O:\ISO\updated_unattended\$($osType)\$($osType)dtc_$($dateISOName)_untd_nprmpt_bios.iso" -Verbose


#copy file to the ISO repository (NFS share)
Invoke-Item -Path "O:\ISO\updated_unattended\$($osType)"
#endregion

#region autounattended - UEFI
Copy-Item -Path "O:\Temp\autounattend\server_uefi\autounattend.xml" -Destination "O:\OSDBuilder\OSBuilds\$($imageName)\OS\autounattend.xml"

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
Move-Item -Path "O:\OSDBuilder\OsBuilds\$($imageName)\ISO\$($updatedIsoName)" -Destination "O:\ISO\updated_unattended\$($osType)\$($osType)dtc_$($dateISOName)_core_untd_nprmpt_uefi.iso" -Verbose

#UEFI - desktop experience
#Move-Item -Path "O:\OSDBuilder\OsBuilds\$($imageName)\ISO\$($updatedIsoName)" -Destination "O:\ISO\updated_unattended\$($osType)\$($osType)dtc_$($dateISOName)_untd_nprmpt_uefi.iso" -Verbose


#copy file to the ISO repository (NFS share)
Invoke-Item -Path "O:\ISO\updated_unattended\$($osType)"

#endregion

#Copy the image to your ISO repository
```