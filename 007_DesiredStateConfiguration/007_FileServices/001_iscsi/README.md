# iSCSI Target

This vm is for the situation where there is no NAS which can serve the iscsi for the clusters built on top

## ToDo

The file servers forms a cluster, so the disks added to the vm should not be initialized and formated.  
The initialization and bringing them online, should take place from the management server.  
Then later on those should be formated from the clustering console it seems.

## Assumption

* The iscsi, fs01, fs02 are already in the domain

1. The configuration takes place on the management node
2. From the management node via Invoke-Command against the target nodes (all in the domain) the actuall configuration take place
3. 

https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/README.md#run_initialsetupps1

```powershell
#Start-Process PowerShell_ISE -Verb RunAs
# run in elevated PowerShell session
#region initialize variables
$scriptName     = 'InitialConfig.ps1'
$uri            = 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode',$scriptName -join '/'
$path           = "$env:USERPROFILE\Documents"
$outFile        = Join-Path -Path $path -ChildPath $scriptName


# set the execution policy
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force

#region download function Get-GitModule.ps1
Set-Location -Path $path
Invoke-WebRequest -Uri $uri -OutFile $outFile -Verbose
#psedit $outFile

# load function into memory
. $outFile
#psedit $outfile
Set-InitialConfiguration -Verbose

```

Join the machine to the domain

```powershell
$domainName = 'lab.local'  #FIXME
Set-InitialConfigDsc -NewComputerName $env:computername -Option Domain -DomainName $domainName -Verbose
```

## FS01, FS02 - Networking

### FS01 - Networking - Storage

```code
# /home/piotrek/Git/Private/LabTrainings/plural/path_server_2019/chapter0-iscsi-fileCluster/
```

```powershell
# code just in case if something is screwed up
# Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True

## Get the network adapter
#$adapter = Get-NetAdapter | Where-Object { $_.Name -eq 'Eth0'}
## Remove current IP configuration
#$adapter | Get-NetIPAddress | Remove-NetIPAddress -Confirm:$false
##
#New-NetIPAddress -InterFaceIndex ($adapter.ifIndex) -IPAddress '10.2.134.21'
```

```powershell
$macPartial = "47-42"
$interfaceName = "storage"
$ipAddress = "10.47.42.21"
$subnetMask = 24

# Get the network interface that matches the partial MAC address
$interface = Get-NetAdapter | Where-Object { $_.MacAddress -match $macPartial }

if ($interface) {
    # Rename the network interface
    Rename-NetAdapter -Name $interface.Name -NewName $interfaceName
    # Disable IPv6 on the interface
    Disable-NetAdapterBinding -Name $interfaceName -ComponentID ms_tcpip6
    New-NetIPAddress -InterFaceIndex ($interface.ifIndex) -IPAddress $ipAddress -PrefixLength 24

    Write-Output "Configuration applied successfully to interface $($interfaceName)."
} else {
    Write-Output "No network interface found with MAC address containing $($macPartial)."
}

```

### FS01 - Networking - cluster

```powershell
$macPartial = "47-43"
$interfaceName = "cluster"
$ipAddress = "10.47.43.21"
$subnetMask = 24

# Get the network interface that matches the partial MAC address
$interface = Get-NetAdapter | Where-Object { $_.MacAddress -match $macPartial }

if ($interface) {
    $interface | Get-NetIPAddress | Remove-NetIPAddress -Confirm:$false
    # Rename the network interface
    Rename-NetAdapter -Name $interface.Name -NewName $interfaceName
    # Disable IPv6 on the interface
    Disable-NetAdapterBinding -Name $interfaceName -ComponentID ms_tcpip6
    New-NetIPAddress -InterFaceIndex ($interface.ifIndex) -IPAddress $ipAddress -PrefixLength 24

    Write-Output "Configuration applied successfully to interface $($interfaceName)."
} else {
    Write-Output "No network interface found with MAC address containing $($macPartial)."
}
```

### FS02 - Networking - Storage

```code
# /home/piotrek/Git/Private/LabTrainings/plural/path_server_2019/chapter0-iscsi-fileCluster/
```

```powershell
$macPartial = "47-42"
$interfaceName = "storage"
$ipAddress = "10.47.42.22"
$subnetMask = 24

# Get the network interface that matches the partial MAC address
$interface = Get-NetAdapter | Where-Object { $_.MacAddress -match $macPartial }

if ($interface) {
    $interface | Get-NetIPAddress | Remove-NetIPAddress -Confirm:$false
    # Rename the network interface
    Rename-NetAdapter -Name $interface.Name -NewName $interfaceName
    # Disable IPv6 on the interface
    Disable-NetAdapterBinding -Name $interfaceName -ComponentID ms_tcpip6
    New-NetIPAddress -InterFaceIndex ($interface.ifIndex) -IPAddress $ipAddress -PrefixLength 24

    Write-Output "Configuration applied successfully to interface $($interfaceName)."
} else {
    Write-Output "No network interface found with MAC address containing $($macPartial)."
}

```

### FS01 - Networking - cluster

```powershell
$macPartial = "47-43"
$interfaceName = "cluster"
$ipAddress = "10.47.43.22"
$subnetMask = 24

# Get the network interface that matches the partial MAC address
$interface = Get-NetAdapter | Where-Object { $_.MacAddress -match $macPartial }

if ($interface) {
    $interface | Get-NetIPAddress | Remove-NetIPAddress -Confirm:$false
    # Rename the network interface
    Rename-NetAdapter -Name $interface.Name -NewName $interfaceName
    # Disable IPv6 on the interface
    Disable-NetAdapterBinding -Name $interfaceName -ComponentID ms_tcpip6
    New-NetIPAddress -InterFaceIndex ($interface.ifIndex) -IPAddress $ipAddress -PrefixLength 24

    Write-Output "Configuration applied successfully to interface $($interfaceName)."
} else {
    Write-Output "No network interface found with MAC address containing $($macPartial)."
}
```

## iSCSI

### iSCSI - Networking - Storage

```code
# /home/piotrek/Git/Private/LabTrainings/plural/path_server_2019/chapter0-iscsi-fileCluster/
```

```powershell
$macPartial = "47-42"
$interfaceName = "storage"
$ipAddress = "10.47.42.29"
$subnetMask = 24

# Get the network interface that matches the partial MAC address
$interface = Get-NetAdapter | Where-Object { $_.MacAddress -match $macPartial }

if ($interface) {
    # Rename the network interface
    Rename-NetAdapter -Name $interface.Name -NewName $interfaceName
    # Disable IPv6 on the interface
    Disable-NetAdapterBinding -Name $interfaceName -ComponentID ms_tcpip6
    New-NetIPAddress -InterFaceIndex ($interface.ifIndex) -IPAddress $ipAddress -PrefixLength 24

    Write-Output "Configuration applied successfully to interface $($interfaceName)."
} else {
    Write-Output "No network interface found with MAC address containing $($macPartial)."
}

```

### iSCSI - Networking - cluster

```powershell
$macPartial = "47-43"
$interfaceName = "cluster"
$ipAddress = "10.47.43.29"
$subnetMask = 24

# Get the network interface that matches the partial MAC address
$interface = Get-NetAdapter | Where-Object { $_.MacAddress -match $macPartial }

if ($interface) {
    $interface | Get-NetIPAddress | Remove-NetIPAddress -Confirm:$false
    # Rename the network interface
    Rename-NetAdapter -Name $interface.Name -NewName $interfaceName
    # Disable IPv6 on the interface
    Disable-NetAdapterBinding -Name $interfaceName -ComponentID ms_tcpip6
    New-NetIPAddress -InterFaceIndex ($interface.ifIndex) -IPAddress $ipAddress -PrefixLength 24

    Write-Output "Configuration applied successfully to interface $($interfaceName)."
} else {
    Write-Output "No network interface found with MAC address containing $($macPartial)."
}
```



```powershell
# run on the management node - under privileged account
# the fs01,fs02, iscsi are domain joined
# iscsi storage interface = 10.0.0.3
# fs01,fs02 storage interface = 10.0.0.1 , 10.0.0.2

# once the disk is added to the iscsi node - do NOT initialize the disk, do NOT format it
# do it only when it is added to the cluster

# iscsi has 3 drives
# C
# S - vhdx storage
# Q - quorum - this drive is initialized and formated from the server manager from one of the clustered nodes

whoami
Install-WindowsFeature -ComputerName iscsi FS-FileServer,FS-iSCSITarget-Server -IncludeAllSubFeature -Restart

Invoke-Command -ComputerName fs01,fs02 -ScriptBlock {Set-Service msiscsi -StartupType Automatic; Start-Service msiscsi}
Invoke-Command -ComputerName fs01,fs02 -ScriptBlock {Get-InitiatorPort}
#copy NodeAddress to clipboard
iqn.1991-05.com.microsoft:fs01.lab.local
iqn.1991-05.com.microsoft:fs02.lab.local
#NodeAddress

#storage network interface on iscsi node IP address equals to 10.47.42.29
Invoke-Command -ComputerName fs01,fs02 -ScriptBlock {New-IscsiTargetPortal -TargetPortalAddress 10.47.42.29}

Invoke-Command -Computername iscsi -ScriptBlock {New-iSCSIVirtualDisk -Path "Q:\iscsi-lun-clusterFS-quorum.vhdx" -Description "iscsi-lun-clusterFS-quorum" -Size 2GB}
Invoke-Command -Computername iscsi -ScriptBlock {New-iSCSIServerTarget -TargetName "iscsi-target-clusterFS" -InitiatorIds @("IPAddress:10.47.42.21","IPAddress:10.47.42.22")}
Invoke-Command -Computername iscsi -ScriptBlock {Add-iSCSIVirtualDiskTargetMapping -TargetName "iscsi-target-clusterFS" -Path "Q:\iscsi-lun-clusterFS-quorum.vhdx"}

Invoke-Command -ComputerName fs01,fs02 -ScriptBlock {Get-IscsiTargetPortal | Update-IscsiTargetPortal}
Invoke-Command -ComputerName fs01,fs02 -ScriptBlock {Get-IscsiTarget}

# copy the NodeAddress
# iqn.1991-05.com.microsoft:iscsi-iscsi-target-clusterfs-target

#cluster1
Invoke-Command -ComputerName fs01 -ScriptBlock {Connect-IscsiTarget -NodeAddress iqn.1991-05.com.microsoft:iscsi-iscsi-target-clusterfs-target -IsPersistent $true -initiatorportaladdress 10.47.42.21 -targetportaladdress 10.47.42.29}
#cluster2
Invoke-Command -ComputerName fs02 -ScriptBlock {Connect-IscsiTarget -NodeAddress iqn.1991-05.com.microsoft:iscsi-iscsi-target-clusterfs-target -IsPersistent $true -initiatorportaladdress 10.47.42.22 -targetportaladdress 10.47.42.29}

Invoke-Command -ComputerName fs01,fs02 -ScriptBlock {Get-IscsiSession | Register-IscsiSession}


```