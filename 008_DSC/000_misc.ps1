Start-Process "https://adamtheautomator.com/powershell-scheduled-task/"

#region NTP client configuration
Start-Process "C:\Windows\System32\rundll32.exe" -ArgumentList 'C:\Windows\System32\shell32.dll,Control_RunDLL C:\Windows\System32\timedate.cpl'
Get-Service | Where-Object {$_.Name -eq 'W32Time'}
Set-Service -Name W32Time -StartupType Automatic -Verbose
#Get-Service -Name W32Time | fl *
# run in elevated command prompt
w32tm /config "/manualpeerlist:[InternalNtpDnsEntry],0x8 0.pl.pool.ntp.org,0xa 1.pl.pool.ntp.org,0xa 2.pl.pool.ntp.org,0xa" /syncfromflags:manual /reliable:no /update
#w32tm /config "/manualpeerlist:[InternalNtpDnsEntry],0x8 0.pl.pool.ntp.org,0xa 1.pl.pool.ntp.org,0xa 2.pl.pool.ntp.org,0xa" /syncfromflags:manual /reliable:no /update
#w32tm /config /syncfromflags:MANUAL /reliable:yes
#  syncfromflags:<source> - sets what sources the NTP client should
#    sync from. <source> should be a comma separated list of
#    these keywords (not case sensitive):
#      MANUAL - sync from peers in the manual peer list
#      DOMHIER - sync from an AD DC in the domain hierarchy
#      NO - sync from none
#      ALL - sync from both manual and domain peers

#  reliable:(YES|NO) - set whether this machine is a reliable time source.
#    This setting is only meaningful on domain controllers.
#      YES - this machine is a reliable time service
#      NO - this machine is not a reliable time service
w32tm /query /peers
w32tm /query /source
#endregion

#region disable IPv6 on the network link of the vm
# assumption that VM has only one network adapter, if not bring simple foreach here
(Get-NetAdapter).Name
Get-NetAdapterBinding -ComponentID ms_tcpip6 | fl *
Disable-NetAdapterBinding -Name (Get-NetAdapter).Name -ComponentID ms_tcpip6
#endregion

#region windows server - firewall configuration - RSAT
get-command -Noun NetFirewallRule
Get-NetFirewallRule | Where-Object {$_.Action -eq 'Allow'} | Out-GridView
Get-NetFirewallRule | Where-Object {$_.DisplayGroup -match 'remote management'} | Out-GridView

# Start-Process 'https://docs.microsoft.com/en-us/windows-server/administration/server-core/server-core-manage'

#To allow all MMC snap-ins to connect, run the following command:
Enable-NetFirewallRule -DisplayGroup "Windows Remote Management"
#To allow only specific MMC snap-ins to connect, run the following:
Enable-NetFirewallRule -DisplayGroup "<rulegroup>"
#MMC snap-in 	                            Rule group
#Event Viewer 	                            Remote Event Log Management
#Services 	                                Remote Service Management
#Shared Folders 	                        File and Printer Sharing
#Task Scheduler 	                        Performance Logs and Alerts, File and Printer Sharing
#Disk Management 	                        Remote Volume Management
#Windows Firewall and Advanced Security 	Windows Firewall Remote Management

#Some MMC snap-ins don't have a corresponding rule group that allows them to connect through the firewall.
#However, enabling the rule groups for Event Viewer, Services, or Shared Folders will allow most other snap-ins to connect.

#Looks like MMC snapins communicates over the winRM and DCOM+
#f.e for the succesfull launch of the mmc DNS add trusted hosts entry for the sucesfull winRm connectivity
Get-Item WSMan:\localhost\Client\TrustedHosts
Set-Item WSMan:\localhost\Client\TrustedHosts -Concatenate -Value "dns.lab" -Force #run this elevated on the server which is your management node
Set-Item WSMan:\localhost\Client\TrustedHosts -Concatenate -Value "mgmt.lab" -Force #run this elevated on the server which plays the DNS role

# in case you can not connect to the DNS server as last resort try the following
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False 
Set-NetFirewallProfile -Profile Private -Enabled False

#Get-ItemProperty -path HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Client\trusted_hosts
Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Client'
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Client'
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Client' |Select-Object -ExpandProperty trusted_hosts

#endregion
