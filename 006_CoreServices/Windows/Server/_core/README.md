# Server core - code

## Initial Configuration



## Install ADDS

```powershell
Get-WindowsFeature
Install-windowsFeature -Name "AD-Domain-Services" -IncludeManagementTools
Install-AddsForest -DomainName "domain.name" -InstallDns
# SafeModeAdminPassword
# A
Get-ADDomain
Get-ADDomainController
```

## Join AD Domain

```powershell
Get-NetAdapter
# the dns address corresponds to the DC address
Set-DnsClientServerAddress -InterfaceAlias 'Ethernet' -ServerAddress ('10.0.0.1')
Add-Computer -NewName 'targetNode' -DomainName 'domain.name' -Restart
#put the account credentials allowed to add machines to the domain
```

## Customize the ISO

```powershell
# 1. copy the content of the ISO to some directory
# 2. copy the WIM file into separate location
Get-WindowsImage -ImagePath [path to the .wim file]
Remove-WindowsImage -ImagePath [path to the .wim file] -index 1
Remove-WindowsImage -ImagePath [path to the .wim file] -index 1
Remove-WindowsImage -ImagePath [path to the .wim file] -index 2
# the indexes are going down with it's numbers, the steps above will only leave the the DataCenter Core

```

### Apply the windows updates

```powershell
# www.catalog.update.microsoft.com/Home.apsx
## Download cummulative updates for the desired OS

# create an offline folder
Mount-WindowsImage -ImagePath [path to the .wim file] -Index 1 -Path c:\offline

# c:\staging\updates contains the cummulative updates (.msu) package
Add-WindowsPackage -path c:\offline -PackagePath c:\staging
updates
```

### Apply windows drivers

```powershell
Add-WindowsDriver -Path c:\offline -Driver c:\staging\drivers -Recurse
```

### Apply windows packages

```powershell

```

### Deploy custom image

```powershell
Dismount-WindowsImage -Path c:\offline -save
# ADK installed on the OSD node
# Deployment and Imaging Tools Environment  - run as administrator
# c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools
cd amd64
cd Oscdimg
## in the old days the etfsboot.com was used for the bios subsystem
## the oscdimg.exe uses the efisys|efisys_noprompt bin files - are used for the UEFI
oscdimg -m -o -u2 -udfver102 -bootdata:2#p0,e,betfsboot.com#pEF,e,befisys.bin c:\folderName c:\isoFileName.iso
## if everything goes well it will create the bootable iso with all the modifications done
```