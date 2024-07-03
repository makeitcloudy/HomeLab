# store the future domain admin credentials


#1. Create Folder structure
#2. Download from Github code
#3. Run it

#4. Prepare credentials
#https://community.spiceworks.com/t/dns-issue-i-have-to-enter-fqdn-to-join-domain-but-why/636506/10

$AdminUsername                 = "Administrator"
$AdminPassword                 = ConvertTo-SecureString "Password1$" -AsPlainText -Force
$cred                          = New-Object System.Management.Automation.PSCredential ($AdminUsername, $AdminPassword)

#$SafemodeAdministratorName     = 'Administrator'
#$SafemodeAdministratorPassword = ConvertTo-SecureString "Password1$" -AsPlainText -Force
#$SafemodeAdministratorCred     = New-Object System.Management.Automation.PSCredential ($SafemodeAdministratorName, $SafemodeAdministratorPassword)


#$domainAdministratorName       = 'lab.local\Administrator'
#$domainAdministratorPassword   = ConvertTo-SecureString "Password1$" -AsPlainText -Force
#$domainAdministratorCred       = New-Object System.Management.Automation.PSCredential ($domainAdministratorName, $domainAdministratorPassword)

if (-not $cred){
    $cred = (Get-Credential -Message "Enter new domain's credential")
}


# customize the configuration parameters according to your needs
psedit C:\dsc\_config\localhost\ActiveDirectory\New-ADDSC.ps1

# there is nothing to customize here - all variables are stored in the file above
psedit C:\dsc\_config\localhost\ActiveDirectory\New-ADDSC.psm1

& C:\dsc\_config\localhost\ActiveDirectory\New-ADDSC.ps1 -domainCred $cred -certThumbprint "" -preReq

# run the script
& "\\tsclient\C\PROJECTS\dsc\SS.INFRA.DSC\NewAD\New-ADDSC.ps1"`
 -domainCred $cred `
 -certThumbprint "64bd5b4725f03221e6b03cf8d376d3bbbd569917" `
 -prereq