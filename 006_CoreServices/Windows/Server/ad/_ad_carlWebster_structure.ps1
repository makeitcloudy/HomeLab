# This piece of code comes from Carl Webster Lab setup
$ADDomain    = 'lab'
$TLD         = 'local'
$DomainName  = "$ADDomain.$TLD"
$DnsZoneName = "$ADDomain.$TLD" #lab.local
$UserPwd     = Read-Host -AsSecureString -Prompt 'Enter password'

#region - domain structure - OU
$Protect = $True
#Create OUs
#Top level OU - Lab
New-ADOrganizationalUnit -Name 'Lab' -Path "dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
#Second-level OUs under Lab
New-ADOrganizationalUnit -Name 'Accounts' -Path "ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name 'Citrix' -Path "ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose

New-ADOrganizationalUnit -Name 'Groups' -Path "ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name 'Infrastructure' -Path "ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -Verbose
New-ADOrganizationalUnit -Name 'Parallels' -Path "ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
#Third-level OUs under Lab/Accounts
New-ADOrganizationalUnit -Name 'Admin' -Path "ou=Accounts,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -Verbose
New-ADOrganizationalUnit -Name 'Service' -Path "ou=Accounts,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name 'Users' -Path "ou=Accounts,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
#Third-level OUs under Lab/Citrix
New-ADOrganizationalUnit -Name 'CVAD-Version' -Path "ou=Citrix,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
#Third-level OUs under Lab/Groups
New-ADOrganizationalUnit -Name 'Admin' -Path "ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name 'Users' -Path "ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
#Third-level OUs under Lab/Infrastructure
New-ADOrganizationalUnit -Name 'Citrix' -Path "ou=Infrastructure,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name 'Microsoft' -Path "ou=Infrastructure,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name 'Parallels' -Path "ou=Infrastructure,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name 'VMware' -Path "ou=Infrastructure,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
#Third-level OUs under Lab/Parallels
New-ADOrganizationalUnit -Name 'RDS' -Path "ou=Parallels,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name 'RemotePC' -Path "ou=Parallels,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
New-ADOrganizationalUnit -Name 'VDI' -Path "ou=Parallels,ou=Lab,dc=$ADDomain,dc=$TLD" -ProtectedFromAccidentalDeletion $Protect -verbose
#endregion

#region - domain structure - create group
$Protect = $False

New-ADGroup -DisplayName 'CtxAdmins' -GroupCategory 'Security' -GroupScope 'Global' -Name "CtxAdmins" -Path "ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "CtxAdmins$"
New-ADGroup -DisplayName 'CtxHelpdesk' -GroupCategory 'Security' -GroupScope 'Global' -Name "CtxHelpdesk" -Path "ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "CtxHelpdesk$"
New-ADGroup -DisplayName 'RASAdmins' -GroupCategory 'Security' -GroupScope 'Global' -Name "RASAdmins" -Path "ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "RASAdmins$"
New-ADGroup -DisplayName 'RASHelpdesk' -GroupCategory 'Security' -GroupScope 'Global' -Name "RASHelpdesk" -Path "ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "RASHelpdesk$"
New-ADGroup -DisplayName 'VMwAdmins' -GroupCategory 'Security' -GroupScope 'Global' -Name "VMwAdmins" -Path "ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "VMwAdmins$"
New-ADGroup -DisplayName 'VMwHelpdesk' -GroupCategory 'Security' -GroupScope 'Global' -Name "VMwHelpdesk" -Path "ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "VMwHelpdesk$"

#user security groups
New-ADGroup -DisplayName 'RASUsers' -GroupCategory 'Security' -GroupScope 'Global' -Name "RASUsers" -Path "ou=Users,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "RASUsers$"
New-ADGroup -DisplayName 'XAUsers' -GroupCategory 'Security' -GroupScope 'Global' -Name "XAUsers" -Path "ou=Users,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "XAUsers$"
New-ADGroup -DisplayName 'XDUsers' -GroupCategory 'Security' -GroupScope 'Global' -Name "XDUsers" -Path "ou=Users,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "XDUsers$"
#endregion

#region - domain structure - create Admin user
New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'CtxAdmin' `
-Enabled $True `
-Name 'CtxAdmin' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path "OU=Admin,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD" `
-SamAccountName 'CtxAdmin' `
-UserPrincipalName "CtxAdmin@$domainName"

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'RASAdmin' `
-Enabled $True `
-Name 'RASAdmin' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path "OU=Admin,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD" `
-SamAccountName 'RASAdmin' `
-UserPrincipalName "RASAdmin@$domainName"

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'UMSAdmin' `
-Enabled $True `
-Name 'UMSAdmin' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path "OU=Admin,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD" `
-SamAccountName 'UMSAdmin' `
-UserPrincipalName "UMSAdmin@$domainName"

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'VMwAdmin' `
-Enabled $True `
-Name 'VMwAdmin' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path "OU=Admin,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD" `
-SamAccountName 'VMwAdmin' `
-UserPrincipalName "VMwAdmin@$domainName"
#endregion

#region - domain structure - create service account
#Create the service account DNSDynamicUpdate DNS Dynamic Update Credentials account for DHCP
New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-Description 'DO NOT CHANGE THE PASSWORD OR DELETE/DISABLE ACCOUNT' `
-DisplayName 'DNSDynamicUpdate' `
-Enabled $True `
-GivenName 'DNSDynamicUpdate' `
-Name 'DNSDynamicUpdate' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path "OU=Service,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD" `
-SamAccountName 'DNSDynamicUpdate' `
-UserPrincipalName "DNSDynamicUpdate@$domainName"

#Create the service account svc_CtxVMware for VVAD hosting connection
New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-Description 'DO NOT CHANGE THE PASSWORD OR DELETE/DISABLE ACCOUNT' `
-DisplayName 'svc_CtxVMware' `
-Enabled $True `
-GivenName 'svc_CtxVMware' `
-Name 'svc_CtxVMware' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path "OU=Service,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD" `
-SamAccountName 'svc_CtxVMware' `
-UserPrincipalName "svc_CtxVMware@domainName"

#Create a service account ldap_query for LDAP Queries
New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-Description 'DO NOT CHANGE THE PASSWORD OR DELETE/DISABLE ACCOUNT' `
-DisplayName 'ldap_query' `
-Enabled $True `
-GivenName 'ldap_query' `
-Name 'ldap_query' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path "OU=Service,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD" `
-SamAccountName 'ldap_query' `
-UserPrincipalName "ldap_query@$domainName"
#endregion

#region - domain structure - create lab user
New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'CtxUser1' `
-Enabled $True `
-Name 'CtxUser1' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path "OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD" `
-SamAccountName 'CtxUser1' `
-UserPrincipalName "CtxUser1@$domainName"

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'CtxUser2' `
-Enabled $True `
-Name 'CtxUser2' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path "OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD" `
-SamAccountName 'CtxUser2' `
-UserPrincipalName "CtxUser2@$domainName"

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'CtxUser3' `
-Enabled $True `
-Name 'CtxUser3' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path "OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD" `
-SamAccountName 'CtxUser3' `
-UserPrincipalName "CtxUser3@$domainName"

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'RASUser1' `
-Enabled $True `
-Name 'RASUser1' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path "OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD" `
-SamAccountName 'RASUser1' `
-UserPrincipalName "RASUser1@$domainName"

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'RASUser2' `
-Enabled $True `
-Name 'RASUser2' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path "OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD" `
-SamAccountName 'RASUser2' `
-UserPrincipalName "RASUser2@$domainName"

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'RASUser3' `
-Enabled $True `
-Name 'RASUser3' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path "OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD" `
-SamAccountName 'RASUser3' `
-UserPrincipalName "RASUser3@$domainName"

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'VMwUser1' `
-Enabled $True `
-Name 'VMwUser1' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path "OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD" `
-SamAccountName 'VMwUser1' `
-UserPrincipalName "VMwUser1@domainName"

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'VMwUser2' `
-Enabled $True `
-Name 'VMwUser2' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path "OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD" `
-SamAccountName 'VMwUser2' `
-UserPrincipalName "VMwUser2@$domainName"

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'VMwUser3' `
-Enabled $True `
-Name 'VMwUser3' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path "OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD" `
-SamAccountName 'VMwUser3' `
-UserPrincipalName "VMwUser@$domainName"
#endregion

#region - domain structure - add Admin to Group
Add-ADGroupMember -Identity "CN=CtxAdmins,ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" `
-Members "CN=CtxAdmin,OU=Admin,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD"

Add-ADGroupMember -Identity "CN=CtxHelpdesk,ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" `
-Members "CN=CtxUser1,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD"

Add-ADGroupMember -Identity "CN=DEMAdmins,ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" `
-Members "CN=VMwUser1,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD"

Add-ADGroupMember -Identity "CN=RASAdmins,ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" `
-Members "CN=RASAdmin,OU=Admin,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD"

Add-ADGroupMember -Identity "CN=RASHelpdesk,ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" `
-Members "CN=RASUser1,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD"

Add-ADGroupMember -Identity "CN=VMwAdmins,ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" `
-Members "CN=VMwAdmin,OU=Admin,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD"

Add-ADGroupMember -Identity "CN=VMwHelpdesk,ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" `
-Members "CN=VMwUser1,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD"
#endregion

#region - domain structure - add user to Group
Add-ADGroupMember -Identity "CN=DEMUsers,ou=Users,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" `
-Members "CN=VMwUser1,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD","CN=VMwUser2,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD","CN=VMwUser3,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD"

Add-ADGroupMember -Identity "CN=RASUsers,ou=Users,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" `
-Members "CN=RASUser1,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD","CN=RASUser2,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD","CN=RASUser3,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD"

Add-ADGroupMember -Identity "CN=XAUsers,ou=Users,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" `
-Members "CN=CtxUser1,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD"

Add-ADGroupMember -Identity "CN=XDUsers,ou=Users,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" `
-Members "CN=CtxUser1,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD","CN=CtxUser2,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD","CN=CtxUser3,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD"
#endregion

#region - DNS entries

Add-DnsServerResourceRecordA -AllowUpdateAny `
-CreatePtr `
-IPv4Address '10.2.134.199' `
-Name 'AppLayering' `
-TimeToLive 01:00:00 `
-ZoneName $DnsZoneName

#endregion