#region Xen Functions
function Example-Example {
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
#>
    
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $ParameterName
    )

    BEGIN
    {
        $WarningPreference = "Continue"
        $VerbosePreference = "Continue"
        $InformationPreference = "Continue"
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Example"
        $startDate = Get-Date
    }

    PROCESS
    {
        try {

        }
        catch {

        }
    }

    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Connect-PLXen
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$XenHost,
        
        #[Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$false)]
        #[ValidateNotNull()]
        #[System.Management.Automation.PSCredential]
        #[System.Management.Automation.Credential()]
        #$Credential = [System.Management.Automation.PSCredential]::Empty
        
        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$false)]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]$Credential = [System.Management.Automation.PSCredential]::Empty
        
    )

    BEGIN
    {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Initiating the connection to the Hypervisor"
        $startDate = Get-Date
    }

    PROCESS
    {
        try {
            Write-Warning "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Setting connection to Xen withouth warning about certificates"
            $Global:Session = Connect-XenServer -Url "https://$($XenHost)" -Creds $Credential -NoWarnCertificates -SetDefaultSession
        } 
  
        catch [XenAPI.Failure] {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error in setting connection to Xen"
            #[System.Windows.MessageBox]::Show("$($_.Exception), try connecting to $($_.Exception.ErrorDescription[1])")
        }
    }

    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Disconnect-PLXen
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
#>

    [CmdletBinding()]
    Param ()

    BEGIN
    {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Terminating the connection to the Hypervisor"
        $startDate = Get-Date
    }

    PROCESS
    {
        try {
            if($Global:Session) {
                try {
                    #Write-Information "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Section if."
                    Write-Warning "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Disconnecting from the exsiting session"
                    #$Global:Session | Disconnect-XenServer
                    Disconnect-XenServer
                }
                catch {
                    Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error 1 in disconnecting from Xen"
                }
            }
            else {
            try {
                #Write-Information "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Section else"
                Write-Warning "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Disconnecting from the exsiting session"
                Disconnect-XenServer
            }
            catch {
                Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error 2 in disconnecting from Xen"
            }
            
            }
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error in disconnecting from Xen"
        }
    }

    END {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Get-PLXenTemplate
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
#>
    
        [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$false)]
            [ValidateSet("default","custom")]
            $Type
        )
    
        BEGIN
        {
            Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Getting details about templates"
            $startDate = Get-Date
        }
    
        PROCESS
        {
            try {
                switch($Type){
                    "custom" {
                        $AllCustomXenTemplates = (Get-XenVM | Where-Object { $_.is_a_template -eq $True -and !($_.other_config.default_template) -and $_.is_a_snapshot -eq $False} | Sort-Object -Property name_label).name_label
                        #foreach($CustomXenTeplate in $AllCustomXenTemplates) {
                        #    Write-Output $CustomXenTeplate
                        #}
                        return $AllCustomXenTemplates            
                    }
                    "default"{
                        $AllDefaultXenTemplates = (Get-XenVM | Where-Object { $_.is_a_template -eq $True -and $_.other_config.default_template } | Sort-Object -Property name_label).name_label
                        #foreach($DefaultXenTeplate in $AllDefaultXenTemplates){
                        #    Write-Output $DefaultXenTeplate
                        #    #$DropDownTemplates.Items.Add($DefaultXenTeplate) | Out-Null
                        #}
                        return $AllDefaultXenTemplates
                    }
                    default {
                        Write-Warning "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Parameter Type not defined"
                    }
                }
            }
            catch {
                Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error during getting information about Templates"
            }
        }
    
        END
        {
            $endDate = Get-Date
            Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
        }
}

Function Get-PLXenSR
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
#>
    
    [CmdletBinding()]
    Param ()

    BEGIN
    {
        $WarningPreference = "Continue"
        $VerbosePreference = "Continue"
        $InformationPreference = "Continue"
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Enumerating names of storage repositories dedicated for VMs"
        $startDate = Get-Date
    }

    PROCESS
    {
        try {
            #add detail about the available, used and free space
            #return the values as object like it is for Get-PLXenStorage
            $storageNameLabels = (Get-XenSR -ErrorAction SilentlyContinue | Sort-Object -Property name_label | Select-Object type,name_label | Where-Object {($_.type -ne "iso") -and ($_.name_label -ne "Removable storage") -and ($_.name_label -ne "DVD drives") -and ($_.name_label -ne "XenServer Tools") -and ($_.type -ne "iso")}).name_label
            return $storageNameLabels        
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error with getting details about storage lables"
        }
    }

    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Get-PLXenStorage
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
#>
    [CmdletBinding()]
    Param ()

    BEGIN
    {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Getting details about storage"
        $startDate = Get-Date
    }

    PROCESS
    {
        try {
            #$DiskSize = 20
            $storageRepository = Get-XenSR
            $storageDetails = @()
            $storageRepository.foreach({
                $obj = [PSCustomObject]@{ 
                    SRUUID = $_.uuid
                    SRNameLabel = $_.name_label
                    SRNameDescription = $_.name_description
                    SRtype = $_.type
                    SRContentType = $_.content_type
                    SRShared = $_.shared
                    SROtherConfig = $_.other_config
                    SRSMConfig = $_.sm_config
                    #SRName = $_
                    SRSizeGB = "{0:N2}" -f (($_.physical_size) / 1GB)
                    SRUsedGB = "{0:N2}" -f (($_.physical_utilisation) / 1GB)
                    SRFreeGB = "{0:N2}" -f (($_.physical_size - $_.physical_utilisation) / 1GB)
                }
            $storageDetails += $obj
            })
            #$MaxDiskSize = ((Get-PLXenSR -Name $DropDownStorage.SelectedItem).physical_size - (Get-PLXenSR).physical_utilisation) / 1GB
            return $storageDetails
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error with getting details about storage"
        }
    }

    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Get-PLXenNetwork
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
#>
    
    [CmdletBinding()]
    Param ()
    
    BEGIN
    {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Getting details about Network"
        $startDate = Get-Date
        #if(Get-XenSession){
        #    Write-Output $true
        #}
        #else{Write-Output $false}
    }
    
    PROCESS
    {
        try {
        #$AllNetworks = (Get-XenNetwork -ErrorAction SilentlyContinue).name_label | Sort-Object
        $xenNetwork = Get-XenNetwork
        #(Get-XenNetwork -ErrorAction SilentlyContinue).name_description | Sort-Object
         $xenNetworkConfig = @()
         $xenNetwork.foreach({
            $obj = [PSCustomObject]@{
                NetworkUUID = $_.uuid
                NetworkLabel = $_.name_label
                NetworkDescription = $_.name_description
                NetworkBridge = $_.bridge
                NetworkMTU = $_.MTU
            }
            $xenNetworkConfig += $obj
         })        
        
        return $xenNetworkConfig
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error with getting details about Network"
        }
    }
    
    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Get-PLXenRam
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
#>
    
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$false)]
        [ValidateSet("Free","Total")]
        [String]$Type
    )
    
    BEGIN
    {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Getting Details about memory"
        $startDate = Get-Date
    }
    
    PROCESS
    {
        try {
            switch($Type){
                "Free" {
                    try {
                        $ramAmount = (Get-XenHostMetrics -ErrorAction SilentlyContinue).memory_free | ForEach-Object {("{0:N0}" -f ($_ / 1GB)-1)} | Sort-Object | Select-Object -First 1
                        return $ramAmount
                    }
                    catch {
                        Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error with getting details about free amount of memory"
                    }
                
                }
                "Total" {
                    try {
                        $ramAmount = (Get-XenHostMetrics -ErrorAction SilentlyContinue).memory_total | ForEach-Object {("{0:N0}" -f ($_ / 1GB)-1)} | Sort-Object | Select-Object -First 1
                        return $ramAmount
                    }
                    catch {
                        Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error with getting details about total amount of memory"
                    }
                }
                default {
                    Write-Warning "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Parameter Type not defined"
                }
            }
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error with getting details about memory"
        }
    }
    
    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Get-PLXenCpuCount
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
#>

    [CmdletBinding()]
    Param ()

    BEGIN
    {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Getting details about CPU threads"
        $startDate = Get-Date
    }
    
    PROCESS
    {
        try {
            #$BaseCPUCount = 1
            $MaxCPUCount = ((Get-XenHostCpu -ErrorAction SilentlyContinue).number | Sort-Object -Descending | Select-Object -Unique -First 1)+1
            return $MaxCPUCount
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error with getting details about CPU"
        }
    }
    
    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Get-PLXenIsoRepository
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
#>
    
    [CmdletBinding()]
    Param ()

    BEGIN
    {
        $WarningPreference = "Continue"
        $VerbosePreference = "Continue"
        $InformationPreference = "Continue"
        $startDate = Get-Date
        $xenToolsRegex = "XCP-ng Tools|XenServer Tools"
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Getting details about all available IsO repositories"
    }

    PROCESS
    {
        try {
            #zdaje sie ze mozna spradzac other_config czy jest dirty wtedy oznaczac to moze ze jest niedostepne
            $ISORepository = (Get-XenSR | Where-Object {$_.type -eq "iso" -and $_.name_label -notmatch $xenToolsRegex}).name_label
            return $ISORepository
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error with getting details about storage repository"
        }
    }

    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Get-PLXenIsoLibrary
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
#>

    [CmdletBinding()]
    Param ()

    BEGIN
    {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Getting details about ISO library"
        $startDate = Get-Date
        $xenToolsRegex = "XCP-ng Tools|XenServer Tools"
        $SRIsoDetails = @()
    }

    PROCESS
    {
        try {
            #$isoPath = [regex]::Matches($((Get-XenSR | Where-Object {$_.type -eq "iso" -and $_.name_label -notmatch $xenToolsRegex}).name_description), '(?<=\[).+?(?=\])').Value
            $SRIso = (Get-XenSR | Where-Object {$_.type -eq "iso" -and $_.name_label -notmatch $xenToolsRegex})
            $SRIso.ForEach({
                $PBD = Get-XenPBD ($_.PBDs).opaque_ref
                $obj = [PSCustomObject]@{
                    SRIsoUUID = $_.uuid
                    SRIsoNameLabel = $_.name_label
                    SRIsoNameDescription = $_.name_description
                    SRIsoVirtualAllocationGB = [int32]($_.virtual_allocation / 1GB)
                    SRIsoPhysicalUtilizationGB = [int32]($_.physical_utilization / 1GB)
                    SRIsoPhysicalSizeGB = [int32]($_.physical_size / 1GB)
                    SRIsoType = $_.type
                    SRIsoContentType = $_.content_type
                    SRIsoShared = $_.shared
                    SRIsoOtherConfig = $_.other_config
                    SRIsoSMConfig = $_.sm_config
                    SRIsoPBD = $PBD.uuid
                    SRIsoPBDLocation = $PBD.device_config.location
                    SRIsoPBDType = $PBD.device_config.type
                    SRIsoPDBCifsvers = $PBD.device_config.vers
                    SRIsoPBDNfsvers = $PBD.device_config.nfsversion
                    SRIsoPBDUsername = $PBD.device_config.username
                }
                $SRIsoDetails += $obj
            })
            return $SRIsoDetails
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error with getting details about ISO library"
        }
    }

    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Get-PLXenIso
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("SRIsoNameLabel")]
        [String[]]$SRName
    )

    BEGIN
    {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Getting details about ISOs"
        $startDate = Get-Date
    }

    PROCESS
    {
        try {
            $all = $SRName.ForEach({Get-XenSR -Name $_ | Select-Object -ExpandProperty VDIs})
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error with all"
        }

        try {
        #leave the Allocation and utilization in default values dont' convert them here into GB with default /1GB
        #if you do it in regular basis without extra checks it will throw erors
        #perform the action somewhere else with Select-Object and expressions on the output of the function
        #$allIso = (Get-XenSR -Name $_ | Select-Object -ExpandProperty VDIs | Get-XenVDI | Where-Object {$_.name_label -match ".iso"})
        $allIso = $all | Get-XenVDI | Where-Object {$_.name_label -match ".iso"}
            $isoDetails = @()
            $allIso.ForEach({
                $SR = (Get-XenSR $_.SR)
                $obj = [PSCustomObject]@{
                    SRUUID = $SR.uuid
                    SRNameLabel = $SR.name_label
                    SRNameDescription = $SR.name_description
                    SRVirtualAllocation = $SR.virtual_allocation
                    SRPhysicalUtilization = $SR.physical_utilisation
                    SRPhysicalSize = $SR.physical_size
                    IsoUUID = $_.uuid
                    #IsoOpaque_ref = $_.opaque_ref
                    IsoLabel = $_.name_label
                    IsoDescription = $_.name_description
                    IsoVirtualSize = $_.virtual_size
                    IsoPhysicalUtilization = $_.physical_utilisation
                    IsoReadOnly = $_.read_only
                    IsoIsToolsIso = $_.is_tools_iso
                }
                $isoDetails += $obj
            })
        return $isoDetails
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error with getting details about ISOs"
        }        
    }

    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Get-PLXenVMNetwork
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
This is a rewritten version of https://discussions.citrix.com/topic/381379-retrieve-guest-vm-network-information-from-xenserver-65-with-powershell/
#>
    
    [CmdletBinding()]
    Param()

    BEGIN 
    {
        #Start-Process 'https://discussions.citrix.com/topic/381379-retrieve-guest-vm-network-information-from-xenserver-65-with-powershell/'
        #Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Getting details about VM and its networks"
        $startDate = Get-Date
        
        $xenVMs = @()
        $xenVMproperties = @{
            Name = ''
            UUID = ''
            CPUCount = ''
            Description = ''
            IsTemplate = ''
            MemoryStaticMax =''
            PowerState = ''
            NICID = ''
            NICNetworkName = ''
            NICMAC = ''
            NICVLAN = ''
            NICIP = ''
        }
    }

    PROCESS
    {
        $vms = Get-XenVM | Where-Object {$_.is_a_template -ne "False" -and $_.is_control_domain -ne "False"} #get all vms
        foreach ($vm in $vms){
            $gm = Get-XenVMProperty -VM $vm -XenProperty GuestMetrics
            if ($vm.VIFs.Count -gt 1)
            {
                for ($i=0; $i -lt $vm.VIFs.Count;$i++)
                {
                    $xenVM = New-Object psobject -Property $xenVMproperties

                    $xenVM.Name = $vm.name_label
                    $xenVM.PowerState = $vm.power_state
                    $xenVM.UUID = $vm.uuid
                    $xenVM.Description = $vm.name_description
                    $xenVM.IsTemplate = $vm.is_a_template
                    $xenVM.MemoryStaticMax = $vm.memory_static_max / 1GB
                    $xenVM.CPUCount = $vm.vcpus_max
                    $vif = Get-XenVIF -Ref $vm.VIFs[$i]
                    $net = Get-XenNetwork -Ref $vif.network
                    $xenVM.NICNetworkName = $net.name_label
                    $pif = Get-XenPIF -Ref $net.PIFs[0]
                    $xenVM.NICVLAN = $pif.VLAN
                    $xenVM.NICMAC = $vif.MAC
                    $xenVM.NICID = $vif.device
                    $xenVM.NICIP = ($gm.networks)[ $vif.device + "/ip"]
                    $xenVMs += $xenVM
                }
            }
            elseif ($vm.VIFs.Count -eq 1)
            {
                $xenVM = New-Object psobject -Property $xenVMproperties
        
                $xenVM.Name = $vm.name_label
                $xenVM.PowerState = $vm.power_state
                $xenVM.UUID = $vm.uuid
                $xenVM.Description = $vm.name_description
                $xenVM.IsTemplate = $vm.is_a_template
                $xenVM.MemoryStaticMax = $vm.memory_static_max / 1GB
                $xenVM.CPUCount = $vm.vcpus_max
                $vif = Get-XenVIF -Ref $vm.VIFs[0]
                $net = Get-XenNetwork -Ref $vif.network
                $xenVM.NICNetworkName = $net.name_label
                $pif = Get-XenPIF -Ref $net.PIFs[0]
                $xenVM.NICVLAN = $pif.VLAN
                $xenVM.NICMAC = $vif.MAC
                $xenVM.NICID = $vif.device
                $xenVM.NICIP = ($gm.networks)[ $vif.device + "/ip"]
                $xenVMs += $xenVM
            }

            else
            {
                $xenVM = New-Object psobject -Property $xenVMproperties
            
                $xenVM.Name = $vm.name_label
                $xenVM.PowerState = $vm.power_state
                $xenVM.UUID = $vm.uuid
                $xenVM.Description = $vm.name_description
                $xenVM.IsTemplate = $vm.is_a_template
                $xenVM.MemoryStaticMax = $vm.memory_static_max / 1GB
                $xenVM.CPUCount = $vm.vcpus_max
                $xenVM.NICID = 'No NIC Attached'
                $xenVM.NICNetworkName = 'No NIC Attached'
                $xenVM.NICVLAN = 'No NIC Attached'
                $xenVM.NICMAC = 'No NIC Attached'
                $xenVM.NICIP = 'No IP Available'
                $xenVMs += $xenVM
            }
        }
    return $xenVms
    }

    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Set-PLXenVM
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
#>
    
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Name")]
        [String[]]$VMName,

        [Parameter(Mandatory=$false,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Regex")]
        [String]$VMNameRegex,

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
        [ValidateNotNullOrEmpty()]
        [Alias("Order")]
        [ValidateSet("cdn","dcn","ndc","cd","dc","c")]
        [String]$BootOrder = 'cdn',

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
        [ValidateNotNullOrEmpty()]
        #[Alias("Order")]
        [ValidateSet("bios","uefi")]
        [String]$Firmware = 'bios',

        [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
        [ValidateNotNullOrEmpty()]
        #[Alias("AutoOn")]
        [ValidateSet($true,$false,0,1)]
        [Boolean]$AutoPowerOn = $false
    )

    BEGIN
    {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Setting VM parameter"
        $startDate       = Get-Date
        $vmNameFlag      = $false
        $vmNameRegexFlag = $false
        $firmwareFlag    = $false
        $bootOrderFlag   = $false
        $otherConfigFlag = $false

        if($PSBoundParameters.ContainsKey('VMName')){
            $vmNameFlag = $true
        }

        if($PSBoundParameters.ContainsKey('VMNameRegex')){
            $vmNameRegexFlag = $true
        }

        if($PSBoundParameters.ContainsKey('BootOrder')){
            $bootOrderFlag = $true
            #$bootParams = @{order = 'cdn'}
            $bootParams = @{order = $BootOrder}
        }

        if($PSBoundParameters.ContainsKey('Firmware')){
            $firmwareFlag = $true
            #$bootParams = @{order = "dc"; firmware = "bios"}
            #$bootParams = @{firmware = "bios"}
            $bootParams = @{firmware = $Firmware}
        }

        if($PSBoundParameters.ContainsKey('AutoPowerOn')){
            $otherConfigFlag = $true
            if($AutoPowerOn -eq $true){
                $otherConfig = @{auto_poweron = 'true'}
            }
            else{
                $otherConfig = @{auto_poweron = 'false'}
            }
        }
    }

    PROCESS
    {
        if($vmNameFlag -and $bootOrderFlag){
            Write-Verbose "bootorder: $BootOrder"
            Write-Verbose "vmNameFlag and bootOrderFlag"
            $vm = foreach($element in $VMName){
                Write-Verbose $element
                Set-XenVM -VM (Get-XenVM -Name $element) -HVMBootParams $bootParams -Verbose
            }
        }

        if($vmNameRegexFlag -and $bootOrderFlag){
            Write-Verbose "bootorder: $BootOrder "
            Write-Verbose "vmNameRegexFlag and bootOrderFlag"
            $allXenVm = (Get-XenVM | Where-Object {($_.is_a_template -eq $False) -and !($_.other_config.default_template) -and ($_.is_a_snapshot -eq $False)} | Sort-Object -Property name_label)
            #$xenVm = $allXenVm | Where-Object {$_ -match $vmNameRegex}
            $xenVm = foreach($element in ($allXenVm | Where-Object {$_.name_label -match $vMNameRegex})){
                Write-Verbose "$($element.name_label) bootOrder: $($bootOrder)"
                Set-XenVM -VM $element -HVMBootParams $bootParams -Verbose
            }
        }

        if($vmNameFlag -and $otherConfigFlag){
            if($AutoPowerOn){ #AutoPowerOn = $true
                $otherConfig = @{auto_poweron = 'true'}
            }
            else{ #AutoPowerOn = $false
                $otherConfig = @{auto_poweron = 'false'}
            }
            
            Write-Verbose "bootorder: $BootOrder"
            Write-Verbose "vmNameFlag and bootOrderFlag"
            $vm = foreach($element in $VMName){
                Write-Verbose "$($element.name_label) otherConfig: $($otherConfig)"
                Set-XenVM -VM (Get-XenVM -Name $element) -OtherConfig $otherConfig -Verbose
            }
        }
        
        if($vmNameRegexFlag -and $otherConfigFlag){
            if($AutoPowerOn){ #AutoPowerOn = $true
                $otherConfig = @{auto_poweron = 'true'}
            }
            else{ #AutoPowerOn = $false
                $otherConfig = @{auto_poweron = 'false'}
            }
            Write-Verbose "bootorder: $BootOrder "
            Write-Verbose "vmNameRegexFlag and otherconfigFlag"
            $allXenVm = (Get-XenVM | Where-Object {($_.is_a_template -eq $False) -and !($_.other_config.default_template) -and ($_.is_a_snapshot -eq $False)} | Sort-Object -Property name_label)
            #$xenVm = $allXenVm | Where-Object {$_ -match $vmNameRegex}
            $xenVm = foreach($element in ($allXenVm | Where-Object {$_.name_label -match $vMNameRegex})){
                Write-Verbose "$($element.name_label) otherConfig: $($otherConfig)"
                Set-XenVM -VM $element -OtherConfig $otherConfig -Verbose
            }        
        }
        #Set-XenVM -VM (Get-XenVM -Name 'bootOrder') -HVMBootParams $bootParams
        #Set-XenVM -VM (Get-XenVM -Name 'bootOrder') -OtherConfig $otherConfig
    }

    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function New-PLXenVM
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
#>

#ToDo:
#add Firmware parameter will it be uefi or bios
#add BootOrder parameter to define in which order the drives are being set
#hvmbootparams: https://xenbits.xen.org/docs/unstable/man/xl.cfg.5.html

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("VmParameter")]
        [PScustomObject[]]$VmParam,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("uefi","bios")]
        [String]$Firmware,

        [Parameter(Mandatory=$false,Position=2,ValueFromPipelineByPropertyName=$false)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("False","True","Auto")]
        [String]$SecureBoot='False'
    )

    BEGIN
    {
        #region Xen Automation - CREATE VM - INITIALIZE - RUN THIS EVERY TIME UPFRONT OF VM CREATION - default template, VM param hashtable
        $xenDefaultTemplate = Get-PLXenTemplate -Type default -Verbose #get all default templates comming with the hypervisor
        #create an object which contains all default templates, and their regex, actually this is the same value pre and suffixed with (\ and \)

        $i = 0
        $xenDefaultTemplateObject = foreach ($element in $xenDefaultTemplate) {
            [PSCustomObject] @{
                "XenTemplateId"     = $i++
                "XenTemplateName"   = $element
                "XenTemplateRegex"  = ($element.Replace("(", "\(")).Replace(")", "\)")
                "XenTemplateObject" = Get-XenVM -Name $element
            }
        }
        #this changes every time there is an update of the Xcpn-g release
        #$xenDefaultTemplate
        # to see above execute $xenDefaultTemplateObject
        #if [24] is your choice then the template equals Ubuntu Focal Fossa 20.04
        #if [27] is your choice then the template equals Windows 10 (64-bit)
        #$vmSourceTemplateObject = $xenDefaultTemplateObject[20..34] | Where-Object {$_.XenTemplateName -match "Windows Server 2019"}
        #$vmSourceTemplateObject = $xenDefaultTemplateObject | Where-Object {$_.XenTemplateName -match $xenDefaultTemplateObject.XenTemplateRegex[33]}
        $vmSourceTemplateObject = $xenDefaultTemplateObject | Where-Object {$_.XenTemplateName -match $VmParam.VMSKU}

        $vmSourceTemplateObject
        #$vmSourceTemplateObject.XenTemplateObject

        #$VMDiskGB = $VmParam.VMDIskGB
        #$VMDiskBytes = $VmParam.VMDiskGB * 1073741824
        $VMDiskName = "{0}-{1}" -f $VmParam.VMName, "OsStorage"
        $VMDiskDescription = "{0}-{1}-{2}" -f $vmParam.VMName,"OsStorage",$vmSourceTemplateObject.XenTemplateName
        #$VMDiskBytes = $VMDiskGB * 1073741824
        #Get-PLXenIso
        #List all ISO files from available ISO repositories
        #Get-PLXenISOLibrary | Where-Object {$_.SRIsoOtherconfig.Values -match "true"} | Select-Object SRIsoNameLabel | Get-PLXenIso -Verbose | Select-Object IsoLabel
        #$VMBootISOName = 'w10entN_19H2_unattended_updated202111.iso'# 'xs82Tools.iso'
        #$VMBootISOName = 'w2k19core_1809LTSC_unattended_updated2111.iso'

        if($VmParam.VMSKU -match 'Windows Server'){
            $vmEvalExpirationDate = (Get-Date (Get-Date ).AddDays(180) -format "yyyyMMdd")
        }
        elseif ($VmParam.VMSKU -match "Windows 10|Windows 8.1"){
            $vmEvalExpirationDate = (Get-Date (Get-Date ).AddDays(90) -format "yyyyMMdd")
        }

            switch ($Firmware)
            {
                'bios'
                {
                    $newVMParamHash = @{
                        NameLabel               = $VmParam.VMName
                        NameDescription         = "$($VmParam.VMDescription) - evaluation expires - $vmEvalExpirationDate"
                        MemoryTarget            = $VmParam.VMRAM
                        MemoryStaticMax         = $VmParam.VMRAM
                        MemoryDynamicMax        = $VmParam.VMRAM
                        MemoryDynamicMin        = $VmParam.VMRAM
                        MemoryStaticMin         = $VmParam.VMRAM
                        VCPUsMax                = $VmParam.VMCPU
                        VCPUsAtStartup          = $VmParam.VMCPU
                        HVMBootPolicy           = $VmParam.HVMBootPolicy
                        HVMBootParams           = @{order = "dc"; firmware = "bios"} #boot order dvd, harddrive, firmware bios
                        HVMShadowMultiplier     = $VmParam.HVMShadowMultiplier
                        UserVersion             = $VmParam.UserVersion
                        ActionsAfterReboot      = $VmParam.ActionsAfterReboot
                        ActionsAfterCrash       = $vmParam.ActionsAfterCrash
                        ReferenceLabel          = ($vmSourceTemplateObject.XenTemplateObject).reference_label
                        HardwarePlatformVersion = $VmParam.HardwarePlatformVersion
                        Platform                = @{ 'cores-per-socket' = "$($VmParam.VMCPU)"; hpet = "true"; pae = "true"; vga = "std"; nx = "true"; viridian_time_ref_count = "true"; apic = "true"; viridian_reference_tsc = "true"; viridian = "true"; acpi = "1" }
                        OtherConfig             = @{ base_template_name = ($vmSourceTemplateObject.XenTemplateObject).reference_label }
                    }
                }
                'uefi'
                {
                    if($SecureBoot -match 'False')
                    {
                        $newVMParamHash = @{
                            NameLabel               = $VmParam.VMName
                            NameDescription         = "$($VmParam.VMDescription) - evaluation expires - $vmEvalExpirationDate"
                            MemoryTarget            = $VmParam.VMRAM
                            MemoryStaticMax         = $VmParam.VMRAM
                            MemoryDynamicMax        = $VmParam.VMRAM
                            MemoryDynamicMin        = $VmParam.VMRAM
                            MemoryStaticMin         = $VmParam.VMRAM
                            VCPUsMax                = $VmParam.VMCPU
                            VCPUsAtStartup          = $VmParam.VMCPU
                            HVMBootPolicy           = $VmParam.HVMBootPolicy
                            HVMBootParams           = @{order = "dc"; firmware = "uefi"} #boot order dvd, harddrive, firmware uefi
                            HVMShadowMultiplier     = $VmParam.HVMShadowMultiplier
                            UserVersion             = $VmParam.UserVersion
                            ActionsAfterReboot      = $VmParam.ActionsAfterReboot
                            ActionsAfterCrash       = $vmParam.ActionsAfterCrash
                            ReferenceLabel          = ($vmSourceTemplateObject.XenTemplateObject).reference_label
                            HardwarePlatformVersion = $VmParam.HardwarePlatformVersion
                            Platform                = @{ secureboot="false"; 'cores-per-socket' = "$($VmParam.VMCPU)"; hpet = "true"; pae = "true"; vga = "std"; nx = "true"; viridian_time_ref_count = "true"; apic = "true"; viridian_reference_tsc = "true"; viridian = "true"; acpi = "1" }
                            OtherConfig             = @{ base_template_name = ($vmSourceTemplateObject.XenTemplateObject).reference_label }
                        }
                    }
                    elseif ($SecureBoot -match 'True')
                    {
                        $newVMParamHash = @{
                            NameLabel               = $VmParam.VMName
                            NameDescription         = "$($VmParam.VMDescription) - evaluation expires - $vmEvalExpirationDate"
                            MemoryTarget            = $VmParam.VMRAM
                            MemoryStaticMax         = $VmParam.VMRAM
                            MemoryDynamicMax        = $VmParam.VMRAM
                            MemoryDynamicMin        = $VmParam.VMRAM
                            MemoryStaticMin         = $VmParam.VMRAM
                            VCPUsMax                = $VmParam.VMCPU
                            VCPUsAtStartup          = $VmParam.VMCPU
                            HVMBootPolicy           = $VmParam.HVMBootPolicy
                            HVMBootParams           = @{order = "dc"; firmware = "uefi"} #boot order dvd, harddrive, firmware uefi
                            HVMShadowMultiplier     = $VmParam.HVMShadowMultiplier
                            UserVersion             = $VmParam.UserVersion
                            ActionsAfterReboot      = $VmParam.ActionsAfterReboot
                            ActionsAfterCrash       = $vmParam.ActionsAfterCrash
                            ReferenceLabel          = ($vmSourceTemplateObject.XenTemplateObject).reference_label
                            HardwarePlatformVersion = $VmParam.HardwarePlatformVersion
                            Platform                = @{ secureboot="true"; 'cores-per-socket' = "$($VmParam.VMCPU)"; hpet = "true"; pae = "true"; vga = "std"; nx = "true"; viridian_time_ref_count = "true"; apic = "true"; viridian_reference_tsc = "true"; viridian = "true"; acpi = "1" }
                            OtherConfig             = @{ base_template_name = ($vmSourceTemplateObject.XenTemplateObject).reference_label }
                        }
                    }
                    elseif ($SecureBoot -match 'Auto')
                    {
                        $newVMParamHash = @{
                            NameLabel               = $VmParam.VMName
                            NameDescription         = "$($VmParam.VMDescription) - evaluation expires - $vmEvalExpirationDate"
                            MemoryTarget            = $VmParam.VMRAM
                            MemoryStaticMax         = $VmParam.VMRAM
                            MemoryDynamicMax        = $VmParam.VMRAM
                            MemoryDynamicMin        = $VmParam.VMRAM
                            MemoryStaticMin         = $VmParam.VMRAM
                            VCPUsMax                = $VmParam.VMCPU
                            VCPUsAtStartup          = $VmParam.VMCPU
                            HVMBootPolicy           = $VmParam.HVMBootPolicy
                            HVMBootParams           = @{order = "dc"; firmware = "uefi"} #boot order dvd, harddrive, firmware uefi
                            HVMShadowMultiplier     = $VmParam.HVMShadowMultiplier
                            UserVersion             = $VmParam.UserVersion
                            ActionsAfterReboot      = $VmParam.ActionsAfterReboot
                            ActionsAfterCrash       = $vmParam.ActionsAfterCrash
                            ReferenceLabel          = ($vmSourceTemplateObject.XenTemplateObject).reference_label
                            HardwarePlatformVersion = $VmParam.HardwarePlatformVersion
                            Platform                = @{ secureboot="auto"; 'cores-per-socket' = "$($VmParam.VMCPU)"; hpet = "true"; pae = "true"; vga = "std"; nx = "true"; viridian_time_ref_count = "true"; apic = "true"; viridian_reference_tsc = "true"; viridian = "true"; acpi = "1" }
                            OtherConfig             = @{ base_template_name = ($vmSourceTemplateObject.XenTemplateObject).reference_label }
                        }
                    }

                }
            }

        #endregion
    }

    PROCESS
    {
        #region Xen Automation - CREATE VM - Create the VM Object / Skeleton
        New-XenVM @newVMParamHash -Verbose
        #endregion

        #region Xen Automation - CREATE VM - Check if VM Skeleton was created
        Get-XenVM -Name $VmParam.VMName
        #endregion

        #region Xen Automation - CREATE VM - Create disk object for the VM placeholder
        $xenSr = Get-XenSR -Name $VmParam.VMSR
        New-XenVDI -NameLabel $VMDiskName -VirtualSize ($VmParam.VMDiskGB * 1073741824) -SR $xenSr -Type user -NameDescription $VMDiskDescription -Verbose
        #New-XenVDI -NameLabel ("{0}-{1}" -f $VmParam.VMName, "OsStorage") -VirtualSize ($VmParam.VMDiskGB * 1073741824) -SR $SR -Type user -NameDescription $VMDiskDescription -Verbose
        #New-XenVDI -NameLabel $VMDiskName -VirtualSize $VMDiskBytes -SR $SR -Type user -NameDescription $VMDiskDescription -Verbose
        #endregion

        #region Xen Automation - CREATE VM - Bind disk with the VM
        #There is no logic included here which perform any sort of prechecks whether there are two VM's with the same name which is feasible on Xen as those differentiate between each by UUID
        #If there are two VMs with the same name of hypervisor level, then below code does work properly
        $xenVm = Get-XenVM -Name $VmParam.VMName
        $xenVdi = Get-XenVDI -Name $VMDiskName
        New-XenVBD -VM $xenVm.opaque_ref -VDI $xenVdi.opaque_ref -Type Disk -mode RW -Userdevice 0 #add disk to the VM 
        #New-XenVBD -VM $xenVm.opaque_ref -VDI $xenVdi.opaque_ref -Type Disk -mode RW -Userdevice 0 -Unpluggable $true -Bootable $true #przetestowac 2022.01.04
        #New-XenVBD -VM $xenVm.opaque_ref -VDI $xenVdi.opaque_ref -Type Disk -mode RW -Userdevice 2 #add disk to the VM as device ID 2
        #endregion

        #region Xen Automation - CREATE VM - Bind CD with the VM
        #There is no logic included here which perform any sort of prechecks whether there are two VM's with the same name which is feasible on Xen as those differentiate between each by UUID
        #If there are two VMs with the same name of hypervisor level, then below code does work properly
        $xenVm = Get-XenVM -Name $VmParam.VMName
        $xenVdi = Get-XenVDI -Name $VMDiskName
        New-XenVBD -VM $xenVm.opaque_ref -VDI $xenVdi.opaque_ref -Type CD -mode RO -Userdevice 3 -Bootable $false -Unpluggable $true -Empty $true  #add CD/DVD to the VM, 3 in case other two disks are planned to be used as id 1 and 2
        #endregion

        #region Xen Automation - CREATE VM - Mount ISO into the DVD bay
        #Get-XenVDI -Name "xs82Tools.iso" | Invoke-XenVBD -Uuid (Get-XenVBD)[2].uuid -XenAction Insert
        Get-XenVM -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object { $_.type -eq "CD" } | Invoke-XenVBD -XenAction Insert -VDI (Get-XenVDI -Uuid (Get-PLXenIso -SRName $nodeIsoSR | Where-Object { $_.IsoLabel -match $VmParam.VMBootISO }).IsoUUID | Select-Object -ExpandProperty opaque_ref) #mount iso
        #Get-XenVM -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object { $_.type -eq "CD" } | Invoke-XenVBD -XenAction Insert -VDI (Get-XenVDI -Uuid (Get-PLXenIso -SRName "centos8NfsIso" | Where-Object { $_.IsoLabel -match $VMBootISOName }).IsoUUID | Select-Object -ExpandProperty opaque_ref) #mount iso
        #endregion

        #region Xen Automation - CREATE VM - Bind networks with the VM
        #To explicitly enter a MAC address, select Use this MAC address. 
        #Enter an address in the form XY:XX:XX:XX:XX:XX where 
        #                 X is any hexadecimal digit, and 
        #                 Y is one of 2, 6, A or E.

        $xenVm = Get-XenVM -Name $VmParam.VMName
        #this piece of code comes from https://github.com/santiagocardenas/xenserver-powershell-scripts/blob/master/Set-XenServerVMResources.ps1
        #Blog Post: Add networks to VMs while making sure to skip duplicates and keep a device count
        $existingNetworks = (($xenVm.VIFs | Get-XenVIF).network | Get-XenNetwork -ErrorAction SilentlyContinue).name_label
        $existingDevices = @(($xenVm.VIFs | Get-XenVIF).device)
        if ($null -eq $existingDevices[0]) { $existingDevices = @() }
        foreach ($networkName in $VmParam.NetworkName) {
            $xenNetwork = Get-XenNetwork -Name $networkName
            if ($xenNetwork) {
                if ($existingNetworks -notcontains $xenNetwork.name_label) {
                    Write-Output "$($MyInvocation.MyCommand): Creating virtual interface connected to network '$($xenNetwork.name_label)' on VM '$($xenVm.name_label)'"
                    #New-XenVIF -VM $xenVm -Network $xenNetwork -Device $existingDevices.Count
                    #New-XenVIF -VM $xenVm -Network $xenNetwork -Device $existingDevices.Count -MAC $VmParam.MAC
                    #New-XenVIF -VM $xenVm -Network $xenNetwork -Device $existingDevices.Count -MAC $VmParam.MAC -MTU $VmParam.MTU -Ipv4Allowed 'true'
                    New-XenVIF -VM $xenVm -Network $xenNetwork -Device $existingDevices.Count -MAC $VmParam.MAC -Ipv4Allowed 'true' -Ipv6Allowed 'false' -Verbose
                    $existingDevices += $existingDevices.Count
                    if ($hasNetworksAdded -notcontains $VmParam.VMName) {
                        $hasNetworksAdded += $VmParam.VMName
                    }
                }
                else {
                    Write-Output "$($MyInvocation.MyCommand): Network '$($xenNetwork.name_label)' is already associated in one of the virtual interfaces on VM '$($xenVm.name_label)'"
                }
            }
            else {
                throw "Network '$networkName' not found."
            }
        }
        #endregion
    }

    END
    {

    }
}

Function Start-PLXenVM
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("VmName")]
        [String[]]$ComputerName
    )

    BEGIN
    {
        #Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Starting Vm"
        $startDate = Get-Date
    }

    PROCESS
    {
        try {
            $ComputerName.ForEach({
                Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Starting VM: $_"
                Invoke-XenVM -Name $_ -XenAction Start -Async
            })
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error when starting VM"
        }
    }

    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Stop-PLXenVM
{
<#
.SYNOPSIS 
This function stop the vm running on Xen.

.DESCRIPTION 
Use this function to stop vm running on Xen.

.PARAMETER VMName
Name of the Vm to be stopped

.PARAMETER Force
Use this parameter if you plan to do hardStop

.EXAMPLE 
Stop-PLXenVM -VmName _w10-mgmt -Verbose

Description example 1.

.EXAMPLE 
Stop-PLXenVM -VmName _w10-mgmt -Force -Verbose

Description example 2.

.EXAMPLE 
_w10-mgmt | Stop_PLXenVM -Verbose

Description example 3.
#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("VmName")]
        [String[]]$ComputerName,

        [Parameter(Mandatory=$false,Position=1,ValueFromPipelineByPropertyName=$false)]
        [Switch]$Force
    )

    BEGIN
    {
        #Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Stop VM"
        $startDate = Get-Date
    }

    PROCESS
    {
        try {
            if($Force){
                $ComputerName.ForEach({
                    Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Starting VM: $_"
                    Invoke-XenVM -Name $_ -XenAction HardShutdown -Async
                })
            }
            
            $ComputerName.ForEach({
                Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Shutting down VM: $_"
                Invoke-XenVM -Name $_ -XenAction CleanShutdown -Async
            })
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error when shutting down VM: $_"
        }
        
    }

    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Restart-PLXenVM
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER One
.PARAMETER Two
.EXAMPLE
.EXAMPLE
.LINK
#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("VmName")]
        [String[]]$ComputerName,

        [Parameter(Mandatory=$false,Position=1,ValueFromPipelineByPropertyName=$false)]
        [Switch]$Force
    )

    BEGIN
    {
        #Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Restart VM"
        $startDate = Get-Date
    }

    PROCESS
    {
        try {
            if($Force){
                $ComputerName.ForEach({
                Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Restarting VM: $_"
                Invoke-XenVm -Name $_ -XenAction HardReboot -Async
                })
            }
            
            $ComputerName.ForEach({
                Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Restarting VM: $_"
                Invoke-XenVm -Name $_ -XenAction CleanReboot -Async
            })
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error when restarting VM: $_"
        }
        
    }

    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function New-PLXenSnapshotVM
{
<#
.SYNOPSIS 
This function creates snapshot of the the Vm.

.DESCRIPTION 
Use this function to create snapshot of the Vm.
It is creating the snapshot on the storage repository, where the VM is being provisioned.

.PARAMETER VMName
Name of the Vm to create snapshot of.

.PARAMETER SnaphostName
Name of the Snapshot which helps identifying what it contains.

.EXAMPLE 
New-PLXenSnapshotVM -VmName _w10-mgmt -SnapshotName 'BeforeApplyingConfig' -Verbose

Description example 1.

.EXAMPLE
@('_w10-mgmt','_w11-mgmt') | New-PLXenSnapshotVM -SnapshotName 'BeforeApplyingConfig' -Verbose

Description example 2.
#>

    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Name")]
        [String[]]$VmName,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$false)]
        [ValidateNotNullOrEmpty()]
        #[Alias("SnpName")]
        [String]$SnapshotName
    )

    BEGIN
    {
        #Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Restart VM"
        $startDate = Get-Date
    }

    PROCESS
    {
        #$Snapshotname = “SNAPSHOTNAME”
        $VmName.ForEach({
            try {
                $VM = Get-XenVM -Name $_
            }
            catch {
                Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error when getting details about Virtual Machine: $_"
            }
            
            try {
                if($VM){                    
                    Write-Verbose "env:COMPUTERNAME - $($MyInvocation.MyCommand) - Creating Snapshot of $_ - $snapshotName"
                    Invoke-XenVM -Uuid $VM.uuid -XenAction Snapshot -NewName "$_-$snapshotName" -Verbose
                }
                else {
                    Write-Warning "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - VM: $($_) does NOT exist"
                }
            }
            catch {
                Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error when creating snapshot of Virtual Machine: $_"
            }
        })
    }

    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Remove-PLXenSnapshotVM
{
<#
.SYNOPSIS
.DESCRIPTION
.PARAMETER ComputerName
.PARAMETER SnapshotNAme
.EXAMPLE
.EXAMPLE
#>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("Name")]
        [String[]]$VmName,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$false)]
        [ValidateNotNullOrEmpty()]
        #[Alias("SnpName")]
        [String]$SnapshotName
    )

    BEGIN
    {
        #Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Restart VM"
        $startDate = Get-Date
    }

    PROCESS
    {
        $VmName.ForEach({
            try {
                $VM = Get-XenVM -Name $_
            }
            catch {
                Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error when getting details about VM: $($_)"
            }        
        
            try {
                if($VM){
                    Remove-XenVM -Name "$_-$SnapshotName" -Verbose        
                }
                else {
                    Write-Warning "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - VM: $($_) does NOT exist"
                }
            }
            catch {
                Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error when removing snapshot: $($_-$SnapshotName)"
            }
        })
    }

    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}
#endregion
