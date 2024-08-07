# Carl Webster - lab

## Create service accounts

```powershell
$ADDomain = 'lab'
$TLD = 'local'

#create service accounts
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
-Path 'OU=Service,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD' `
-SamAccountName 'DNSDynamicUpdate' `
-UserPrincipalName 'DNSDynamicUpdate@lab.local'

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
-Path 'OU=Service,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD' `
-SamAccountName 'svc_CtxVMware' `
-UserPrincipalName 'svc_CtxVMware@lab.local'

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
-Path 'OU=Service,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD' `
-SamAccountName 'ldap_query' `
-UserPrincipalName 'ldap_query@lab.local'
```