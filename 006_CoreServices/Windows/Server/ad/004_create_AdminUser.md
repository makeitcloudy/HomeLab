# Carl Webster lab

## x

```powershell
#Create admin user accounts
$UserPwd = Read-Host -AsSecureString -Prompt 'Enter password'
New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'CtxAdmin' `
-Enabled $True `
-Name 'CtxAdmin' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path 'OU=Admin,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD' `
-SamAccountName 'CtxAdmin' `
-UserPrincipalName 'CtxAdmin@lab.local'

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'RASAdmin' `
-Enabled $True `
-Name 'RASAdmin' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path 'OU=Admin,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD' `
-SamAccountName 'RASAdmin' `
-UserPrincipalName 'RASAdmin@LabADDomain.com'

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'UMSAdmin' `
-Enabled $True `
-Name 'UMSAdmin' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path 'OU=Admin,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD' `
-SamAccountName 'UMSAdmin' `
-UserPrincipalName "UMSAdmin@LabADDomain.com"

New-ADUser -AccountPassword $UserPwd `
-CannotChangePassword $True `
-ChangePasswordAtLogon $False `
-DisplayName 'VMwAdmin' `
-Enabled $True `
-Name 'VMwAdmin' `
-PasswordNeverExpires $True `
-PasswordNotRequired $False `
-Path 'OU=Admin,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD' `
-SamAccountName 'VMwAdmin' `
-UserPrincipalName VMwAdmin@LabADDomain.com
```
