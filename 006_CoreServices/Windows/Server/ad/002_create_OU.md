# Webster Lab - OU structure

```powershell
#create the OU structure $ADDomain.$TLD
$ADDomain = "lab"
$TLD = "local"
$Protect = $True
#Create OUs
#Top level OU - Lab
New-ADOrganizationalUnit -Name "Lab" -Path "dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
#Second-level OUs under Lab
New-ADOrganizationalUnit -Name "Accounts" -Path "ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name "Citrix" -Path "ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose

New-ADOrganizationalUnit -Name "Groups" -Path "ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name "Infrastructure" -Path "ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -Verbose
New-ADOrganizationalUnit -Name "Parallels" -Path "ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
#Third-level OUs under Lab/Accounts
New-ADOrganizationalUnit -Name "Admin" -Path "ou=Accounts,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -Verbose
New-ADOrganizationalUnit -Name "Service" -Path "ou=Accounts,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name "Users" -Path "ou=Accounts,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
#Third-level OUs under Lab/Citrix
New-ADOrganizationalUnit -Name "CVAD2103" -Path "ou=Citrix,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
#Third-level OUs under Lab/Groups
New-ADOrganizationalUnit -Name "Admin" -Path "ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name "Users" -Path "ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
#Third-level OUs under Lab/Infrastructure
New-ADOrganizationalUnit -Name "Citrix" -Path "ou=Infrastructure,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name "Microsoft" -Path "ou=Infrastructure,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name "Parallels" -Path "ou=Infrastructure,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name "VMware" -Path "ou=Infrastructure,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
#Third-level OUs under Lab/Parallels
New-ADOrganizationalUnit -Name "RDS" -Path "ou=Parallels,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name "RemotePC" -Path "ou=Parallels,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name "VDI" -Path "ou=Parallels,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
```
