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
#endreigon
