#region windows10 - install RSAT tools
Get-WindowsCapability -Name RSAT* -Online | Select-Object -Property DisplayName,Name,State | Format-List
$rsatTool = @(
'Rsat.ServerManager.Tools~~~~0.0.1.0',
'Rsat.Dns.Tools~~~~0.0.1.0'
)
$rsatTool.foreach({
    Add-WindowsCapability -Online -Name $_
})

# windows 10 install missing RSAT tools
Get-WindowsCapability -Name RSAT* -Online | Where-Object {$_.State -eq 'NotPresent'} | Add-WindowsCapability -Online

#Looks like MMC snapins communicates over the winRM and DCOM+
#f.e for the succesfull launch of the mmc DNS add trusted hosts entry for the sucesfull winRm connectivity
Get-Item WSMan:\localhost\Client\TrustedHosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Concatenate -Value "dns.lab" -Force #run this elevated on the server which is your management node
## https://www.powershellgallery.com/packages/SecurityFever/2.5.0/Content/Functions%5CTrustedHost%5CRemove-TrustedHost.ps1

# in order to be succesful with launching RSAT tools especially when your user on your device does not go
# hand in hand with the user name on the server side, navigate on the mgmt node to following location
Invoke-Item -Path 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Administrative Tools'
# the start menu in windows 10 in that context left much to be desired that's why in order to launch 
# RSAT tool navigate to abovementioned location

# in order to be sucesfull with opening the mmc DNS towards your server (still in workgroup)
# Start Server Manager with regular user context
Invoke-Item -Path "C:\Windows\system32\ServerManager.exe"
Invoke-Item -Path "$env:SystemRoot\system32\ServerManager.exe"
# in the dashboard create Server Group
# once the server group is created, edit it, and add the FQDN dns entry of the machine you'd like to manage
# in our case there is a pihole within the infrastructure, when very first entries can be created so there
# is no need to use hosts file on the system which plays your mgmt node (not domain joined)
# right click on the added server and hit the [Managed As]
# put [IP address of the dns server]\Administrator along with the password or [FQDN\Administrator] = [dns.lab\Administrator]
# if the authentication went succesfully then within the server manager some details like events and performance counters are displayed
# within the RMB (right mouse button) you'll be shown with the possibilities of the remote snapins which can be run
# in our case DNS role is installed so DNS Manager is available
# as it is not configured there are neither forward nor reverse lookup zones
#endreigon
