# Prepare DNS for Active Directory

## initial configuration

```powershell
tzutil /l
Set-TimeZone "Central Europe Standard Time"
Set-Date -Date '8/6/2024 7:49 PM'
Get-NetAdapter
# this works provided there is only one network adapter
Get-NetIPAddress -InterfaceAlias (Get-NetAdapter).Name
New-NetIPAddress -InterfaceAlias (Get-NetAdapter).Name -IPAddress 10.0.0.1 -PrefixLength 24 -DefaultGateway 10.0.0.254
Get-NetIPConfiguration -InterfaceAlias (Get-NetAdapter).Name
(Get-NetIPConfiguration -InterfaceAlias (Get-NetAdapter).Name).IPv4Address

Set-DnsClientServerAddress -InterfaceAlias (Get-NetIPConfiguration -InterfaceAlias (Get-NetAdapter).Name).InterfaceAlias -ServerAddres (((Get-NetIPConfiguration -InterfaceAlias (Get-NetAdapter).Name).IPv4Address).IPAddress)

Get-NetIPConfiguration -InterfaceAlias (Get-NetIPConfiguration -InterfaceAlias (Get-NetAdapter).Name).InterfaceAlias

Rename-Computer -NewName dc01 -Restart

slmgr.vbs -ipk [produktkey]
slmgr.vbs -ato
Enable-PSRemoting

Get-NetFirewallRule
Get-NetFirewallRule -Name [nameOfTheRule]
Get-NetFirewallRule | Format-Table DisplayName,DisplayGroup
Enable-NetFirewallRule -DisplayGroup 'File and Printer Sharing'

# allowed only in the lab
New-NetFirewallrule -DisplayName "Allow All Traffic" -Direction Outbound -Action Allow
New-NetFirewallrule -DisplayName "Allow All Traffic" -Direction Inbound -Action Allow
```

## DNS preconfiguration 

```powershell
# run this on the domain controller prior the role configuration and setup
Install-WindowsFeature dns

# on the management VM
# launch explorer
# mount the \\[IP address of DC]\c$ - connect using different credentials
# user: [IP address of DC]\administrator
# pass: [password]

# once the content of the drive is shown the access to the target VM should be possible over RSAT tooling as well
```