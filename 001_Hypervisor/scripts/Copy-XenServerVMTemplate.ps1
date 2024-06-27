#source: https://github.com/santiagocardenas/xenserver-powershell-scripts/blob/master/Copy-XenServerVMTemplate.ps1
<#
    .SYNOPSIS
        Creates a new XenServer VM by copying an existing VM or Template.
    .DESCRIPTION
        Creates a new XenServer VM by copying an existing VM or Template.
        Requires XenServer SDK's PowerShell Snap-in (new version).
    .PARAMETER VMNames
        Names of new VMs to be created.
    .PARAMETER SourceVMName
        Name of the VM to be used for copying.
    .PARAMETER SourceTemplateName
        Name of the Template to be used for copying.
    .PARAMETER XenServerHost
        The XenServer host to connect to. It must be the master of the pool.
    .PARAMETER UserName
        Username for XenServer host.
    .PARAMETER Password
        Password for XenServer host.
    .PARAMETER Clone
        Specify to clone instead of copy. Clone is thin provisioned (where possible) while Copy (this script's default) is thick provisioned.
    .PARAMETER StartVMs
        Specify to automatically start VMs after copying.
    .EXAMPLE
        Copy-XenServerVMTemplate.ps1 -VMNames "VM01","VM02" -SourceVMName "SOURCEVM" -XenServerHost "1.2.3.4" -UserName "root" -Password "p4ssw0rd"
        Description
        -----------
        Creates new VMs based on the provided source VM name through the XenServer host provided.
    .EXAMPLE
        Copy-XenServerVMTemplate.ps1 -VMNames "VM01","VM02" -SourceTemplateName "SOURCETEMPLATE" -XenServerHost "1.2.3.4" -UserName "root" -Password "p4ssw0rd"
        Description
        -----------
        Creates new VMs based on the provided source Template name through the XenServer host provided.
    .NOTES
        Copyright (c) Citrix Systems, Inc. All rights reserved.
        Version 1.0
#>

Param (
    [Parameter(Mandatory=$true)] [string[]]$VMNames,
    [Parameter(Mandatory=$true,ParameterSetName='VM')] [string]$SourceVMName,
    [Parameter(Mandatory=$true,ParameterSetName='Template')] [string]$SourceTemplateName,
    [Parameter(Mandatory=$true)] [string]$XenServerHost,
    [Parameter(Mandatory=$true)] [string]$UserName,
    [Parameter(Mandatory=$true)] [string]$Password,
    [Parameter(Mandatory=$false)] [switch]$Clone,
    [Parameter(Mandatory=$false)] [switch]$StartVMs
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
                $params = @{
                    Async = $true
                    PassThru = $true
                }
                #Blog Step: Get the source VM or Template
                if ($PSCmdlet.ParameterSetName -eq 'VM') {
                    $sourceVM = Get-XenVM -Name $SourceVMName
                    $params.Add("VM",$sourceVM)
                } elseif ($PSCmdlet.ParameterSetName -eq 'Template') {
                    $sourceTemplate = Get-XenVM -Name $SourceTemplateName
                    $params.Add("VM",$sourceTemplate)
                }
                #Blog Step: Decide if we’re doing a clone or copy (i.e. thin vs. thick provision)
                if ($Clone) {
                    Write-Host "$($MyInvocation.MyCommand): CLONE MODE"
                    $params.Add("XenAction","Clone")
                } else {
                    Write-Host "$($MyInvocation.MyCommand): COPY MODE"
                    $params.Add("XenAction","Copy")
                }
                #Blog Step: Schedule the creation of the VMs
                $xenTasks = @()
                foreach ($VMName in $VMNames) {
                    if ($PSCmdlet.ParameterSetName -eq 'VM') {
                        Write-Host "$($MyInvocation.MyCommand): Scheduling creation of VM '$VMName' from VM '$SourceVMName'"
                    } elseif ($PSCmdlet.ParameterSetName -eq 'Template') {
                        Write-Host "$($MyInvocation.MyCommand): Scheduling creation of VM '$VMName' from Template '$SourceTemplateName'"
                    }

                    $xenTasks += Invoke-XenVM -NewName $VMName @params
                }
                #Blog Step: Wait for the creation to finish
                Write-Host "$($MyInvocation.MyCommand): Waiting for copy/clone to finish..."
                foreach ($xenTask in $xenTasks) {
                    $xenTask | Wait-XenTask -ShowProgress
                }
                #Blog Step: If we started with templates, then we need to provision VMs from the copies/clones and wait for the provisioning to finish
                if ($PSCmdlet.ParameterSetName -eq 'Template') {
                    $xenTasks = @()
                    foreach ($VMName in $VMNames) {
                        Write-Host "$($MyInvocation.MyCommand): Provisioning VM '$VMName'"
                        $xenTasks += Invoke-XenVM -Name $VMName -XenAction Provision -Async -PassThru
                    }

                    Write-Host "$($MyInvocation.MyCommand): Waiting for provisioning to finish..."
                    foreach ($xenTask in $xenTasks) {
                        $xenTask | Wait-XenTask -ShowProgress
                    }
                }
                #Blog Step: If we want to start the VMs, then get each VM and schedule a power on
                if ($StartVMs) {
                    foreach ($VMName in $VMNames) {
                        $VM = Get-XenVM -Name $VMName
                        Write-Host "$($MyInvocation.MyCommand): Scheduling power on of VM '$VMName'"
                        Invoke-XenVM -VM $VM -XenAction Start -Async
                    }
                }
            }
            finally {
                #Blog Step: Disconnect from XenServer pool master
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
