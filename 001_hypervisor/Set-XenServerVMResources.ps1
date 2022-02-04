#function from one of the citrix folks github - Set-XenServerVMResources
<#
    .SYNOPSIS
        Modifies the resources of a XenServer VM.
    .DESCRIPTION
        Modifies the resources of a XenServer VM.

        Requires XenServer SDK's PowerShell Snap-in (new version).
    .PARAMETER VMNames
        Names of the VMs to use.
    .PARAMETER CPUs
        Number of CPUs for the VM.
    .PARAMETER MemoryGB
        Number of GB of Memory for the VM.
    .PARAMETER NetworkNames
        Names of the networks to associate for the network adapters on the VM.
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
    .PARAMETER RebootDelay
        Time in second to sleep before rebooting VM to allow for configuration changes when networks are added.
    .PARAMETER KeepExistingNetworks
        Specify so that existing virtual interfaces are not removed before adding new networks.
    .EXAMPLE
        Set-XenServerVMResources.ps1 -VMNames "VM01","VM02" -CPUs 8 -MemoryGB 16 -NetworkNames "VM Network","INF" -XenServerHost "1.2.3.4" -UserName "root" -Password "p4ssw0rd"

        Description
        -----------
        Modifies the provided resources on the VMs specified.
    .NOTES
        Copyright (c) Citrix Systems, Inc. All rights reserved.
        Version 1.0
#>
function Set-XenServerVMResources{
[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)] [string[]]$VMNames,
    [Parameter(Mandatory=$false)] [int]$CPUs,
    [Parameter(Mandatory=$false)] [double]$MemoryGB,
    [Parameter(Mandatory=$false)] [string[]]$NetworkNames,
    [Parameter(Mandatory=$true)] [string]$XenServerHost,
    [Parameter(Mandatory=$true)] [string]$UserName,
    [Parameter(Mandatory=$true)] [string]$Password,
    [Parameter(Mandatory=$false)] [int]$TryDelay=10,
    [Parameter(Mandatory=$false)] [int]$Tries=30,
    [Parameter(Mandatory=$false)] [int]$RebootDelay=30,
    [Parameter(Mandatory=$false)] [switch]$KeepExistingNetworks
)

#Need this to ensure non-terminating error halt script
$ErrorActionPreference = "Stop"

if ($CPUs -or $MemoryGB -or $NetworkNames) {
    if (Get-Module -Name XenServerPSModule | Where-Object {$_.Name -match "XenServerPSModule"}) {
    #if (Get-PSSnapin -Registered | ? {$_.Name -eq "XenServerPSSnapIn"}) {
        #Blog Step: Load the XenServer Snap-in
        # reilict of prevoius releases
        #if ((Get-PSSnapin -Name XenServerPSSnapIn -ErrorAction SilentlyContinue) -eq $null) {
        #    Write-Host "$($MyInvocation.MyCommand): Adding XenServerPSSnapIn PowerShell Snap-in"
        #    Add-PSSnapin XenServerPSSnapIn
        #}

        if ((Get-Module -Name XenServerPSModule -ErrorAction SilentlyContinue) -eq $null) {
            Write-Host "$($MyInvocation.MyCommand): Adding XenServerPSModule PowerShell Module"
            Import-Module -Name XenServerPSModule -Scope Local -PassThru
            #Get-InstalledModule -Name XenServerPSModule -AllVersions
            #Uninstall-Module -Name XenServerPSModule -AllVersions
            #Remove-Module -Name XenServerPSModule -Force -Verbose
            #Get-Command -Noun Module
            #Get-Command -Module XenServerPSModule
        }
        
        try {
            #Blog Step: Connect to the XenServer pool master
            Write-Host "$($MyInvocation.MyCommand): Connecting to XenServer host: $XenServerHost"
            $session = Connect-XenServer -Server $XenServerHost -UserName $UserName -Password $Password -NoWarnCertificates -SetDefaultSession -PassThru

            if ($session) {
                try {
                    #Blog Step: Get each VM and schedule a graceful shut down
                    foreach ($VMName in $VMNames) {
                        $VM = Get-XenVM -Name $VMName
                        if ($VM.power_state -eq 'Running' -and $VM.allowed_operations -contains 'clean_shutdown') {
                            Write-Host "$($MyInvocation.MyCommand): Scheduling shutdown of VM '$VMName'"
                            Invoke-XenVM -VM $VM -XenAction CleanShutdown -Async
                        } else {
                            Write-Host "$($MyInvocation.MyCommand): WARNING: Unable to shutdown VM '$VMName'. Ensure that VM is powered off."
                        }
                    }

                    $hasNetworksAdded = @()
                    foreach ($VMName in $VMNames) {
                        #Blog Post: Get each VM and ensure that the VM is powered down
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

                        #Blog Post: If we are modifying networking:
                        if ($NetworkNames) {
                            #Blog Post: If we are not keeping existing networks on the VM, then remove all existing networks on the VM
                            if (-not $KeepExistingNetworks) {
                                Write-Host "$($MyInvocation.MyCommand): Removing existing virtual interfaces"
                                $($VM.VIFs | Get-XenVIF) | Remove-XenVIF -ErrorAction SilentlyContinue
                                $VM = Get-XenVM -Name $VMName
                            }
                            #Blog Post: Add networks to VMs while making sure to skip duplicates and keep a device count
                            $existingNetworks = (($VM.VIFs | Get-XenVIF).network | Get-XenNetwork -ErrorAction SilentlyContinue).name_label
                            $existingDevices = @(($VM.VIFs | Get-XenVIF).device)
                            if ($existingDevices[0] -eq $null) { $existingDevices = @() }
                            foreach ($networkName in $NetworkNames) {
                                $network = Get-XenNetwork -Name $networkName
                                if ($network) {
                                    if ($existingNetworks -notcontains $network.name_label) {
                                        Write-Host "$($MyInvocation.MyCommand): Creating virtual interface connected to network '$($network.name_label)' on VM '$($VM.name_label)'"
                                        New-XenVIF -VM $VM -Network $network -Device $existingDevices.Count                                        
                                        $existingDevices += $existingDevices.Count
                                        if ($hasNetworksAdded -notcontains $VMName) {
                                            $hasNetworksAdded += $VMName
                                        }
                                    } else {
                                        Write-Host "$($MyInvocation.MyCommand): Network '$($network.name_label)' is already associated in one of the virtual interfaces on VM '$($VM.name_label)'"
                                    }
                                } else {
                                    throw "Network '$networkName' not found."
                                }
                            }
                        }
                        #Blog Post: If we are modifying CPU (we must always satisfy a CPU rule of 0 < VCPUs_at_startup ≤ VCPUs_max):
                        if ($CPUs) {
                            #In XenServer, cpu has to be set in a particular order to always satisfy the 0 < VCPUs_at_startup ≤ VCPUs_max
                            #This means that we must set each value separately because the Set-XenVM cmdlet has a specific order it acts on each parameter that doesn't play nicely when doing in bulk.
                            if ($VM.VCPUs_max -gt $CPUs) {
                                #Blog Post: If CPUs on VM are greater than our desired count, then we reduce start-up CPUs followed by max CPUs
                                Write-Host "$($MyInvocation.MyCommand): Changing number of VM CPUs to '$CPUs' on VM '$($VM.name_label)'"
                                Set-XenVM -VM $VM -VCPUsAtStartup $CPUs | Out-Null
                                Set-XenVM -VM $VM -VCPUsMax $CPUs | Out-Null
                            } elseif ($VM.VCPUs_max -lt $CPUs) {
                                #Blog Post: If CPUs on VM are less than our desired count, then we increase max CPUs followed by start-up CPUs
                                Write-Host "$($MyInvocation.MyCommand): Changing number of VM CPUs to '$CPUs' on VM '$($VM.name_label)'"
                                Set-XenVM -VM $VM -VCPUsMax $CPUs | Out-Null
                                Set-XenVM -VM $VM -VCPUsAtStartup $CPUs | Out-Null                                
                            } else {
                                #Blog Post: Otherwise, we skip this action
                                Write-Host "$($MyInvocation.MyCommand): Number of VM CPUs is already '$CPUs' on VM '$($VM.name_label)'"
                            }
                        }
                        #Blog Post: If we are modifying memory (we must always satisfy a memory rule of memory_static_min ≤ memory_dynamic_min ≤ memory_dynamic_max ≤ memory_static_max):
                        if ($MemoryGB) {
                            #In XenServer, memory has to be set in a particular order to always satisfy the memory_static_min ≤ memory_dynamic_min ≤ memory_dynamic_max ≤ memory_static_max constraint.
                            #This means that we must set each value separately because the Set-XenVM cmdlet has a specific order it acts on each parameter that doesn't play nicely when doing in bulk.
                            #Also, we follow the minimums that are also applied on XenCenter.
                            $memoryBytes = $MemoryGB*1GB
                            if ($memoryBytes -lt $VM.memory_static_min) {
                                #Blog Post: If desired memory amount is less than the static minimum, then change our desired amount to the memory static minimum
                                $MemoryGB = $VM.memory_static_min/1GB
                                Write-Host "$($MyInvocation.MyCommand): Changing amount of memory to '$($MemoryGB)GB' since that's the minimum"
                                $memoryBytes = $VM.memory_static_min
                            }
                            if ($VM.memory_static_max -gt $memoryBytes) {
                                #Blog Post: If static maximum memory on VM is greater than our desired amount, then we set dynamic minimum, followed by dynamic maximum, and finally static maximum
                                Write-Host "$($MyInvocation.MyCommand): Changing amount of VM memory to '$($MemoryGB)GB' on VM '$($VM.name_label)'"
                                Set-XenVM -VM $VM -MemoryDynamicMin $memoryBytes | Out-Null
                                Set-XenVM -VM $VM -MemoryDynamicMax $memoryBytes | Out-Null
                                Set-XenVM -VM $VM -MemoryStaticMax $memoryBytes | Out-Null
                            } elseif ($VM.memory_static_max -lt $memoryBytes) {
                                #Blog Post: If static maximum memory on VM is less than our desired amount, then we set the static maximum, followed by the dynamic maximum, and finally dynamic minimum
                                Write-Host "$($MyInvocation.MyCommand): Changing amount of VM memory to '$($MemoryGB)GB' on VM '$($VM.name_label)'"
                                Set-XenVM -VM $VM -MemoryStaticMax $memoryBytes | Out-Null
                                Set-XenVM -VM $VM -MemoryDynamicMax $memoryBytes | Out-Null
                                Set-XenVM -VM $VM -MemoryDynamicMin $memoryBytes | Out-Null
                            } else {
                                #Blog Post: Otherwise, we skip this action
                                Write-Host "$($MyInvocation.MyCommand): Amount of VM memory is already '$($MemoryGB)GB' on VM '$($VM.name_label)'"
                            }
                        }
                    }
                    #Blog Post: Get each VM and schedule the power on
                    foreach ($VMName in $VMNames) {
                        $VM = Get-XenVM -Name $VMName
                        Write-Host "$($MyInvocation.MyCommand): Scheduling power on of VM '$VMName'"
                        Invoke-XenVM -VM $VM -XenAction Start -Async
                    }
                    #Blog Post: If networks were added, then we wait until the VM is rebootable to schedule a graceful reboot to apply changes
                    if ($hasNetworksAdded) {
                        Write-Host "$($MyInvocation.MyCommand): Virtual interfaces were added to VMs which will require a reboot"
                        $firstVM = $true
                        foreach ($VMName in $hasNetworksAdded) {
                            Write-Host "$($MyInvocation.MyCommand): Ensuring that VM '$VMName' is in a rebootable state"
                            $try = 1
                            do {
                                $VM = Get-XenVM -Name $VMName
                                if ($VM.power_state -eq 'Running' -and $VM.allowed_operations -contains 'clean_reboot') {
                                    if ($firstVM) {
                                        Write-Host "$($MyInvocation.MyCommand): Sleeping $RebootDelay seconds to allow for configuration changes before rebooting"
                                        Start-Sleep -Seconds $RebootDelay
                                        $firstVM = $false
                                    }
                                    break
                                } else {
                                    Write-Host "$($MyInvocation.MyCommand): $($Tries-$try) retries left. Sleeping for $TryDelay seconds."
                                    $try++ 
                                    Start-Sleep -Seconds $TryDelay
                                }
                            } while ($try -le $Tries)
                            if ($try -gt $Tries) {
                                Write-Host "$($MyInvocation.MyCommand): WARNING: Unable to verify rebootable state on VM '$VMName'. Ensure to restart VM to complete changes."
                            } else {
                                $VM = Get-XenVM -Name $VMName
                                Write-Host "$($MyInvocation.MyCommand): Scheduling reboot of VM '$VMName'"
                                Invoke-XenVM -VM $VM -XenAction CleanReboot -Async
                            }
                        }
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
            #relict as pssnapin was replaced by powershell module
            #Blog Post: Remove the XenServer Snap-in
            #Write-Host "$($MyInvocation.MyCommand): Removing XenServerPSSnapIn PowerShell Snap-in"
            #Remove-PSSnapin XenServerPSSnapIn
        }
    } else {
        throw "XenServerPSSnapIn not found."
    }
} else {
    throw "Please specify CPU, Memory, and/or Network values."
}
}
