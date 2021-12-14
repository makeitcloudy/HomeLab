#Start-Process 'https://nikiink.wordpress.com/2016/10/22/xenserver-7-0-api-powershell-backup-running-vms/' #backup VM
#Start-Process 'https://www.citrix.com/blogs/2014/03/11/citrix-xenserver-setting-more-than-one-vcpu-per-vm-to-improve-application-performance-and-server-consolidation-e-g-for-cad3-d-graphical-applications/'
#Start-Process 'https://github.com/santiagocardenas/xenserver-powershell-scripts/blob/master/Set-XenServerVMResources.ps1'

Import-Module XenServerPSModule
Get-Command -Module XenServerPSModule

. .\functions.ps1

Connect-PLXen -XenHost "[IP address of your Xen node/pool master]" -Verbose

#region Xen inventory
Get-PLXenSR
Get-PLXenTemplate -Type default -Verbose
Get-PLXenTemplate -Type custom -Verbose
Get-PLXenRam -Type Total -Verbose
Get-PLXenRam -Type Free -Verbose
Get-PLXenStorage -Verbose
Get-PLXenStorage | Where-Object {$_.SRNameLabel -match "ssd|hdd"}

Get-PLXenCPUCount
Get-PLXenISORepository
Get-PLXenISOLibrary -Verbose

Get-PLXenISOLibrary
Get-PLXenISOLibrary | Where-Object {$_.SRIsoOtherConfig.Keys -notmatch "dirty"} #pokaz te ktore trzeba naprawic (repair z gui)
Get-PLXenISOLibrary | Where-Object {$_.SRIsoOtherconfig.Values -match "true"} #pokaz te ktore sa dostepne, sa osiagalne z sieci
#($(Get-PLXenISOLibrary).SRIsoOtherconfig).Keys

#$srName = @{
#    SRName = "nas","centos8nfsIso"
#}
#
#Get-PLXenIso @srName -Verbose

Get-PLXenIso -SRName 'nas' -Verbose
Get-PLXenIso -SRName 'centos8nfsIso' -Verbose
Get-PLXenIso -SRName 'centos8nfsIso','nas' -Verbose
Get-PLXenIso -SRName 'centos8nfsIso','nas' | Out-GridView

Get-PLXenNetwork -Verbose | Sort-Object NetworkBridge
#endregion

$x = Get-XenSession
$x.Url

#region Xen Automation
#show existing Storage Repositories
Get-PLXenSR 
#list all available ISO's among the available ISO repositories
#Get-PLXenISOLibrary | Where-Object {$_.SRIsoOtherconfig.Values -match "true"} | Select-Object SRIsoNameLabel | Get-PLXenIso -Verbose | Select-Object IsoLabel 
Get-PLXenISOLibrary | Where-Object {$_.SRIsoOtherconfig.Values -match "true"} #list available ISO Libraries
Get-PLXenISOLibrary | Where-Object {$_.SRIsoOtherconfig.Values -match "true"} | Select-Object SRIsoNameLabel | Get-PLXenIso -Verbose | Out-GridView #for the available ISO Libraries list all iso files which are available for your disposal
Get-PLXenTemplate -Type default -Verbose #list Available templates which can be used for VM provisioning
#endregion

#region Xen Automation - initialization of objects and hastables which are for the VM creation process
$VmParam = @{
    VMName                  = 'test'       #VM Skel
    VMRAM                   = 2*1GB        #VM Skel
    VMCPU                   = 4            #VM Skel
    HVMBootPolicy           = "BIOS order" #VM Skel
    HVMShadowMultiplier     = 1            #VM Skel
    UserVersion             = 1            #VM Skel
    ActionsAfterReboot      = "restart"    #VM Skel
    ActionsAfterCrash       = "restart"    #VM Skel
    HardwarePlatformVersion = 2            #VM Skel
    NetworkName             = @("Pool-wide eth0","Pool-wide eth1") #VM Network operations
}

$newVMParamHash = @{
    NameLabel        = $VmParam.VMName
    MemoryTarget     = $VmParam.VMRAM
    MemoryStaticMax  = $VmParam.VMRAM
    MemoryDynamicMax = $VmParam.VMRAM
    MemoryDynamicMin = $VmParam.VMRAM
    MemoryStaticMin  = $VmParam.VMRAM
    VCPUsMax         = $VmParam.VMCPU
    VCPUsAtStartup   = $VmParam.VMCPU
    HVMBootPolicy    = $VmParam.HVMBootPolicy
    HVMBootParams    = @{ order = "dc"; firmware = "uefi" }
    HVMShadowMultiplier = $VmParam.HVMShadowMultiplier
    UserVersion = $VmParam.UserVersion
    ActionsAfterReboot = $VmParam.ActionsAfterReboot
    ActionsAfterCrash = $vmParam.ActionsAfterCrash
    ReferenceLabel   = ($vmSourceTemplateObject.XenTemplateObject).reference_label
    HardwarePlatformVersion = $VmParam.HardwarePlatformVersion
    Platform         = @{ 'cores-per-socket' = "$($VmParam.VMCPU)"; hpet = "true"; pae = "true"; vga = "std"; nx = "true"; viridian_time_ref_count = "true"; apic = "true"; viridian_reference_tsc = "true"; viridian = "true"; acpi = "1" }
    OtherConfig      = @{ base_template_name = ($vmSourceTemplateObject.XenTemplateObject).reference_label }
}
#endregion

#region Xen Automation - initialization of objects
$xenDefaultTemplate = Get-PLXenTemplate -Type default -Verbose #get all default templates comming with the hypervisor
#create an object which contains all default templates, and their regex, actually this is the same value pre and suffixed with (\ and \)
 
$i = 0
$xenDefaultTemplateObject= foreach($element in $xenDefaultTemplate){
    [PSCustomObject] @{
        "XenTemplateId" = $i++
        "XenTemplateName" = $element
        "XenTemplateRegex" = ($element.Replace("(","\(")).Replace(")","\)")
        "XenTemplateObject" = Get-XenVM -Name $element
    }
}

# Id XenTemplateName                               XenTemplateRegex                                XenTemplateObject
# -- ---------------                               ----------------                                -----------------
#  0 CentOS 7                                      CentOS 7                                        XenAPI.VM
#  1 CentOS 8                                      CentOS 8                                        XenAPI.VM
#  2 CoreOS                                        CoreOS                                          XenAPI.VM
#  3 Debian Buster 10                              Debian Buster 10                                XenAPI.VM
#  4 Debian Jessie 8.0                             Debian Jessie 8.0                               XenAPI.VM
#  5 Debian Stretch 9.0                            Debian Stretch 9.0                              XenAPI.VM
#  6 NeoKylin Linux Server 7                       NeoKylin Linux Server 7                         XenAPI.VM
#  7 Oracle Linux 7                                Oracle Linux 7                                  XenAPI.VM
#  8 Oracle Linux 8                                Oracle Linux 8                                  XenAPI.VM
#  9 Other install media                           Other install media                             XenAPI.VM
# 10 Red Hat Enterprise Linux 7                    Red Hat Enterprise Linux 7                      XenAPI.VM
# 11 Red Hat Enterprise Linux 8                    Red Hat Enterprise Linux 8                      XenAPI.VM
# 12 Scientific Linux 7                            Scientific Linux 7                              XenAPI.VM
# 13 SUSE Linux Enterprise 15 (64-bit)             SUSE Linux Enterprise 15 \(64-bit\)             XenAPI.VM
# 14 SUSE Linux Enterprise Desktop 12 SP3 (64-bit) SUSE Linux Enterprise Desktop 12 SP3 \(64-bit\) XenAPI.VM
# 15 SUSE Linux Enterprise Desktop 12 SP4 (64-bit) SUSE Linux Enterprise Desktop 12 SP4 \(64-bit\) XenAPI.VM
# 16 SUSE Linux Enterprise Server 12 SP3 (64-bit)  SUSE Linux Enterprise Server 12 SP3 \(64-bit\)  XenAPI.VM
# 17 SUSE Linux Enterprise Server 12 SP4 (64-bit)  SUSE Linux Enterprise Server 12 SP4 \(64-bit\)  XenAPI.VM
# 18 SUSE Linux Enterprise Server 12 SP5 (64-bit)  SUSE Linux Enterprise Server 12 SP5 \(64-bit\)  XenAPI.VM
# 19 Ubuntu Bionic Beaver 18.04                    Ubuntu Bionic Beaver 18.04                      XenAPI.VM
# 20 Ubuntu Focal Fossa 20.04                      Ubuntu Focal Fossa 20.04                        XenAPI.VM
# 21 Ubuntu Xenial Xerus 16.04                     Ubuntu Xenial Xerus 16.04                       XenAPI.VM
# 22 Windows 10 (32-bit)                           Windows 10 \(32-bit\)                           XenAPI.VM
# 23 Windows 10 (64-bit)                           Windows 10 \(64-bit\)                           XenAPI.VM
# 24 Windows 8.1 (32-bit)                          Windows 8.1 \(32-bit\)                          XenAPI.VM
# 25 Windows 8.1 (64-bit)                          Windows 8.1 \(64-bit\)                          XenAPI.VM
# 26 Windows Server 2012 (64-bit)                  Windows Server 2012 \(64-bit\)                  XenAPI.VM
# 27 Windows Server 2012 R2 (64-bit)               Windows Server 2012 R2 \(64-bit\)               XenAPI.VM
# 28 Windows Server 2016 (64-bit)                  Windows Server 2016 \(64-bit\)                  XenAPI.VM
# 29 Windows Server 2019 (64-bit)                  Windows Server 2019 \(64-bit\)                  XenAPI.VM

# to see above execute $xenDefaultTemplateObject

#if [23] is your choice then the template equals Windows 10 (64-bit)
#if [20] is your choice then the template equals Ubuntu Focal Fossa 20.04
$vmSourceTemplateObject = $xenDefaultTemplateObject | Where-Object {$_.XenTemplateName -match $xenDefaultTemplateObject.XenTemplateRegex[23]}
$vmSourceTemplateObject.XenTemplateObject
#endregion 

#region Xen Automation - initialization of objects used to create disks and CD/DVD's
$VMname = $VmParam.VMName
#$DiskName = "testDisk"
$VMDiskName = "{0}-{1}" -f $VmParam.VMName, "OsStorage"
$VMDiskDescription = "{0}-{1}" -f $VMName, $vmSourceTemplateObject.XenTemplateName
$VMDiskGB = 32

#Get-PLXenSR #list available Storage Repositories
$VMSRLocation = "node0_hdd" #StorageRepositoryName
#Get-PLXenIso
#Get-PLXenISOLibrary | Where-Object {$_.SRIsoOtherconfig.Values -match "true"} | Select-Object SRIsoNameLabel | Get-PLXenIso -Verbose | Select-Object IsoLabel #listuje wszystkie dostepne ISO w ramach dostepnych ISO repositories
$VMBootISOName  = 'w10entN_19H2_unattended_updated202111.iso'# 'xs82Tools.iso'

$VMDiskBytes = $VMDiskGB*1073741824
$VM = Get-XenVM -Name $VmParam.VMName
$SR = Get-XenSR -Name $VMSRLocation
#endregion

#region Xen Automation - Creating the VM Skeleton
New-XenVM @newVMParamHash -Verbose
Get-XenVM -Name $VmParam.VMName
#endregion

#region Xen Automation - Create and add Disk, add CD to the VM object
New-XenVDI -NameLabel $VMDiskName -VirtualSize $VMDiskBytes -SR $SR -Type user -NameDescription $VMDiskDescription -Verbose #tworzenie dysku
$VDI = Get-XenVDI -Name $VMDiskName
#New-XenVBD -VM $VM.opaque_ref -VDI $VDI.opaque_ref -Type Disk -mode RW -Userdevice 2 #add disk to the VM
#There is no logic included here which perform any sort of prechecks whether there are two VM's with the same name which is feasible on Xen as those differentiate between each by UUID
#If there are two VMs with the same name of hypervisor level, then below code does work properly
New-XenVBD -VM $VM.opaque_ref -VDI $VDI.opaque_ref -Type Disk -mode RW -Userdevice 0 #add disk to the VM 
New-XenVBD -VM $VM.opaque_ref -VDI $VDI.opaque_ref -Type CD -mode RO -Userdevice 3 -Bootable $false -Unpluggable $true -Empty $true  #add CD/DVD to the VM, 3 na wypadek gdyby chciec dodac jeszcze ze dwa dyski
#endregion

#region Xen Automation - Mount the iso file into the DVD bay
#Get-XenVDI -Name "xs82Tools.iso" | Invoke-XenVBD -Uuid (Get-XenVBD)[2].uuid -XenAction Insert
#Get-XenVM -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object {$_.type -eq "CD"} | Invoke-XenVBD -XenAction Insert -VDI (Get-XenVDI -Name $VMBootISOName | Select-Object -ExpandProperty opaque_ref)#this won't work if there is more than one iso with the same name
#Get-XenVM -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object {$_.type -eq "CD"} | Invoke-XenVBD -XenAction Insert -VDI (Get-XenVDI -Name $VMBootISOName | Select-Object -ExpandProperty opaque_ref)
Get-XenVM -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object {$_.type -eq "CD"} | Invoke-XenVBD -XenAction Insert -VDI (Get-XenVDI -Uuid (Get-PLXenIso -SRName "centos8NfsIso" | Where-Object {$_.IsoLabel -match $VMBootISOName}).IsoUUID | Select-Object -ExpandProperty opaque_ref) #mount iso
#(Get-PLXenIso -SRName "centos8NfsIso" | Where-Object {$_.IsoLabel -match $VMBootISOName}).IsoUUID
#Get-XenVDI -Uuid (Get-PLXenIso -SRName "centos8NfsIso" | Where-Object {$_.IsoLabel -match $VMBootISOName}).IsoUUID | Select-Object -ExpandProperty opaque_ref
#endregion

#region Xen Automation - Create Network objects
#list available networks on the hypervisor
Get-PLXenNetwork -Verbose | Sort-Object NetworkBridge | Select-Object NetworkLabel, NetworkDescription
#$VM = Get-XenVM -Name $VMName
#this piece of code comes from https://github.com/santiagocardenas/xenserver-powershell-scripts/blob/master/Set-XenServerVMResources.ps1
#Blog Post: Add networks to VMs while making sure to skip duplicates and keep a device count
$existingNetworks = (($VM.VIFs | Get-XenVIF).network | Get-XenNetwork -ErrorAction SilentlyContinue).name_label
$existingDevices = @(($VM.VIFs | Get-XenVIF).device)
if ($existingDevices[0] -eq $null) { $existingDevices = @() }
foreach ($networkName in $VmParam.NetworkName) {
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
#endregion

#region Xen Automation - Launch VM
Invoke-XenVM -Name $VmParam.VMName -XenAction Start
#endregion

#region Xen Automation - Modify VM parameters
Set-Location -path "$Env:USERPROFILE\Documents\howtoLab\xenServerAutomation\"
$VMparamModify = @{
    VMNames = '[VMName]'
    CPUs = 4
    MemoryGB = 2
    XenServerHost = '[IP address of your XCPng host/pool master]'
    UserName = '[XCPng user]'
    Password = '[XCPng password]'
    NetworkNames = 'Pool-wide eth0'
    TryDelay = 5
    Tries = 5
}
.\Set-XenServerVMResources.ps1 @VMparamModify -Verbose

#.\Set-XenServerVMResources.ps1 -VMNames $VMname `
#                               -CPUs $VMparamModify.CPUs `
#                               -MemoryGB $VMparamModify.MemoryGB `
#                               -XenServerHost $VMparamModify.XenServerHost `
#                               -UserName $VMparamModify.UserName `
#                               -Password $VMparamModify.Password `
#                               -NetworkNames $VMparamModify.NetworkNames `
#                               -TryDelay $VMparamModify.TryDelay `
#                               -Tries $VMparamModify.Tries `
#                               -Verbose
#endregion

#region Xen Automation - REMOVE disks / DVD wihch are no longer needed
#in case you end up with two DVD bound to the VM, this is the way those can be removed
$VM = Get-XenVM -Name $VmParam.VMName
$VM.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object {$_.type -notmatch "CD"} } #show drives which are not CD
$VM.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object {$_.type -match "CD"} } #show drives which are CD's
#Get-XenVBD -Uuid ($VM.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object {$_.type -notlike "CD"} }).uuid
$VM.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object {$_.type -notmatch "CD"} } | ForEach-Object {Get-XenVDI -Ref $_.VDI | Remove-XenVDI -Confirm:$true } #test this
#$VM | Remove-XenVM #remove VM
#endregion

#region Xen Automation - REMOVE objects composing VM along with the VM Skel
$VM = Get-XenVM -Name $VmParam.VMName
#region Xen Automation - EJECT iso from the DVD bay
Get-XenVm -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object {$_.type -eq "CD"} | Invoke-XenVBD -XenAction Eject #eject ISO
#endregion

#region Xen Automation - REMOVE network interfaces bound with VM
$VM.VIFs | ForEach-Object {Get-XenVIF $_.opaque_ref | Remove-XenVIF -Confirm:$true} #Remove network interfaces from VM
#endregion

#region Xen Automation - DETACH disks and DVD from VM
$VM.VBDs | ForEach-Object {Get-XenVBD $_.opaque_ref | Where-Object {$_.type -match "CD"} | Remove-XenVBD -Confirm:$true} #detach DVD from VM
$VM.VBDs | ForEach-Object {Get-XenVBD $_.opaque_ref | Where-Object {$_.type -match "disk" -and $_.mode -match "RW"} | Remove-XenVBD -Confirm:$true} #detach disk from VM
#$VM.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object {$_.type -notmatch "CD"} } | ForEach-Object {Get-XenVDI -Ref $_.VDI | Remove-XenVDI -Confirm:$true} #detach disk from VM
#endregion

#region Xen Automation - REMOVE virtual disks combined with the VM
Get-XenVDI | Where-Object { $_.SR.opaque_ref -like $sr.opaque_ref} | Where-Object {$_.name_label -match $VmParam.VMName} | Remove-XenVDI -Confirm:$true
#endregion

#region Xen Atuomation - REMOVE VM skel - at this stage it should have any objects combined with it
$VM | Remove-XenVM #usun VMke
Get-XenVM -Name $VmParam.VMName | Remove-XenVM -Confirm:$true #remove VM, it looks like it does not confirm the action, on the prompt you'll get the UUID of VM not it's name, don't be surprised
#endregion
#endregion


Disconnect-PLXen -Verbose
#Disconnect-XenServer
