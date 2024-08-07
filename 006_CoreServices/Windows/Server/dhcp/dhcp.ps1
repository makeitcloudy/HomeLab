# ToDo:
# make use of XCP-ng powershell module - list VM's with MAC addresses and pass it to the reservations

$ADDomain   = 'lab'
$TLD        = 'local'
$DomainName = "$ADDomain.$TLD"

#region install DHCP

Install-WindowsFeature DHCP, RSAT-DHCP

## Authorize the new DHCP server in AD
$DHCPServer = "$($env:ComputerName).$($env:USERDNSDOMAIN)"
Add-DhcpServerInDC -DnsName $DHCPServer
## Add the new DHCP server to the DnsUpdateProxy security group
$computer = "$($env:ComputerName)$"
Add-ADGroupMember "DnsUpdateProxy" -members $computer
## Add DHCP security groups
## This command adds the security groups DHCP Users and DHCP Administrators to the DHCP server
Add-DhcpServerSecurityGroup -ComputerName $DHCPServer
## Set DHCP server DNS settings
Set-DhcpServerv4DnsSetting -ComputerName $DHCPServer `
-DynamicUpdates Always `
-NameProtection $True
## Set DHCP Server Network Access Protection policy settings
Set-DhcpServerSetting -ComputerName $DHCPServer `
-NapEnabled $False `
-ConflictDetectionAttempts 0 `
-ActivatePolicies $False `
-NpsUnreachableAction Full

## Set the DNS Dynamic Update Credentials
$DHCPCredentials = Get-Credential -UserName "DNSDynamicUpdate" -
Message "Enter a password for DNSDynamicUpdate"
Set-DhcpServerDnsCredential -Credential $DHCPCredentials -ComputerName $DHCPServer
## Set Filters
Set-DhcpServerv4FilterList -ComputerName $DHCPServer -Allow $False -Deny $False
## Set DHCP server options
Set-DhcpServerv4OptionValue -ComputerName $DHCPServer `
-DnsServer 192.168.1.201,192.168.1.202 `
-Router 192.168.1.1 `
-Force `
-DnsDomain $domainName

#region DHCP Scope
Add-DhcpServerv4Scope -Name "Webster's Lab" `
-StartRange 192.168.1.100 `
-EndRange 192.168.1.199 `
-SubnetMask 255.255.255.0 `
-ComputerName $DHCPServer `
-LeaseDuration 8.00:00:00 `
-State Active `
-Type DHCP `
-Description ""

#region DHCP Scope - Set scope options
Set-DhcpServerv4OptionValue -ComputerName $DHCPServer `
-ScopeId 192.168.1.0 `
-DnsServer 192.168.1.201,192.168.1.202 `
-Force `
-DnsDomain $domainName `
-Router 192.168.1.1
#endregion

#region DHCP Scope - Set scope DNS settings
Set-DhcpServerv4DnsSetting -ComputerName $DHCPServer `
-ScopeId 192.168.1.0 `
-DynamicUpdates Always `
-NameProtection $True
#endregion

## Set scope reservations
Add-DhcpServerv4Reservation -Name "APC SmartUPS 2200" `
-ScopeId 192.168.1.0 `
-IPAddress 192.168.1.249 `
-ClientId "28-29-86-1b-f9-b1" `
-Type Both `
-Description "APC SmartUPS 2200"

## Set reservation DNS settings
Set-DhcpServerv4DnsSetting -ComputerName $DHCPServer `
-IPAddress 192.168.1.249 `
-DynamicUpdates Always
Add-DhcpServerv4Reservation -Name "Netgear 1G Switch" `
-ScopeId 192.168.1.0 `
-IPAddress 192.168.1.250 `
-ClientId "28-80-88-6d-51-60" `
-Type Both `
-Description "Netgear 1G Switch"

## Set reservation DNS settings
Set-DhcpServerv4DnsSetting -ComputerName $DHCPServer `
-IPAddress 192.168.1.250 `
-DynamicUpdates Always
Add-DhcpServerv4Reservation -Name "Netgear 10G Switch" `
-ScopeId 192.168.1.0 `
-IPAddress 192.168.1.251 `
-ClientId "3c-37-86-2a-0e-0c" `
-Type Both `
-Description "Netgear 10G Switch"

## Set reservation DNS settings
Set-DhcpServerv4DnsSetting -ComputerName $DHCPServer `
-IPAddress 192.168.1.251 `
-DynamicUpdates Always

#endregion
#endregion