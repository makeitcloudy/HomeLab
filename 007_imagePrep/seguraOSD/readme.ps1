#Requires -RunAsAdministrator

#Run this as Administrator otherwise won't be able to install modules, neither run the OSDBuilder properly
#2022.01.12 - there is an issue with OSDBuilder which prevents chaning the homePath from default location
# when you change it it throws an error message mentioned here: https://github.com/OSDeploy/OSDBuilder/issues/72
# thats why the main C drive is 100GB in side to collect all the images

Find-Module -Name $osdBuilderModuleName -AllVersions | Out-GridView
Find-Module -Name $osdModuleName -AllVersions | Out-GridView

#region OSDBuilder - 2022 - EVERY TIME - initialize variables 
#O drive is not needed anymore, as there won't be any extra drives but everything with OSDBuilder will be pefromed on C drive
#$OsDataDriveLetter                      = 'O'
$OsDataDiskNumber                       = 1
$OsDataDiskLabel                        = 'OsData'
$OSdataDiskFileSystem                   = 'ReFs' #ReFs can also be mounted as a directory in the filesystem - it works 2022.01.15

$osdModuleName                          = "OSD"

$osdBuilderModuleName                   = "OSDBuilder"
$osdBuilder2012R2SupportModuleVersion  = "19.5.20.0" #dziala z windows 2012R2 - OSBuilder can be used for updating
$osdBuilderModuleVersion                = "21.12.15.1" #dziala z windows 2016 1607
$powershellModulePath                   = "$env:ProgramFiles\WindowsPowerShell\Modules"
#$osdBuilderPath                         = Join-Path -Path "$($OsDataDriveLetter+":")" -ChildPath 'OSDBuilder\SeguraOSD'
$osdBuilderPathCdrive                   = Join-Path -Path $env:SystemDrive -ChildPath $osdBuilderModuleName

$osdSusModuleName                       = "OSDSUS"
$osdSusModuleVersion                    = "22.1.11.1"

$smbLocalPath                           = "I:"
$smbRemotePathIsoMsNoUpdate             = '\\emc.lab\_labEmc\isoMsNoUpdate'
$resourcesIsoOrgFolderName              = 'org'
$resourcesIsoUpdatedFolderName          = 'updated'
$resourcesIsoPath                       = "$env:SystemDrive\LabResourcesIso" # it contains iso files downloaded from microsft (not updated)
$resourcesIsoOrgPath                    = Join-Path -Path $resourcesIsoPath -ChildPath $resourcesIsoOrgFolderName
$resourcesIsoUpdatedPath                = Join-Path -Path $resourcesIsoPath -ChildPath $resourcesIsoUpdatedFolderName

$isoWindows2012FileName                 = 'w2k12R2.iso'
$isoWindows2016FileName                 = 'w2k16.iso'
$isoWindows2019FileName                 = 'w2k19.iso'
$isoWindows2022FileName                 = 'w2k22.iso'
$isoWindows10_19H2FileName              = '10 19H2 EnterpriseN x64 en-US.iso'

$isoWindows2012ImagePath                = Join-Path -Path $resourcesIsoOrgPath -ChildPath $isoWindows2012FileName
$isoWindows2016ImagePath                = Join-Path -Path $resourcesIsoOrgPath -ChildPath $isoWindows2016FileName
$isoWindows2019ImagePath                = Join-Path -Path $resourcesIsoOrgPath -ChildPath $isoWindows2019FileName
$isoWindows2022ImagePath                = Join-Path -Path $resourcesIsoOrgPath -ChildPath $isoWindows2022FileName
$isoWindows10_19H2ImagePath             = Join-Path -Path $resourcesIsoOrgPath -ChildPath $isoWindows10_19H2FileName
#endregion

#region Drive Initialization - 2022 - ONE TIME - drive initialization and mounting as OSDBuilder folder
#it turns out that OSDBuilder crashes when another drive than C drive is being used, so it has to be stored on the C drive
Get-Disk
Get-Partition
#compmgmt.msc
#diskmgmt.msc
Get-Disk
Initialize-Disk -Number $OsDataDiskNumber -Verbose #this is the extra drive added for the purpose of OSDBuilder
Clear-Disk -Number $OsDataDiskNumber -RemoveData -Verbose
Initialize-Disk -Number $OsDataDiskNumber -Verbose
New-Partition -DiskNumber $OsDataDiskNumber -UseMaximumSize | Format-Volume -FileSystem $OSdataDiskFileSystem -NewFileSystemLabel $OsDataDiskLabel

Get-disk 0 | Get-Partition #Os drive - here windows is installed
#https://winaero.com/remove-drive-letter-windows-10/
#Remove-PartitionAccessPath -DiskNumber 0 -PartitionNumber 1 -AccessPath O:
#Remove-PartitionAccessPath -DiskNumber 0 -PartitionNumber 2 -AccessPath O:
Get-disk 1 | Get-Partition #OsData drive - here is your spare data drive where the iso will be located along with OSBuilder HomePath
#Get-Partition -DiskNumber 0 | Set-Partition -NewDriveLetter $OsDataDriveLetter
#ustaw na drugiej partycji 100GB dysku litere O
#region - 2022 - assign a letter to the created partition - THIS is NOT needed when the drive is bound to the folder
Get-Partition -DiskNumber $OsDataDiskNumber -PartitionNumber 2 | Set-Partition -NewDriveLetter $OsDataDriveLetter
Invoke-Item -Path $($OsDataDriveLetter+":")
#endregion

#region - 2022 - mount the partition as folder on the NTFS filesystem
$disk = Get-Disk -Number $OsDataDiskNumber
$disk | Initialize-Disk -PartitionStyle GPT
$disk | New-Partition -UseMaximumSize
$partition = Get-Partition -DiskNumber $disk.Number
$partition | Format-Volume -FileSystem NTFS -Confirm:$false
New-Item -Path 'C:\OSDBuilder' -ItemType Directory -Verbose
Get-Item -Path 'C:\OSDBuilder'

$partition | Add-PartitionAccessPath -AccessPath 'C:\OSDBuilder'
$partition | Remove-PartitionAccessPath -AccessPath 'C:\OSDBuilder' -Verbose
Get-Command -Noun PartitionAccessPath
#endregion

#region - 2022 - disk performance
#http://woshub.com/how-to-measure-disk-iops-using-powershell/
#https://github.com/Microsoft/diskspd
diskspd.exe –c50G -d300 -r -w40 -t8 -o32 -b64K -Sh -L O:\diskpsdtmp.dat > DiskSpeedResults.txt
#endregion
#endregion

#region OSDBuilder - 2022 - EVERY TIME - import module so the commandlets begin to be available
Import-Module $osdModuleName
#Import-Module $osdBuilderModuleName
#endregion

#Dell EMC - should be up
#region - 2022 - IT WORKS - ONE TIME - COPY iso files from SMB share (Dell Emc) to the local drive
New-SmbMapping -LocalPath $smbLocalPath -RemotePath $smbRemotePathIsoMsNoUpdate -Verbose
$isoFile = (Get-ChildItem -Path $smbLocalPath).Name
$isoFile.ForEach({
    Copy-Item -Path (Join-Path -Path $smbLocalPath -ChildPath $_) -Destination $resourcesIsoPath -Verbose
})
#get-command -noun SMBMapping
Get-SmbMapping | Remove-SmbMapping #unmount the drive (only one is mapped at this stage)
#Copy-Item -Path $smbLocalPath -Recurse -Destination $resourcesIsoPath -Verbose
#endregion

#region OSDBuilder - 2022 - ONE TIME - INSTALLATION of module from PowerShell Gallery
#get-command -Noun Module
#Find-Module -Name $moduleName -AllVersions | Select-Object Version,Name,Description | Format-List
Find-Module -Name $osdModuleName -AllVersions
Find-Module -Name $osdBuilderModuleName -AllVersions | Out-GridView
Find-Module -Name $osdSusModuleName -AllVersions

#2022.01.15 - Anything newer than 2012R2
#Install-Module -Name $osdBuilderModuleName -MaximumVersion $osdBuilderModuleVersion -Scope AllUsers -Verbose
#2022.01.15 - Windows 2012R2
#Install-Module -Name $osdBuilderModuleName -MaximumVersion $osdBuilder2012R2SupportModuleVersion -Scope AllUsers -Verbose
Install-Module -Name $osdBuilderModuleName -RequiredVersion $osdBuilder2012R2SupportModuleVersion -Scope AllUsers -Verbose
Get-OSBuilder -CreatePaths -Verbose
Get-OSBuilder -Verbose
#Get-module -Name $osdSusModuleName -ListAvailable
#Find-Module -Name $osdSusModuleName -AllVersions
Install-Module -Name $osdSusModuleName -RequiredVersion '21.7.13.1' -Scope AllUsers -Verbose #this is the latest version supporting 2012R2 and windows 7


#region OSDBuilder - RELICT CODE
#OSDBuilder\SeguraOSD
#$env:PSModulePath.split(';')
###
#Invoke-Item -Path 'C:\Users\piotrek\Documents\WindowsPowerShell\Modules'
#Invoke-Item -Path 'C:\Windows\system32\WindowsPowerShell\v1.0\Modules'
#Invoke-Item -Path 'C:\Program Files\Mellanox\MLNX_VPI\Tools\WMI\Modules'
#Invoke-Item -Path 'C:\Program Files\Mellanox\MLNX_CIMProvider\WMI\Modules'

Uninstall-Module $osdBuilderModuleName -AllVersions -Force
Install-Module $osdBuilderModuleName -Force #once this is executed the modules exist within the directory $env:ProgramFiles\WindowsPowerShell\Modules, it is also listed among available modules
Import-Module $osdBuilderModuleName -Force

#OSDBuilder -Update #cos nie tak w wrsji 21.12.15.1 
#WARNING: Uninstall-Module -Name OSDBuilder -AllVersions -Force
#WARNING: Remove-Module -Name OSDBuilder -Force
#WARNING: Install-Module -Name OSD -Force
#WARNING: The version '21.12.15.1' of module 'OSD' is currently in use. Retry the operation after closing the applications.
#WARNING: Install-Module -Name OSDBuilder -Force
#WARNING: The version '21.12.15.1' of module 'OSD' is currently in use. Retry the operation after closing the applications.
#WARNING: Import-Module -Name OSDBuilder -Force
#WARNING: Close all open PowerShell sessions before using OSDBuilder
#it does not do much here, but there is some network traffic which is being generated

#Remove-Module OSDBuilder -Force
#endregion
#endregion

#region OSDBuilder - 2022 - ONE TIME - CHECK the installed module
Get-Module -Name $osdModuleName -ListAvailable        #check version of the installed module 22.1.11.2
Get-Module -Name $osdBuilderModuleName -ListAvailable #check version of the installed module 21.12.15.1
Get-Module -Name $osdSusModuleName -ListAvailable     #check version of the installed module 22.1.11.1

OsD -Verbose
OSDBuilder -Verbose
Get-OSDBuilder
#endregion

#region OSDBuilder - 2022 - ONE TIME - REMOVE the installed module
Uninstall-Module -Name $osdBuilderModuleName -Verbose
Uninstall-Module -Name $osdModuleName -Verbose
# Once the module is installed / loaded within the powershell session, there is a dll hook and it is not possible 
# to remove the OSD directory. First close the powershell then remove the directories from the filesystem
Remove-Module -Name $osdBuilderModuleName
Remove-Item -Path (Join-Path -Path $powershellModulePath -ChildPath $osdModuleName) -Recurse -Force -Verbose
Remove-Item -Path (Join-Path -Path $powershellModulePath -ChildPath $osdBuilderModuleName) -Recurse -Force -Verbose
#in case the OSDBuilder writes to the C drive then run the following
Remove-Item -Path $osdBuilderPathCdrive -Recurse -Force -Verbose
Invoke-Item -Path $powershellModulePath #here the OSDBuilder is installing the sources
#endregion

#region OSMedia - 2022 - IT WORKS - list details about the Images
Get-OSMedia -Updates Update -Revision OK -GridView
#endregion

#region OSDBuilder - 2022 - UPDATE the installed version - before updating reopen the powershell ISE and start with the UPDATE
#module OSD along with OSDBuilder is installed here: 
#Invoke-Item -Path $powershellModulePath
#home dla OSDBuildera domyslnie to C:\OSDBuilder zeby to zmienic trzeba wywolac nastepujace zaklecie
#https://4sysops.com/archives/automate-offline-servicing-of-windows-images-with-the-powershell-module-osdbuilder/
#OSDBuilder -SetHome C:\OSDBuilder
#OSDBuilder -SetHome $OSDBuilderPath #nie dziala wali potem bledem
#show the version of the OSDBuilder and check if there are updates
#show some basic commands to update the OSMedia

#update he OSDBuilder
OSDBuilder -Update #it throws an error message  that the OSD is currently in use. Retry the operation after closing the application

#Things here are changing frequently so to make sure you have the latest, simply run the install command again or use this command

Update-Module -Name $osdModuleName -Force #Update the OSD Module - close the powershell session first then it will be possible to update the module
Update-Module -Name $osdBuilderModuleName -Force
Update-Module -Name $osdSusModuleName -Force
Update-OSDSUS

#endregion

OSDBuilder -Verbose #this lists the version of the builder and some commands
#OSDSUS -Verbose #it will list all updates I'm afraidOSDBuilder -Verbose #this lists the version of the builder and some commands

Import-Module OSD -Force #Finally don't forget to Import it before you run any of the functions
Import-Module OSDBuilder -Force

#region OSDSUS - UPDATE - 2022.01.14 - no idea what this is doing
#https://osdsus.osdeploy.com/release
# As a reminder, use this PowerShell command to update OSDSUS, and remember to close and reopen 
# your PowerShell Sessions before using the updated OSDSUS with OSDBuilder or OSDUpdate
## Update-OSDSUS #to make sure that OSDBuilder and OSDUpdate have the latest OSDSUS module, use this command
## Close powershell sessions, it is important to close and open PowerShell sessions and re-open before using 
## OSDBuilder or OSDUpdate to make sure they are using latest OSDSUS Catalogs
Get-OSDSUS -UpdateArch x64 -UpdateBuild 1607 -UpdateGroup SSU -UpdateOS 'Windows Server 2016'
#endregion


### START UPDATING THE IMAGES ###

#region OSDBuilder - 2022 - UPDATE ISO files
# Start-Process 'https://www.deploymentresearch.com/building-the-perfect-windows-server-2019-reference-image/'
#teraz potrzebujesz zamontowac iso ktore chcesz obrabiac OSD
#region OSDBuilder - 2022 - update ISO files - MOUNT iso image
Mount-DiskImage -ImagePath $isoWindows10_19H2ImagePath -StorageType ISO -Verbose
Mount-DiskImage -ImagePath $isoWindows2022ImagePath -StorageType ISO -Verbose #2022.01.13
Mount-DiskImage -ImagePath $isoWindows2019ImagePath -StorageType ISO -Verbose #2022.01.13
Mount-DiskImage -ImagePath $isoWindows2016ImagePath -StorageType ISO -Verbose #2022.01.12 - import-osmedia
Mount-DiskImage -ImagePath $isoWindows2012ImagePath -StorageType ISO -Verbose
#endregion

#region OSDBuilder - 2022 - update ISO files - UNMOUNT iso image
Dismount-DiskImage -ImagePath $isoWindows10_19H2ImagePath -StorageType ISO -Verbose
Dismount-DiskImage -ImagePath $isoWindows2022ImagePath -StorageType ISO -Verbose
Dismount-DiskImage -ImagePath $isoWindows2019ImagePath -StorageType ISO -Verbose
Dismount-DiskImage -ImagePath $isoWindows2016ImagePath -StorageType ISO -Verbose #2022.01.12 - 
Dismount-DiskImage -ImagePath $isoWindows2012ImagePath -StorageType ISO -Verbose
#endregion

#NOW START MESSING WITH OSDBuilder
#region OSDBuilder - 2022 - update ISO files - launch OSDBuilder to proceed with mounted iso
# OSDBuilder requires Original Microsoft Gold Image or ISO that has been unmodified
# POWERSHELL should be run ELEVATED
#
# choose the operating system Std/Dtc core/desktop experience - 2022.01.12 - picked nr 3
# here is the path C:\OSDBuilder\OSImport for imported operating systems
# Invoke-Item C:\OSDBuilder\OSImport
#get-help Import-OSMedia -Examples

#Import-OSMedia -ImageName 'Windows Server 2016 Datacenter' -Update ServerDatacenterACor -Verbose
#Import-OSMedia -Path "C:\OSDBuilder\OSImport\Windows Server 2016 Datacenter Evaluation x64 1607 14393.693" -Update ServerDatacenterACor -Verbose #OSmedia not found
#Import-OSMedia -EditionId ServerDatacenterACor -Update -Verbose
#Import-OSMedia -Update ServerDatacenterACor -BuildNetFX 

Get-PSDrive -Name C #show amount of space left on the drive before proceeding with the import of Iso and the update
#OSDBuilder -UpdateModule #how to update the OSDBuilder ?

# for this to work properly you'll have to have an up to date OSDSUS (after updating OSDSUS close and reopen powershell),
# simply run this funciton without any parameters it will find the images if you have mounted any,
# and let you know if it needs any updates
Import-OSMedia -Update -BuildNetFX -Verbose #Here the UPDATE process is launched

OSMedia #shows details about the iso file which was imported
OSMedia -Verbose

Get-PSDrive -Name C

#You can easily download the updates you need for your Imported OSMedia using the following command
OSDBuilder -Download OSMediaUpdates
#OSDBuilder -Download FeatureUpdates #this seems to be dedicated for DesktopOS not the Server OS

#after execution of this command there is following warning once the download is completed
#WARINING: Use the -Execute parameter to complete this task

#apply microsoft updates
#2016, 2019, 2022, w10 19H2 Enterprise
Update-OSMedia -Download -Execute -Verbose
#endregion
#Close powershell sessions, it is important to close and open PowerShell sessions and re-open before using OSDBuilder or OSDUpdate to make sure they are using latest OSDSUS Catalogs
Get-OSMedia
### New-OSBuildTask -OSMedia 
### get-help New-OSBuildTask -ShowWindow

#region OSDBuilder - 2022 - update ISO files - windows 2012R2 - DOES NOT WORK with my version of windows 2012R2
Get-OSDBuilder -Verbose #wersja 19.5.20.0
Get-OSDBuilder -CreatePaths
#Import-OSMedia -Update -BuildNetFX -Verbose #Here the UPDATE process is launched - this commandlet is for version which supports windows 2016 - windows 11
Import-OSMedia -UpdateOSMedia -OSDInfo -Verbose
Update-OSMedia -Download -Execute -OSDInfo -Verbose
#get-help Import-OSMedia -ShowWindow
#endregion

#region Create Build Task - enable NetFx3
Dismount-WindowsImageOSD -Discard
Get-OSMedia -GridView
Get-Command -Module OSD
#Get-OSMedia | Where-Object Name -like 'Windows 10 Enterprise x64 2009*' | Where-Object Revision -eq 'OK' | Where-Object Updates -eq 'Update' | foreach {Update-OSMedia -Download -Execute -Name
#Get-OSMedia | Where-Object {($_.Name -match "Windows 10|Windows Server") -and {($_.Revision -match "OK")}} -and {$_.Updates -match "Update"}}


Get-OSMedia | Where-Object {($_.Revision -match "OK") -and (($_.Name -match "Windows 10|Windows Server"))} | foreach {Update-OSMedia -Download -Execute -Name $_.Name -CreateISO}
#before running the New-OSBuild -Download -Execute run Update-OSMedia
Update-OSMedia -Name 'Windows Server 2016 Datacenter Evaluation x64 1607 14393.4886' -Download -Execute -Verbose

#wyglada na to ze mozna puscic new-osbuild task z parametrem -EnableNetFX wlaczy .neta w obrazie
#$taskName = 'Enable NetFx3'
#New-OSBuildTask -TaskName $taskName -EnableNetFx3

#New-OSBuild -DownloadUpdates -Execute -ByTaskName $taskName
#Update-OSMedia -Name 'Windows 10 Enterprise N x64 1909 18363.1139' -Download -Execute #2021.11. execute this command before running New-OSBuild for w10 1909
New-OSBuild -Download -Execute -EnableNetFX -CreateISO -SkipTask -Verbose
#New-OSBuild -Execute -ByTaskName $taskName #2022.01.13 - tested OK

New-OSBMediaISO

#get-help New-OSBuildTask -ShowWindow
Update-OSMedia -CreateISO
#Get-Command -Module OSD | Where-Object {$_.Name -match "ISO"}
##### Update-OSMedia -Download -Execute -CreateISO

#endregion
#endregion

## get-help Save-OSDBuilderDownload -ShowWindow
## Save-OSDBuilderDownload

get-command -Module OSDBuilder
get-help New-OSBMediaISO -ShowWindow

New-OSBMediaISO

#You can optionally copy the amd64 and x86 directories from ADK into OSBuilder\Content\Tools instead of having ADK installed
#C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools
#<OSBuilder SourcePath>\Content\Tools

#region some error messages
#Import-OSMedia : Cannot validate argument on parameter 'ImageName'. The argument "Windows Server 2016 Datacenter" does not belong to the set
#Windows 10 Education,Windows 10 Enterprise,
#Windows 10 Enterprise for Virtual Desktops, Windows 10 Enterprise 2016 LTSB, Windows 10 Enterprise LTSC,
#Windows 10 Pro, Windows 10 Pro Education, Windows 10 Pro for Workstations,
#Windows 10 Education N, Windows 10 Enterprise N, Windows 10 Enterprise N LTSC,
#Windows 10 Pro N, Windows 10 Pro Education N, Windows 10 Pro N for Workstations,
#Windows 11 Education, Windows 11 Education N,
#Windows 11 Enterprise, Windows 11 Enterprise for Virtual Desktops, Windows 11 Enterprise 2016 LTSB, Windows 11 Enterprise LTSC,
#Windows 11 Pro, Windows 11 Pro Education, Windows 11 Pro for Workstations,
#Windows 11 Enterprise N, Windows 11 Enterprise N LTSC,
#Windows 11 Pro N, Windows 11 Pro Education N, Windows 11 Pro N for Workstations,

#Windows Server Standard,
#Windows Server Datacenter,
#Windows Server 2019 Standard,
#Windows Server 2019 Standard (Desktop Experience),
#Windows Server 2019 Datacenter,
#Windows Server 2019 Datacenter (Desktop Experience),
#Windows Server 2022 Standard,
#Windows Server 2022 Standard (Desktop Experience),
#Windows Server 2022 Datacenter,
#Windows Server 2022 Datacenter (Desktop Experience)
#specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again.
#endregion
