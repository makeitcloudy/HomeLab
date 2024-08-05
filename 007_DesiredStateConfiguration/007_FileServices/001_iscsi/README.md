# iSCSI Target

This vm is for the situation where there is no NAS which can serve the iscsi for the clusters built on top

## iSCSI



```powershell
# run on the management node - under privileged account
# the fs01,fs02, iscsi are domain joined
# iscsi storage interface = 10.0.0.3
# fs01,fs02 storage interface = 10.0.0.1 , 10.0.0.2

# once the disk is added to the iscsi node - do NOT initialize the disk, do NOT format it
# do it only when it is added to the cluster

whoami
Install-WindowsFeature -ComputerName iscsi FS-FileServer,FS-iSCSITarget-Server -IncludeAllSubFeature -Restart
Invoke-Command -Computername iscsi -ScriptBlock {New-iSCSIVirtualDisk -Path "Q:\iscsi-lun-clusterFS-quorum.vhdx" -Description "iscsi-lun-clusterFS-quorum" -Size 2GB}
Invoke-Command -Computername iscsi -ScriptBlock {New-iSCSIServerTarget -TargetName "iscsi-target-clusterFS" -InitiatorIds @("IPAddress:10.0.0.1","IPAddress:10.0.0.2")}
Invoke-Command -Computername iscsi -ScriptBlock {Add-iSCSIVirtualDiskTargetMapping -TargetName "iscsi-target-clusterFS" -Path "Q:\iscsi-lun-clusterFS-quorum.vhdx"}

Invoke-Command -ComputerName fs01,fs02 -ScriptBlock {Set-Service msiscsi -StartupType Automatic; Start-Service msiscsi}
Invoke-Command -ComputerName fs01,fs02 -ScriptBlock {Get-InitiatorPort}
#NodeAddress

#storage network interface on iscsi node IP address equals to 10.0.0.3
Invoke-Command -ComputerName fs01,fs02 -ScriptBlock {New-IscsiTargetPortal -TargetPortalAddress 10.0.0.3}
Invoke-Command -ComputerName fs01,fs02 -ScriptBlock {Get-IscsiTargetPortal | Update-IscsiTargetPortal}
Invoke-Command -ComputerName fs01,fs02 -ScriptBlock {Get-IscsiTarget}

#cluster1
Invoke-Command -ComputerName fs01 -ScriptBlock {Connect-IscsiTarget -NodeAddress iqn.1991-05.com.microsoft:iscsi-iscsi-target-clusterfs-target -IsPersistent $true -initiatorportaladdress 10.0.0.1 -targetportaladdress 10.0.0.3}
#cluster2
Invoke-Command -ComputerName fs02 -ScriptBlock {Connect-IscsiTarget -NodeAddress iqn.1991-05.com.microsoft:iscsi-iscsi-target-clusterfs-target -IsPersistent $true -initiatorportaladdress 10.0.0.2 -targetportaladdress 10.0.0.3}

Invoke-Command -ComputerName fs01,fs02 -ScriptBlock {Get-IscsiSession | Register-IscsiSession}


```