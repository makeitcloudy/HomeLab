# Prepare DNS for Active Directory

## initial configuration - Network Layer

### Set - network adapter configuration

```powershell
$newComputerName = 'sql01'
$IPv4Address = '10.2.134.221'
$netMask   = '24'
$defaultGateway = '10.2.134.254'

$dnsServerIpv4Address = @('10.2.134.201','10.2.134.202')

$domainName = ''

Get-NetAdapter
# this works provided there is only one network adapter
Get-NetIPAddress -InterfaceAlias (Get-NetAdapter).Name
New-NetIPAddress -InterfaceAlias (Get-NetAdapter).Name -IPAddress $IPv4Address -PrefixLength $netMask -DefaultGateway $defaultGateway

Get-NetIPConfiguration -InterfaceAlias (Get-NetAdapter).Name
(Get-NetIPConfiguration -InterfaceAlias (Get-NetAdapter).Name).IPv4Address

#this is for any subsequent serer
Set-DnsClientServerAddress -InterfaceAlias (Get-NetIPConfiguration -InterfaceAlias (Get-NetAdapter).Name).InterfaceAlias -ServerAddres $dnsServerIpv4Address

Get-NetIPConfiguration -InterfaceAlias (Get-NetIPConfiguration -InterfaceAlias (Get-NetAdapter).Name).InterfaceAlias
```

## Set - Firewall configuration

```powershell
Get-NetFirewallRule
Get-NetFirewallRule -Name [nameOfTheRule]
Get-NetFirewallRule | Format-Table DisplayName,DisplayGroup
Enable-NetFirewallRule -DisplayGroup 'File and Printer Sharing'

# allowed only in the lab
New-NetFirewallrule -DisplayName "Allow All Traffic" -Direction Outbound -Action Allow
New-NetFirewallrule -DisplayName "Allow All Traffic" -Direction Inbound -Action Allow
```

## Initial configuration - OS Layer

### Set - timezone

```powershell
# set timezone
tzutil /l
Set-TimeZone "Central Europe Standard Time"
#Set-Date -Date '8/6/2024 7:49 PM'
```

### add computer to domain

```powershell
Add-computer -DomainName 'lab.local' -NewName sql01 -Credential (Get-Credential -UserName 'mot\administrator' -Message 'creds') -Restart
```

### misc code

```powershell
slmgr.vbs -ipk [produktkey]
slmgr.vbs -ato
Enable-PSRemoting

```
