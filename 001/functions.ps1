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
    Param (
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $ConnectionBroker
    )

    Begin {
        $WarningPreference = "Continue"
        $VerbosePreference = "Continue"
        $InformationPreference = "Continue"
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Example"
        $startDate = Get-Date
    }

    Process {
        try {

        }
        catch {

        }
    }

    End {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Set-PLCred {
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
    Param (
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$userName,
        
        [Parameter(Mandatory = $true,Position = 1,ValueFromPipelineByPropertyName=$false)]
        [ValidateNotNullOrEmpty()]
        [String]$password
    )

    Begin {
        $WarningPreference = "Continue"
        $VerbosePreference = "Continue"
        $InformationPreference = "Continue"
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Example"
        $startDate = Get-Date
    }

    Process {
        try {
            $passwordSecureString = ConvertTo-SecureString $password -AsPlainText -Force
            Remove-Variable -Name password
            $cred = New-Object System.Management.Automation.PSCredential ($userName, $passwordSecureString)
            Remove-Variable -Name userName
        }
        catch {

        }
        return $cred
    }

    End {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Connect-PLXen {
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
    Param (
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$XenHost,
        
        #[Parameter(Mandatory = $true,Position = 1,ValueFromPipelineByPropertyName=$false)]
        #[ValidateNotNull()]
        #[System.Management.Automation.PSCredential]
        #[System.Management.Automation.Credential()]
        #$Credential = [System.Management.Automation.PSCredential]::Empty
        
        [Parameter(Mandatory = $true,Position = 1,ValueFromPipelineByPropertyName=$false)]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]$Credential = [System.Management.Automation.PSCredential]::Empty
        
    )


    Begin {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Initiating the connection to the Hypervisor."
        $startDate = Get-Date
    }

    Process {
        Try {
            Write-Warning "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Setting connection to Xen withouth warning about certificates."
            $Global:Session = Connect-XenServer -Url "https://$($XenHost)" -Creds $Credential -NoWarnCertificates -SetDefaultSession
        } 
  
        Catch [XenAPI.Failure] {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error in setting connection to Xen."
            #[System.Windows.MessageBox]::Show("$($_.Exception), try connecting to $($_.Exception.ErrorDescription[1])")

        }
    }

    End {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Disconnect-PLXen {
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

    Begin {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Terminating the connection to the Hypervisor."
        $startDate = Get-Date
    }

    Process {
        try {
            if($Global:Session) {
                try {
                    #Write-Information "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Section if."
                    Write-Warning "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Disconnecting from the exsiting session."
                    #$Global:Session | Disconnect-XenServer
                    Disconnect-XenServer
                }
                catch {
                    Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error 1 in disconnecting from Xen."
                }
            }
            else {
            try {
                #Write-Information "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Section else."
                Write-Warning "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Disconnecting from the exsiting session."
                Disconnect-XenServer
            }
            catch {
                Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error 2 in disconnecting from Xen."
            }
            
            }
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error in disconnecting from Xen."
        }
    }

    End {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

#do owrapowania
Function Get-PLXenSR {
#dodac informacje o zajetosci, ile miejsca calkowitego, ile wolnego i niech zwraca to jako obiekt
#wynik na wzor Get-PLXenStorage - tyle ze cztery wartosci ma zwracac
    $storageNameLabels = (Get-XenSR -ErrorAction SilentlyContinue | Sort -Property name_label | select type,name_label | Where-Object {($_.type -ne "iso") -and ($_.name_label -ne "Removable storage") -and ($_.name_label -ne "DVD drives") -and ($_.name_label -ne "XenServer Tools") -and ($_.type -ne "iso")}).name_label

    #foreach($StorageLabel in $StorageNameLabels) {
    #    #Write-Output $StorageLabel
    #    #$DropDownStorage.Items.Add($StorageLabel) | Out-Null
    #}
    return $storageNameLabels

}

#przepisac zeby zwracalo obiekt
Function Get-PLXenTemplate {
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
    Param (
        [Parameter(Mandatory = $false,Position = 0,ValueFromPipelineByPropertyName=$false)]
        [ValidateSet("default","custom")]
        $Type
    )

    Begin {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Getting details about templates."
        $startDate = Get-Date
    }

    Process {
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
                    Write-Warning "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Parameter Type not defined."
                }
            }
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error during getting information about Templates."
        }
    }

    End {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

#nie zwraca obiektu ale ok
Function Get-PLXenRam {
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
    Param (
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName=$false)]
        [ValidateSet("Free","Total")]
        [String] $Type
    )

    Begin {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Getting Details about memory."
        $startDate = Get-Date
    }

    Process {
        try {
            switch($Type){
                "Free" {
                    try {
                        $ramAmount = (Get-XenHostMetrics -ErrorAction SilentlyContinue).memory_free | ForEach-Object {("{0:N0}" -f ($_ / 1GB)-1)} | Sort-Object | Select-Object -First 1
                        return $ramAmount
                    }
                    catch {

                    }
                
                }
                "Total" {
                    try {
                        $ramAmount = (Get-XenHostMetrics -ErrorAction SilentlyContinue).memory_total | ForEach-Object {("{0:N0}" -f ($_ / 1GB)-1)} | Sort-Object | Select-Object -First 1
                        return $ramAmount
                    }
                    catch {

                    }
                }
                default {
                    Write-Warning "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Parameter Type not defined."
                }
            }
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error with getting details about memory."
        }
    }

    End {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Get-PLXenStorage {
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
    Param (
        #[Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName=$true)]
        #[ValidateNotNullOrEmpty()]
        #$SRName
    )

    Begin {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Getting details about storage."
        $startDate = Get-Date
    }

    Process {
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
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error with getting details about storage."
        }
    }

    End {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

#do owrapowania
Function Get-PLXenCpuCount {

#$BaseCPUCount = 1
$MaxCPUCount = ((Get-XenHostCpu -ErrorAction SilentlyContinue).number | Sort-Object -Descending | Select-Object -Unique -First 1)+1

    #if($DropDownCPUCount.Items) {
    #
    #$DropDownCPUCount.Items.Clear()
    #
    #}

    #while($BaseCPUCount -le $MaxCPUCount) {
    #
    ##$DropDownCPUCount.Items.Add($BaseCPUCount)
    #$BaseCPUCount++
    #
    #}
    return $MaxCPUCount
}

#do owrapowania
Function Get-PLXenIsoRepository {
    #zdaje sie ze mozna spradzac other_config czy jest dirty wtedy oznaczac to moze ze jest niedostepne
    $xenToolsRegex = "XCP-ng Tools|XenServer Tools"
    $ISORepository = (Get-XenSR | Where-Object {$_.type -eq "iso" -and $_.name_label -notmatch $xenToolsRegex}).name_label
    return $ISORepository
}

Function Get-PLXenIsoLibrary {
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

    Begin {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Getting details about ISO library."
        $startDate = Get-Date
        $xenToolsRegex = "XCP-ng Tools|XenServer Tools"
    }

    Process {
        try {
            #$isoPath = [regex]::Matches($((Get-XenSR | Where-Object {$_.type -eq "iso" -and $_.name_label -notmatch $xenToolsRegex}).name_description), '(?<=\[).+?(?=\])').Value
            $SRIsoDetails = @()
            $SRIso = (Get-XenSR | Where-Object {$_.type -eq "iso" -and $_.name_label -notmatch $xenToolsRegex})
            $SRIso.ForEach({
                $PBD = Get-XenPBD ($_.PBDs).opaque_ref
                $obj = [PSCustomObject]@{
                    SRIsoUUID = $_.uuid
                    SRIsoNameLabel = $_.name_label
                    SRIsoNameDescription = $_.name_description
                    SRIsoVirtualAllocation = $_.virtual_allocation
                    SRIsoPhysicalUtilization = $_.physical_utilization
                    SRIsoPhysicalSize = $_.physical_size
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
            #$isoPath = [regex]::Matches($((Get-XenSR | Where-Object {$_.type -eq "iso" -and $_.name_label -notmatch $xenToolsRegex}).name_description), '(?<=\[).+?(?=\])').Value

            #$xenToolsRegex = "XCP-ng Tools|XenServer Tools"
            #$ISORepository = (Get-XenSR | where {$_.type -eq "iso" -and $_.name_label -notmatch "XCP-ng Tools | XenServer Tools"}).name_label
            #$ISOPath = (Get-XenSR | Where-Object {$_.type -eq "iso" -and $_.name_label -notmatch "XCP-ng Tools|XenServer Tools"}).name_description

            #$testText = "NFS ISO Library [10.0.5.10:/labdata/nfs_share/labIso]"
            #$pattern = '(?<=\[).+?(?=\])'
            #[regex]::Matches($ISOPath, $pattern).Value
            
            #$SRIso.ForEach({
            #    Get-XenPBD ($SRIso[0].PBDs).opaque_ref
            #})
            #Get-XenPBD ($SRIso[0].PBDs).opaque_ref
        
        return $SRIsoDetails
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error with getting details about ISO library."
        }
    }

    End {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Get-PLXenIso {
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
    Param (
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias("SRIsoNameLabel")]
        [String[]]$SRName
    )

    Begin {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Getting details about ISOs."
        $startDate = Get-Date
    }

    Process {
        try {
        #$allIso = (Get-XenSR -Name $_ | Select-Object -ExpandProperty VDIs | Get-XenVDI | Where-Object {$_.name_label -match ".iso"})
         $all = $SRName.ForEach({Get-XenSR -Name $_ | Select-Object -ExpandProperty VDIs})
         $allIso = $all | Get-XenVDI | Where-Object {$_.name_label -match ".iso"}
            $isoDetails = @()
            $allIso.ForEach({
                $SR = (Get-XenSR $_.SR)
                #(Get-XenSR $_.SR).name_label
                #(Get-XenSR $_.SR).name_description
                #Get-XenSR $_.SR
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
            #$SRName = 'px2-300d'
            #$AllISOs = (Get-XenSR -Name $SRName | Select-Object -ExpandProperty VDIs | Get-XenVDI | Where-Object {$_.name_label -match ".iso"}).name_label | Sort-Object
            #$AllIso = (Get-XenSR -Name $SRName | Select-Object -ExpandProperty VDIs | Get-XenVDI | Where-Object {$_.name_label -match ".iso"}).name_label | Sort-Object
            #$isoDestails = @()
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error with getting details about ISOs."
        }
        #$AllISOs.foreach({
        #    Write-Output $_
        #})
        return $isoDetails
    }

    End {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

Function Get-PLXenNetwork {
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

    Begin {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Getting details about Network."
        $startDate = Get-Date
        #if(Get-XenSession){
        #    Write-Output $true
        #}
        #else{Write-Output $false}
    }

    Process {
        try {
        
        #$AllNetworks = (Get-XenNetwork -ErrorAction SilentlyContinue).name_label | Sort-Object
        $AllNetworks = Get-XenNetwork
        #(Get-XenNetwork -ErrorAction SilentlyContinue).name_description | Sort-Object
        
            $NetworkDetails = @()
            $AllNetworks.foreach({
                $obj = [PSCustomObject]@{
                    NetworkUUID = $_.uuid
                    NetworkLabel = $_.name_label
                    NetworkDescription = $_.name_description
                    NetworkBridge = $_.bridge
                    NetworkMTU = $_.MTU
                }
            $networkDetails += $obj
            })        
        
        return $NetworkDetails
        }
        catch {
            Write-Error "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Error with getting details about Network."
        }
    }

    End {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}
