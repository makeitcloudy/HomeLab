# Webster Lab

## create regular users

```powershell
#Create lab user accounts
New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'CtxUser1' `
-Enabled $True `
-Name 'CtxUser1' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path 'OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD' `
-SamAccountName 'CtxUser1' `
-UserPrincipalName 'CtxUser1@LabADDomain.com'

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'CtxUser2' `
-Enabled $True `
-Name 'CtxUser2' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path 'OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD' `
-SamAccountName 'CtxUser2' `
-UserPrincipalName 'CtxUser2@LabADDomain.com'

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'CtxUser3' `
-Enabled $True `
-Name 'CtxUser3' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path 'OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD' `
-SamAccountName 'CtxUser3' `
-UserPrincipalName 'CtxUser3@LabADDomain.com'

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'RASUser1' `
-Enabled $True `
-Name 'RASUser1' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path 'OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD' `
-SamAccountName 'RASUser1' `
-UserPrincipalName 'RASUser1@LabADDomain.com'

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'RASUser2' `
-Enabled $True `
-Name 'RASUser2' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path 'OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD' `
-SamAccountName 'RASUser2' `
-UserPrincipalName 'RASUser2@LabADDomain.com'

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'RASUser3' `
-Enabled $True `
-Name 'RASUser3' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path 'OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD' `
-SamAccountName 'RASUser3' `
-UserPrincipalName 'RASUser3@LabADDomain.com'

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'VMwUser1' `
-Enabled $True `
-Name 'VMwUser1' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path 'OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD' `
-SamAccountName 'VMwUser1' `
-UserPrincipalName 'VMwUser1@LabADDomain.com'

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'VMwUser2' `
-Enabled $True `
-Name 'VMwUser2' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path 'OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD' `
-SamAccountName 'VMwUser2' `
-UserPrincipalName 'VMwUser2@LabADDomain.com'

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'VMwUser3' `
-Enabled $True `
-Name 'VMwUser3' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path 'OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD' `
-SamAccountName 'VMwUser3' `
-UserPrincipalName 'VMwUser@LabADDomain.com'
```
