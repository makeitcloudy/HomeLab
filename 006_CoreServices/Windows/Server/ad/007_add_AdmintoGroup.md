# Carl Webster

##

```powershell
#add admin users to admin groups
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
```