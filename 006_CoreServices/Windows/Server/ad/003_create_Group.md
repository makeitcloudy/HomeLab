# Carl Webster - Lab

```powershell
#admin security groups - $ADDomain.$TLD
$ADDomain = 'lab'
$TLD = 'local'
$Protect = $False

New-ADGroup -DisplayName "CtxAdmins" -GroupCategory "Security" -GroupScope "Global" -Name "CtxAdmins" -Path "ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "CtxAdmins$"

New-ADGroup -DisplayName "CtxHelpdesk" -GroupCategory "Security" -GroupScope "Global" -Name "CtxHelpdesk" -Path "ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "CtxHelpdesk$"

New-ADGroup -DisplayName "RASAdmins" -GroupCategory "Security" -GroupScope "Global" -Name "RASAdmins" -Path "ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "RASAdmins$"

New-ADGroup -DisplayName "RASHelpdesk" -GroupCategory "Security" -GroupScope "Global" -Name "RASHelpdesk" -Path "ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "RASHelpdesk$"

New-ADGroup -DisplayName "VMwAdmins" -GroupCategory "Security" -GroupScope "Global" -Name "VMwAdmins" -Path "ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "VMwAdmins$"

New-ADGroup -DisplayName "VMwHelpdesk" -GroupCategory "Security" -GroupScope "Global" -Name "VMwHelpdesk" -Path "ou=Admin,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "VMwHelpdesk$"

#user security groups
New-ADGroup -DisplayName "RASUsers" -GroupCategory "Security" -GroupScope "Global" -Name "RASUsers" -Path "ou=Users,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "RASUsers$"

New-ADGroup -DisplayName "XAUsers" -GroupCategory "Security" -GroupScope "Global" -Name "XAUsers" -Path "ou=Users,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "XAUsers$"

New-ADGroup -DisplayName "XDUsers" -GroupCategory "Security" -GroupScope "Global" -Name "XDUsers" -Path "ou=Users,ou=Groups,ou=Lab,dc=$ADDomain,dc=$TLD" -SamAccountName "XDUsers$"
```
