# Prepare the configuration for very first domain controller

## First domain controller

The domain is not there yet

```powershell
#this is for the very first domain controller, before the domain arise yet
Set-DnsClientServerAddress -InterfaceAlias (Get-NetIPConfiguration -InterfaceAlias (Get-NetAdapter).Name).InterfaceAlias -ServerAddres (((Get-NetIPConfiguration -InterfaceAlias (Get-NetAdapter).Name).IPv4Address).IPAddress)

Rename-Computer -NewName $newComputerName -Restart
```

### DNS preconfiguration

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

### Second domain controller

