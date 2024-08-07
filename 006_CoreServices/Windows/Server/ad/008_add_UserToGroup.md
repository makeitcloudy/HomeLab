# Carl Webster

## x

```powershell
#add lab users to lab user groups
Add-ADGroupMember -Identity "CN=DEMUsers,ou=Users,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" `
-Members "CN=VMwUser1,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD","CN=VMwUser2,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD","CN=VMwUser3,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD"

Add-ADGroupMember -Identity "CN=RASUsers,ou=Users,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" `
-Members "CN=RASUser1,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD","CN=RAS
User2,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD","CN=RASUser3,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD"

Add-ADGroupMember -Identity "CN=XAUsers,ou=Users,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" `
-Members "CN=CtxUser1,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD"

Add-ADGroupMember -Identity "CN=XDUsers,ou=Users,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" `
-Members "CN=CtxUser1,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD","CN=CtxUser2,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD","CN=CtxUser3,OU=Users,OU=Accounts,OU=Lab,DC=$ADDomain,DC=$TLD"

```