#source: https://github.com/santiagocardenas/xenserver-powershell-scripts/blob/master/Set-XenServerVMSnapshot.ps1
<#
    .SYNOPSIS
        Creates or Reverts a XenServer VM snapshot.
    .DESCRIPTION
        Creates or Reverts a XenServer VM snapshot.
        Requires XenServer SDK's PowerShell Snap-in (new version).
    .PARAMETER VMNames
        Names of the VMs to use.
    .PARAMETER Create
        Specify to create a snapshot.
    .PARAMETER Revert
        Specify to revert to a snapshot.
    .PARAMETER SnapshotName
        Name of the snapshot to use.
    .PARAMETER XenServerHost
        The XenServer host to connect to. It must be the master of the pool.
    .PARAMETER UserName
        Username for XenServer host.
    .PARAMETER Password
        Password for XenServer host.
    .PARAMETER TryDelay
        Time in seconds to sleep between VM shutdown checks.
    .PARAMETER Tries
        Number of tries for VM shutdown checks.
    .EXAMPLE
        Set-XenServerVMSnapshot.ps1 -VMNames "VM01","VM02" -Create -SnapshotName "My Snapshot" -XenServerHost "1.2.3.4" -UserName "root" -Password "p4ssw0rd"
        Description
        -----------
        Creates a snapshot on the VMs specified through the XenServer host provided.
    .EXAMPLE
        Set-XenServerVMSnapshot.ps1 -VMNames "VM01","VM02" -Revert -SnapshotName "My Snapshot" -XenServerHost "1.2.3.4" -UserName "root" -Password "p4ssw0rd"
        Description
        -----------
        Reverts a snapshot on the VMs specified through the XenServer host provided.
    .NOTES
        Copyright (c) Citrix Systems, Inc. All rights reserved.
        Version 1.0
#>

Param (
    [Parameter(Mandatory=$true)] [string[]]$VMNames,
    [Parameter(Mandatory=$true,ParameterSetName='Create')] [switch]$Create,
    [Parameter(Mandatory=$true,ParameterSetName='Revert')] [switch]$Revert,
    [Parameter(Mandatory=$true)] [string]$SnapshotName,
    [Parameter(Mandatory=$true)] [string]$XenServerHost,
    [Parameter(Mandatory=$true)] [string]$UserName,
    [Parameter(Mandatory=$true)] [string]$Password,
    [Parameter(Mandatory=$false,ParameterSetName='Create')] [int]$TryDelay=10,
    [Parameter(Mandatory=$false,ParameterSetName='Create')] [int]$Tries=30
)

#Need this to ensure non-terminating error halt script
$ErrorActionPreference = "Stop"

if (Get-PSSnapin -Registered | ? {$_.Name -eq "XenServerPSSnapIn"}) {
    #Blog Step: Load the XenServer Snap-in
    if ((Get-PSSnapin -Name XenServerPSSnapIn -ErrorAction SilentlyContinue) -eq $null) {
        Write-Host "$($MyInvocation.MyCommand): Adding XenServerPSSnapIn PowerShell Snap-in"
        Add-PSSnapin XenServerPSSnapIn
    }

    try {
        #Blog Step: Connect to the XenServer pool master
        Write-Host "$($MyInvocation.MyCommand): Connecting to XenServer host: $XenServerHost"
        $session = Connect-XenServer -Server $XenServerHost -UserName $UserName -Password $Password -NoWarnCertificates -SetDefaultSession -PassThru

        if ($session) {
            try {
                #Blog Post: If we are creating a snapshot:
                if ($PSCmdlet.ParameterSetName -eq 'Create') {
                    #Blog Post: Get each VM and schedule a graceful shut down of VMs
                    foreach ($VMName in $VMNames) {
                        $VM = Get-XenVM -Name $VMName
                        Write-Host "$($MyInvocation.MyCommand): Scheduling shutdown of VM '$VMName'"
                        Invoke-XenVM -VM $VM -XenAction CleanShutdown -Async
                    }
                    #Blog Post: Get each VM, ensure that the VM is powered down, and schedule the creation of snapshot
                    foreach ($VMName in $VMNames) {
                        Write-Host "$($MyInvocation.MyCommand): Ensuring that VM '$VMName' is powered off"
                        $try = 1
                        do {
                            $VM = Get-XenVM -Name $VMName
                            if ($VM.power_state -eq 'Halted') {
                                break
                            } else {
                                Write-Host "$($MyInvocation.MyCommand): $($Tries-$try) retries left. Sleeping for $TryDelay seconds."
                                $try++ 
                                Start-Sleep -Seconds $TryDelay
                            }
                        } while ($try -le $Tries)
                        if ($try -gt $Tries) {
                            throw "$($MyInvocation.MyCommand): Shutdown of VM '$VMName' FAILED. Timed out."
                        }
                        Write-Host "$($MyInvocation.MyCommand): Scheduling creation of snapshot '$SnapshotName' on VM '$VMName'"
                        Invoke-XenVM -VM $VM -XenAction Snapshot -NewName $SnapshotName -Async
                    }
                #Blog Post: If we are reverting a snapshot:
                } elseif ($PSCmdlet.ParameterSetName -eq 'Revert') {
                    #Blog Post: Get each VM, get the snapshot, schedule the reversion of snapshot
                    foreach ($VMName in $VMNames) {
                        $VM = Get-XenVM -Name $VMName
                        $snapshot = @(Get-XenVM -Name $SnapshotName | where { $_.snapshot_of -eq $VM })
                        if ($snapshot.Count -gt 1) {
                            throw "More than 1 VM Snapshot was found with the name '$SnapshotName' on VM '$VMName'."
                        } elseif ($snapshot.Count -lt 1) {
                            throw "Snapshot '$SnapshotName' not found on VM '$VMName'."
                        }
                        Write-Host "$($MyInvocation.MyCommand): Reverting to snapshot '$SnapshotName' on VM '$VMName'"
                        #Don't run command below async because it conflicts with the power on
                        Invoke-XenVM -VM $VM -XenAction Revert -Snapshot $snapshot[0]
                    }
                }
                #Blog Post: Get each VM and schedule the power on
                foreach ($VMName in $VMNames) {
                    $VM = Get-XenVM -Name $VMName
                    Write-Host "$($MyInvocation.MyCommand): Scheduling power on of VM '$VMName'"
                    Invoke-XenVM -VM $VM -XenAction Start -Async
                }
            }
            finally {
                #Blog Post: Disconnect from XenServer pool master
                Write-Host "$($MyInvocation.MyCommand): Disconnecting from XenServer host"
                Disconnect-XenServer -Session $session
            }
        }
    }
    finally {
        #Blog Post: Remove the XenServer Snap-in
        Write-Host "$($MyInvocation.MyCommand): Removing XenServerPSSnapIn PowerShell Snap-in"
        Remove-PSSnapin XenServerPSSnapIn
    }
} else {
    throw "XenServerPSSnapIn not found."
}
