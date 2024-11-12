# Carl Webster code, adapted to fit the purpose
# code comes from Carl Webster publication available here: https://www.carlwebster.com/building-websters-lab-v2-1/
# Carl Webster lab build guide - Chapter 16 - Create Active Directory

# it contains:
# * initial configuration of the ADDS 
# * initial configuration of the DNS
# 

$DomainName = "d.local"

### Enable Recycle bin - page 449
Enable-ADOptionalFeature 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target $DomainName -Confirm:$False

### Set the domain's password and lockout policy
Set-ADDefaultDomainPasswordPolicy -Identity $DomainName -PasswordHistoryCount 6 -MaxPasswordAge 90.00:00:00 -MinPasswordAge 7.00:00:00 -MinPasswordLength 8 -ComplexityEnabled $False -ReversibleEncryptionEnabled $False -LockoutDuration 00:00:00 -LockoutObservationWindow 00:00:00 -LockoutThreshold 5

### Setup sites
## here the assumption is - there are two domain controllers already
#$ADSites2 = @()
##create a new site
#$ADSites = @{
#    "134b" = "Based on Webster's Lab, 134b"
#    "144c" = "Based on Webster's Lab, 144c"
#}
#ForEach($ADSite in $ADSites.Keys)
#{
#    $ADSites2 += $ADSite
#    New-ADReplicationSite -Name $ADSite -Description $ADSites[$ADSite]-ProtectedFromAccidentalDeletion $True -Server $DomainName
#}

##move the new domain controller from the Default-First-Site-Name site to the new site
#Move-ADDirectoryServer -Identity "dc01" -Site "134b"
#Move-ADDirectoryServer -Identity "dc02" -Site "134b"

##remove the Default-First-Site-Name site
##Remove-ADReplicationSite -Identity "Default-First-Site-Name" -Confirm:$False
#Remove-ADReplicationSite -Identity "Lab-Site" -Confirm:$False
##create subnets and associate them with a site
#$Subnets = @{
#    "134b" = "10.2.134.0/24"
#    "144c" = "10.3.144.0/24"
#}
#ForEach($Subnet in $Subnets.Keys) {
#    New-ADReplicationSubnet -Name $Subnets[$Subnet] -Site $Subnet
#}

### Configure DNS

$ScavengeServer = @(Get-ADDomainController).IPv4Address
Set-DnsServerScavenging -ApplyOnAllZones -ScavengingState $True -ScavengingInterval 7.00:00:00 -RefreshInterval 7.00:00:00 -NoRefreshInterval 7.00:00:00
Set-DnsServerPrimaryZone -Name $DomainName -ReplicationScope "Forest"
Set-DnsServerPrimaryZone -Name $DomainName -DynamicUpdate "Secure"

Set-DnsServerZoneAging -Name $DomainName -Aging $True -ScavengeServers $ScavengeServer -RefreshInterval 7.00:00:00 -NoRefreshInterval 7.00:00:00
Set-DnsServerForwarder -Confirm:$False -IPAddress @('1.1.1.1','8.8.8.8','8.8.4.4') -UseRootHint $True
#Add-DnsServerForwarder -Confirm:$False -IPAddress '8.8.8.8' -PassThru
#Add-DnsServerForwarder -Confirm:$False -IPAddress '8.8.4.4' -PassThru

ForEach($Subnet in $Subnets.Keys) {
    Add-DnsServerPrimaryZone -NetworkID $Subnets[$Subnet] -ReplicationScope "Forest" -DynamicUpdate "Secure"
}

Get-DnsServerZone | Where-Object {$_.IsAutoCreated -eq $False} | Set-DnsServerZoneAging -Aging $True -ScavengeServers $ScavengeServer -RefreshInterval 7.00:00:00 -NoRefreshInterval 7.00:00:00
