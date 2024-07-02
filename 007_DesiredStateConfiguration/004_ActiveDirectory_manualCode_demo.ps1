#dc01
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Rename-Computer -

$domainName = 'lab.local'
$domainNetbiosName = 'lab'
#$SafemodeAdministratorName     = 'Administrator'
$SafemodeAdministratorPassword = ConvertTo-SecureString "Password1$" -AsPlainText -Force
#$SafemodeAdministratorCred     = New-Object System.Management.Automation.PSCredential ($SafemodeAdministratorName, $SafemodeAdministratorPassword)

Install-ADDSForest -DomainName $domainName `
                   -DomainNetbiosName 'crap' `
                   -SafeModeAdministratorPassword $SafemodeAdministratorPassword `
                   -ForestMode 'WinThreshold' `
                   -DomainMode 'WinThreshold' `
                   -DatabasePath "C:\Windows\NTDS" `
                   -LogPath "C:\Windows\Logs" `
                   -SysvolPath "C:\Windows\SYSVOL" `
                   -InstallDns
Install-ADDSForest -DomainName contoso.com 

