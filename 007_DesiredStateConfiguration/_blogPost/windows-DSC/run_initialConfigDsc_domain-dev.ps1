
#1. on target node run: cmd
#2. on target node in cmd run: powershell
#3. on target node in powershell run: Start-Process PowerShell -Verb RunAs

# if domain name is modified then update the DSC configuration data accordingly
# run code in elevated powershell session

$domainName = 'd.local'  #FIXME
Set-InitialConfigDsc -NewComputerName $env:computername -Option Domain -DomainName $domainName -Verbose
