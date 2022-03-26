#Requires -RunAsAdministrator
# TEN KOD JEST PISANY NA LAPTOK - tutaj tez testowany
Get-ChildItem $env:USERPROFILE\Downloads\* -Include *.jnlp | Remove-Item -Verbose

#region Xen Automation - 2022 - INITIALIZE
#region Xen Automation - 2022 - INITIALIZE - Variables Modules, DSC, functions, passwords
#region Xen Automation - 2022 - INITIALIZE - Variables to process DSC configs, load Modules to build the DSC Configuration
#install the XenServerPSModule first
#copy the XenServerPSModule into this location 
# C:\Users\piotrek\Documents\WindowsPowerShell\Modules
# C:\Windows\System32\WindowsPowerShell\v1.0\ #when it is in abovementioned location it is not needed to copy it here unless you'd like to make it available for all users

$powerShellModulePath                  = "$env:PROGRAMFILES\WindowsPowerShell\Modules"
$resourcesPath                         = "$env:SystemDrive\LabResources"

$hostFileEtcPath                       = "$env:SystemRoot\System32\drivers\etc"
$hostFileName                          = 'hosts'
$hostFilePath                          = Join-Path -Path $hostFileEtcPath -ChildPath $hostFileName

$certsFolderName                       = "certs"
$certsSelfSignedFolderName             = "selfSigned"
$certsPkiFolderName                    = "pki"
$certsPath                             = Join-Path -Path $resourcesPath -ChildPath $certsFolderName
$certsSelfSignedPath                   = Join-Path -Path $certsPath -ChildPath $certsSelfSignedFolderName
$certsPkiPath                          = Join-Path -Path $certsPath -ChildPath $certsPkiFolderName

$scriptsFolderName                     = "scripts"
$functionsFileName                     = "_functions.ps1"
$scriptsPath                           = Join-Path -Path $resourcesPath -ChildPath $scriptsFolderName
$functionFilePath                      = Join-Path -Path $scriptsPath -ChildPath $functionsFileName

$helperFunctionsFolderName             = 'helperFunctions'
$helperFunctionsSelfSignedCertFileName = "New-SelfSignedCertificateEx.ps1"
$helperFunctionsPath                   = Join-Path -Path $resourcesPath -ChildPath $helperFunctionsFolderName
$helperFunctionsSelfSignedScriptPath   = Join-Path -Path $helperFunctionsPath -ChildPath $helperFunctionsSelfSignedCertFileName

$resourcesIsoPath                      = "$env:SystemDrive\LabResourcesIso"
$resourcesIsoOrgFolderName             = "org"
$resourcesIsoUpdatedFolderName         = "updated"
$resourcesIsoOrgPath                   = Join-Path -Path $resourcesIsoPath -ChildPath $resourcesIsoOrgFolderName
$resourcesIsoUpdatedPath               = Join-Path -Path $resourcesIsoPath -ChildPath $resourcesIsoUpdatedFolderName

$domainName                            = 'home.lab'
$authoringBoxUserName                  = 'labUser'
$administratorUserName                 = 'administrator'
$laptokUserName                        = 'piotrek'

#$nodeName                             = "authoring"
#$dscInitialConfigurationFile          = "$($nodeName)_InitialConfigurationDsc.ps1"
#region laptok - Xen Automation - 2022 - DSC variables

$dscLcmFolderName                      = 'lcm'
$dscConfigurationFolderName            = 'dscConfiguration'
$dscZippedModuleFolderName             = 'dscZippedModule'
$dscConfigurationCompiledFolderName    = 'dscConfigurationCompiled'

$dscInitialConfigurationFile           = "nodeName_InitialConfigurationDsc.ps1"
$dscInitialLaptokConfigurationFile     = "laptok_InitialConfigurationDsc.ps1"
$dscConfigurationLcmFile               = "configurationLcm.ps1"

$dscConfigurationPath                  = Join-Path -Path $resourcesPath -ChildPath $dscConfigurationFolderName
$dscZippedModulePath                   = Join-Path -Path $resourcesPath -ChildPath $dscZippedModuleFolderName
$dscZippedAllModulePath                = Join-Path -Path $dscZippedModulePath -ChildPath "*"
$dscConfigurationLcmPath               = Join-Path -Path $dscConfigurationPath -ChildPath $dscLcmFolderName
$dscConfigurationCompiledPath          = Join-Path -Path $resourcesPath -ChildPath $dscConfigurationCompiledFolderName
$dscConfigurationCompiledLcmPath       = Join-Path -Path $dscConfigurationCompiledPath -ChildPath $dscLcmFolderName
$dscInitialConfigurationFilePath       = Join-Path -Path $dscConfigurationPath -ChildPath $dscInitialConfigurationFile
$dscInitialLaptokConfigurationFilePath = Join-Path -Path $dscConfigurationPath -ChildPath $dscInitialLaptokConfigurationFile
$dscConfigurationLcmFilePath           = Join-Path -Path $dscConfigurationLcmPath -ChildPath $dscConfigurationLcmFile

$dscModule = @{
    ComputerManagementDsc              = "8.5.0";
    NetworkingDsc                      = "8.2.0.0";
    #xActiveDirectory                  = "2.16.0.0";
    #xDhcpServer                       = "1.7.0.0"
    #xDnsServer                        = "1.8.0.0"
    #xPSDesiredStateConfiguration      = "7.0.0.0"
    #xComputerManagement               = "2.1.0.0";
    #xNetworking                       = "5.1.0.0";
    #xAdcsDeployment                   = "1.2.0.0";
    #xSQLServer                        = "8.2.0.0";
    #xFailoverCluster                  = "1.8.0.0";
    #xSystemSecurity                   = "1.2.0.0"; #IE Enhanced Security, UAC
    #cNtfsAccessControl                = "1.3.0"
}
#endregion

#region laptok - Xen automation - 2022 - DSC variables for self signed Certificates
$selfSignedCertDscConfigurationEncryptionParam = @{
    NotAfter                           = $([datetime]::now.AddYears(1))
    KeyUsage                           = "KeyEncipherment, DataEncipherment"
    EnhancedKeyUsage                   = "1.3.6.1.4.1.311.80.1"
    SignatureAlgorithm                 = "SHA256"
    FriendlyName                       = "DSC mof password encryption"
    StoreLocation                      = "LocalMachine"
}
$selfSignedCertThumbprint = @{}
#endregion

#region laptok - Xen automation - 2022 - Xen variables, SMB variables
#nodeIP                                = "10.0.4.250" #node0
#$nodeIsoSR                            = 'centos8nfsIso' #node0
$xenServerToolsIso                     = 'Citrix_Hypervisor_82_tools.iso'
$nodeIsoSR                             = 'centos8Stream_nfs' #node1
$sshPortNumber                         = 22
$nodeHypervisorUserName                = 'root'
$nodeIp                                = '10.0.5.1' #node1
$nodeFqdn                              = 'node1.lab'
$nodeIpIpmi                            = '10.0.4.241'
$nodeIpmiFqdn                          = "node1ipmi.lab"
$smbLocalPath                          = "L:"
$smbRemotePath                         = "\\192.168.39.240\_labEmc"
$puttySshSessionName                   = 'node1_xcpng'
#endregion

#endregion

#region Xen Automation - 2022 - INITIALIZE - Load XenServerPSModule and dot source the functions unless there is a module written to fit the purpose
Import-Module XenServerPSModule
Set-Location -Path $env:USERPROFILE
. $functionFilePath
#endregion

#region Xen Automation - 2022 - INITIALIZE - Passwords credentials
$laptokCred = Get-Credential -UserName $laptokUserName -Message 'password for the piotrek account on laptok'
$xenCred = Get-Credential -UserName $nodeHypervisorUserName -Message "password for the $nodeHypervisorUserName on Xen"
$creds2019 = Get-Credential -UserName $administratorUserName -Message 'Local admin password w2k19 - Password1$' #Password1$
$creds2016 = Get-Credential -UserName $administratorUserName -Message 'Local admin password w2k16 - Password1!' #Password1!
$authoringBoxCred = Get-Credential -UserName $authoringBoxUserName -Message 'labuser password for authoringbox - Password1!' #Password1!
#endregion
#endregion

#region Xen Automation - 2022 - INITIALIZE - device NodeName parameters
$vmArray = @()
#VMSKU       = Get-PLXenTemplate -Type default -Verbose
#VMBootISO   = name of the iso file located on the ISO repository
#VMBootISO   = Get-PLXenISOLibrary | Where-Object { $_.SRIsoOtherconfig.Values -match "true" } | Select-Object SRIsoNameLabel | Get-PLXenIso -Verbose | Select-Object IsoLabel,IsoDescription,IsoVirtualSize,IsoPhysicalUtilization,IsoIsToolsIso,SRNameLabel,SRNameDescription,SRUUID | Sort-Object IsoLabel | Out-GridView
#VMBootISO   = Get-PLXenIso -SRName $nodeIsoSR -Verbose | Select-Object IsoLabel | Where {$_.IsoLabel -match 'w2k19'} #node1
#VMSR        = Get-PLXenSR -Verbose
#NetworkName = Get-PLXenNetwork -Verbose | Sort-Object NetworkBridge
#MAC         = #XY:XX:XX:XX:XX:XX - Y=2,6,A,E

#this section is being used to get details for the VMParam used to provision new VM's
#Get-PLXenTemplate -Type default -Verbose #pokaz dostepne templatki z ktorych mozna tworzyc VMki
#Get-PLXenStorage | Select-Object SRNameLabel,SRNameDescription,SrType | Sort-Object SRNameLabel #get details about Xen Storage Repositories
#Get-PLXenIso -SRName $nodeIsoSR -Verbose | Select-Object IsoLabel | Sort-Object IsoLabel #get available ISO which can be used to build VMs
#Get-PLXenNetwork -Verbose | Sort-Object NetworkBridge | Select-Object NetworkLabel, NetworkDescription #get details about availabke Xen networks

#region Xen Automation - 2022 - INITIALIZE device NodeName parameters - nvme - change boot order
$vmParam = @{
    VMName                  = 'bootOrder'           #VM Skel
    VMDescription           = "$domainName - mgmt node"
    VMSKU                   = 'Windows Server 2019' #VM Template
    VMBootISO               = 'w2k19core_1809LTSC_unattended_updated2111.iso'
    #VMIsoSR                 = 'centos8Stream_nfs'  #ISO SR
    VMDiskGB                = 32
    VMSR                    = 'node1_nvme'          #VM disk
    VMRAM                   = 8 * 1GB               #VM Skel
    VMCPU                   = 8                     #VM Skel
    HVMBootPolicy           = "BIOS order"          #VM Skel
    HVMShadowMultiplier     = 1                     #VM Skel
    UserVersion             = 1                     #VM Skel
    ActionsAfterReboot      = "restart"             #VM Skel
    ActionsAfterCrash       = "restart"             #VM Skel
    HardwarePlatformVersion = 2                     #VM Skel
    NetworkName             = @("Pool-wide eth3")   #VM Network operations
    MAC                     = '3a:5b:7c:17:19:97'
    #MTU                     = 1500
    #NetworkName             = @("Pool-wide eth0", "Pool-wide eth1") #VM Network operations
}
$vmObject = [pscustomobject]$vmParam
$vmArray += $vmObject
#endregion

#region Xen Automation - 2022 - INITIALIZE device NodeName parameters - testVM
$vmParam = @{
    VMName                  = 'mgmt'       #VM Skel
    VMDescription           = "$domainName - mgmt node"
    VMSKU                   = 'Windows Server 2016' #VM Template
    VMBootISO               = 'w2k16std_unattended_updated_2111.iso'
    #VMIsoSR                 = 'centos8Stream_nfs'   #ISO SR
    VMDiskGB                = 32
    VMSR                    = 'node1_ssd'           #VM disk
    VMRAM                   = 8 * 1GB      #VM Skel
    VMCPU                   = 8            #VM Skel
    HVMBootPolicy           = "BIOS order" #VM Skel
    HVMShadowMultiplier     = 1            #VM Skel
    UserVersion             = 1            #VM Skel
    ActionsAfterReboot      = "restart"    #VM Skel
    ActionsAfterCrash       = "restart"    #VM Skel
    HardwarePlatformVersion = 2            #VM Skel
    NetworkName             = @("Pool-wide eth1") #VM Network operations
    MAC                     = '3a:5b:7c:17:19:98'
    #MTU                     = 1500
    #NetworkName             = @("Pool-wide eth0", "Pool-wide eth1") #VM Network operations
}
$vmObject = [pscustomobject]$vmParam
$vmArray += $vmObject
#endregion

#region Xen Automation - 2022 - INITIALIZE device NodeName parameters - authoringBox MgmtBox w10
#2022.01.13 authoring box zeby zaktualizowac obrazy w2k16,w2k19, w2k22, w10-19H2 potrzebuje dysku C o rozmiarze minimum 120GB
#2022.01.13 przetestowac czy OSDBuilder zadziala jesli drugi ekstra dysk bedzie zamontowany nie jako D tylko jako katalog na dysku C
#2022.01.13 sprawdzic jak sie zachowa OSDBuilder gdy bedzie zamonotowanych wiecej niz jeden obraz podczas aktualizacji
$vmParam = @{
    VMName                  = '_authoring'            #VM Skel
    VMDescription           = "$domainName - authoring/management box"
    VMSKU                   = 'Windows 10 \(64-bit\)' #VM Template # Get-PLXenTemplate -Type default -Verbose
    VMBootISO               = 'w10entN_19H2_unattended_updated202111.iso'
    #VMIsoSR                 = 'centos8Stream_nfs'    #ISO SR
    VMDiskGB                = 40
    VMSR                    = 'node1_ssd'             #VM disk
    VMRAM                   = 8 * 1GB                 #VM Skel
    VMCPU                   = 4                       #VM Skel
    HVMBootPolicy           = "BIOS order"            #VM Skel
    HVMShadowMultiplier     = 1                       #VM Skel
    UserVersion             = 1                       #VM Skel
    ActionsAfterReboot      = "restart"               #VM Skel
    ActionsAfterCrash       = "restart"               #VM Skel
    HardwarePlatformVersion = 2                       #VM Skel
    NetworkName             = @("Pool-wide eth3")     #VM Network operations
    MAC                     = '3a:5b:7c:17:19:99' #XY:XX:XX:XX:XX:XX - Y=2,6,A,E
    #MTU                     = 1500
    #NetworkName             = @("Pool-wide eth0", "Pool-wide eth1") #VM Network operations
}
$vmObject = [pscustomobject]$vmParam
$vmArray += $vmObject
#endregion

#region Xen Automation - 2022 - INITIALIZE device NodeName parameters - domain controller dc01
$VmParam = @{
    VMName                  = 'dc01'       #VM Skel
    VMDescription           = "$domainName - domain controler 01"
    VMSKU                   = 'Windows Server 2019' #VM Template
    VMBootISO               = 'w2k19core_1809LTSC_unattended_updated2111.iso'
    #VMIsoSR                 = 'centos8Stream_nfs'   #ISO SR
    VMDiskGB                = 32
    VMSR                    = 'node1_hdd'           #VM disk
    VMRAM                   = 2 * 1GB      #VM Skel
    VMCPU                   = 4            #VM Skel
    HVMBootPolicy           = "BIOS order" #VM Skel
    HVMShadowMultiplier     = 1            #VM Skel
    UserVersion             = 1            #VM Skel
    ActionsAfterReboot      = "restart"    #VM Skel
    ActionsAfterCrash       = "restart"    #VM Skel
    HardwarePlatformVersion = 2            #VM Skel
    NetworkName             = @("Pool-wide eth1") #VM Network operations
    MAC                     = '3a:5b:7c:17:19:01' #XY:XX:XX:XX:XX:XX - Y=2,6,A,E
    #MTU                     = 1500
    #NetworkName             = @("Pool-wide eth0", "Pool-wide eth1") #VM Network operations
}
$vmObject = [pscustomobject]$vmParam
$vmArray += $vmObject
#endregion

#region Xen Automation - 2022 - INITIALIZE device NodeName parameters - domain controller dc02
$VmParam = @{
    VMName                  = 'dc02'       #VM Skel
    VMDescription           = "$domainName - domain controler 02"
    VMSKU                   = 'Windows Server 2019' #VM Template
    VMBootISO               = 'w2k19core_1809LTSC_unattended_updated2111.iso'
    #VMIsoSR                 = 'centos8Stream_nfs'   #ISO SR
    VMDiskGB                = 32
    VMSR                    = 'node1_hdd'           #VM disk
    VMRAM                   = 2 * 1GB      #VM Skel
    VMCPU                   = 4            #VM Skel
    HVMBootPolicy           = "BIOS order" #VM Skel
    HVMShadowMultiplier     = 1            #VM Skel
    UserVersion             = 1            #VM Skel
    ActionsAfterReboot      = "restart"    #VM Skel
    ActionsAfterCrash       = "restart"    #VM Skel
    HardwarePlatformVersion = 2            #VM Skel
    NetworkName             = @("Pool-wide eth1") #VM Network operations
    #NetworkName             = @("Pool-wide eth0", "Pool-wide eth1") #VM Network operations
    MAC                     = '3a:5b:7c:17:19:02'
    #MTU                     = 1500
}
$vmObject = [pscustomobject]$vmParam
$vmArray += $vmObject
#endregion

#region Xen Automation - 2022 - INITIALIZE device NodeName parameters - root CA
$VmParam = @{
    VMName                  = 'rootCA'       #VM Skel
    VMDescription           = "$domainName - root CA"
    VMSKU                   = 'Windows Server 2019' #VM Template
    VMBootISO               = 'w2k19std_1809LTSC_unattended_updated2111.iso'
    #VMIsoSR                 = 'centos8Stream_nfs'   #ISO SR
    VMDiskGB                = 32
    VMSR                    = 'node1_ssd'           #VM disk
    VMRAM                   = 4 * 1GB      #VM Skel
    VMCPU                   = 4            #VM Skel
    HVMBootPolicy           = "BIOS order" #VM Skel
    HVMShadowMultiplier     = 1            #VM Skel
    UserVersion             = 1            #VM Skel
    ActionsAfterReboot      = "restart"    #VM Skel
    ActionsAfterCrash       = "restart"    #VM Skel
    HardwarePlatformVersion = 2            #VM Skel
    NetworkName             = @("Pool-wide eth1") #VM Network operations
    #NetworkName             = @("Pool-wide eth0", "Pool-wide eth1") #VM Network operations
    MAC                     = '3a:5b:7c:17:19:03'
    #MTU                     = 1500
}
$vmObject = [pscustomobject]$vmParam
$vmArray += $vmObject
#endregion

#region Xen Automation - 2022 - INITIALIZE device NodeName parameters - sub CA
$VmParam = @{
    VMName                  = 'subCA'       #VM Skel
    VMDescription           = "$domainName - sub CA"
    VMSKU                   = 'Windows Server 2019' #VM Template
    VMBootISO               = 'w2k19std_1809LTSC_unattended_updated2111.iso'
    #VMIsoSR                 = 'centos8Stream_nfs'   #ISO SR
    VMDiskGB                = 32
    VMSR                    = 'node1_ssd'           #VM disk
    VMRAM                   = 4 * 1GB      #VM Skel
    VMCPU                   = 4            #VM Skel
    HVMBootPolicy           = "BIOS order" #VM Skel
    HVMShadowMultiplier     = 1            #VM Skel
    UserVersion             = 1            #VM Skel
    ActionsAfterReboot      = "restart"    #VM Skel
    ActionsAfterCrash       = "restart"    #VM Skel
    HardwarePlatformVersion = 2            #VM Skel
    NetworkName             = @("Pool-wide eth1") #VM Network operations
    #NetworkName             = @("Pool-wide eth0", "Pool-wide eth1") #VM Network operations
    MAC                     = '3a:5b:7c:17:19:04'
    #MTU                     = 1500
}
$vmObject = [pscustomobject]$vmParam
$vmArray += $vmObject
#endregion

#region Xen Automation - 2022 - INITIALIZE device NodeName parameters - file server fs01
$VmParam = @{
    VMName                  = 'fs01'       #VM Skel
    VMDescription           = "$domainName - file server 01"
    VMSKU                   = 'Windows Server 2019' #VM Template
    VMBootISO               = 'w2k19core_1809LTSC_unattended_updated2111.iso'
    #VMIsoSR                 = 'centos8Stream_nfs'   #ISO SR
    VMDiskGB                = 32
    VMSR                    = 'node1_ssd'           #VM disk
    VMRAM                   = 2 * 1GB      #VM Skel
    VMCPU                   = 4            #VM Skel
    HVMBootPolicy           = "BIOS order" #VM Skel
    HVMShadowMultiplier     = 1            #VM Skel
    UserVersion             = 1            #VM Skel
    ActionsAfterReboot      = "restart"    #VM Skel
    ActionsAfterCrash       = "restart"    #VM Skel
    HardwarePlatformVersion = 2            #VM Skel
    NetworkName             = @("Pool-wide eth1") #VM Network operations
    MAC                     = '3a:5b:7c:17:19:05'
    #MTU                     = 1500
    #NetworkName             = @("Pool-wide eth0", "Pool-wide eth1") #VM Network operations
}
$vmObject = [pscustomobject]$vmParam
$vmArray += $vmObject
#endregion

#region Xen Automation - 2022 - INITIALIZE device NodeName parameters - file server fs02
$VmParam = @{
    VMName                  = 'fs02'       #VM Skel
    VMDescription           = "$domainName - file server 02"
    VMSKU                   = 'Windows Server 2019' #VM Template
    VMBootISO               = 'w2k19core_1809LTSC_unattended_updated2111.iso'
    #VMIsoSR                 = 'centos8Stream_nfs'   #ISO SR
    VMDiskGB                = 32
    VMSR                    = 'node1_ssd'           #VM disk
    VMRAM                   = 2 * 1GB      #VM Skel
    VMCPU                   = 4            #VM Skel
    HVMBootPolicy           = "BIOS order" #VM Skel
    HVMShadowMultiplier     = 1            #VM Skel
    UserVersion             = 1            #VM Skel
    ActionsAfterReboot      = "restart"    #VM Skel
    ActionsAfterCrash       = "restart"    #VM Skel
    HardwarePlatformVersion = 2            #VM Skel
    NetworkName             = @("Pool-wide eth1") #VM Network operations
    MAC                     = '3a:5b:7c:17:19:06'
    #MTU                     = 1500
    #NetworkName             = @("Pool-wide eth0", "Pool-wide eth1") #VM Network operations
}
$vmObject = [pscustomobject]$vmParam
$vmArray += $vmObject
#endregion

#endregion
#endregion

#region Xen Automation - 2022 - INITIALIZE / START
#region Xen Automation - 2022 - INITIALIZE / START - POWER UP hypervisor via IPMI
#power up the node via ipmi - DNS is resolved on the piHole
#password is kept in keepas, Remote Control -> Power Control - Power On Server -> Perfrom Action
Start-Process  https://$nodeIpmiFqdn #ipmi node1
#Start-Process https://node3ipmi.lab #ipmi node3
#endregion

#region Xen Automation - 2022 - INITIALIZE / START - XCP-ng Center, rdcman, keepas 
Start-App -Path "${env:ProgramFiles(x86)}\XCP-ng Center\XCP-ng Center.exe" -WorkingDirectory "${env:ProgramFiles(x86)}\XCP-ng Center\" -Verbose
Start-App -Path "$env:ProgramFiles\RDCMan\RDCMan.exe" -WorkingDirectory "$env:ProgramFiles\RDCMan" -Verbose
Start-App -Path "$env:ProgramFiles\KeePass Password Safe 2\KeePass.exe" -WorkingDirectory "$env:ProgramFiles\KeePass Password Safe 2" -Verbose
#Start-App -Path "$env:ProgramFiles\PuTTY\putty.exe" -WorkingDirectory "$env:ProgramFiles\PuTTY\" -puttySession 'node1_xcpng' -Verbose
#endregion
#endregion

#wait 5min

#region Xen automation - 2022 - LAUNCH - Test-NetConnection,launch putty session
# Wait around 5min - until the hypervisor boots up
#Test-NetConnection -ComputerName $nodeIp -Port 22 -InformationLevel Detailed
Test-NetConnection -ComputerName $nodeFqdn -Port $sshPortNumber -InformationLevel Detailed

putty.exe -load $puttySshSessionName
#putty.exe -load 'node0_xcpng'
#putty.exe -load 'node3_xcpng'
#endregion

#region Xen Automation - Xen - CONNECT
#2022 - consider setting up the certificates on Xen
Connect-PLXen -XenHost $nodeFqdn -Credential $xenCred -Verbose
#Connect-PLXen -XenHost '10.0.4.250' -Credential $xenCred -Verbose
#endregion

#region Xen Automation - VM - INVENTORY - NETWORK IPv4 addresses get the IP address of all hosts running on node
Get-XenVM | Where-Object {$_.is_a_template -eq $False -and $_.is_a_snapshot -eq $False -and $_.power_state -eq "running"} | select name_label,uuid,vCPUs_max,@{Name='ipv4';Expression={((Get-XenVMGuestMetrics -Uuid (Get-XenVMProperty -vm (Get-XenVM -Uuid $_.uuid) -XenProperty GuestMetrics).uuid).Networks)['0/ipv4/0']}},@{Name='ipv6';Expression={((Get-XenVMGuestMetrics -Uuid (Get-XenVMProperty -vm (Get-XenVM -Uuid $_.uuid) -XenProperty GuestMetrics).uuid).Networks)['0/ipv6/0']}} | Format-Table -AutoSize
#Get-XenVM | Where-Object {$_.is_a_template -eq $False -and $_.is_a_snapshot -eq $False -and $_.power_state -eq "running"} | select name_label,uuid,vCPUs_max,@{Name='ip';Expression={((Get-XenVMGuestMetrics -Uuid (Get-XenVMProperty -vm (Get-XenVM -Uuid $_.uuid) -XenProperty GuestMetrics).uuid).Networks)['0/ipv6/0']}}
#Get-XenVM | Where-Object {$_.is_a_template -eq $False -and $_.is_a_snapshot -eq $False -and $_.power_state -eq "running"} | select name_label,uuid,vCPUs_max,@{Name='ip';Expression={((Get-XenVMGuestMetrics -Uuid (Get-XenVMProperty -vm (Get-XenVM -Uuid $_.uuid) -XenProperty GuestMetrics).uuid).Networks)['0/ipv4/0']}}
#((Get-XenVMGuestMetrics -Uuid (Get-XenVMProperty -vm (Get-XenVM -Uuid '061d0761-5985-1014-0d29-b26f34f7bc92') -XenProperty GuestMetrics).uuid).Networks)['0/ipv4/0']
#endregion

#region Xen Automation - VM - INVENTORY - Network details
Get-PLXenVMNetwork | Out-GridView
#endregion

#region Xen Automation - Xen - DISCONNECT
#Disconnect-XenServer -Session (Get-XenSession)
Disconnect-PLXen -Verbose
#Disconnect-XenServer
#endregion

#region Xen Automation - Xen - INVENTORY
#Start-Process 'https://nikiink.wordpress.com/2016/10/22/xenserver-7-0-api-powershell-backup-running-vms/' #backup VM
#Start-Process 'https://www.citrix.com/blogs/2014/03/11/citrix-xenserver-setting-more-than-one-vcpu-per-vm-to-improve-application-performance-and-server-consolidation-e-g-for-cad3-d-graphical-applications/'
#Start-Process 'https://github.com/santiagocardenas/xenserver-powershell-scripts/blob/master/Set-XenServerVMResources.ps1'

#sprawdzic jakby sie to zachowywalo gdyby chciec dodac wiecej niz jednego hosta
#wynies dane wejsciowe na zewnatrz do jakiegos pliku psd, json

#region Xen Automation - Xen - INVENTORY - Getting details about Xen configuration
#Xen Storage Repositories - Available Labels
Get-PLXenSR -Verbose
#Xen List of default templates - those can be used for VM provisioning
Get-PLXenTemplate -Type default -Verbose
#Xen List Custom templates
Get-PLXenTemplate -Type custom -Verbose
#Xen RAM Total
Get-PLXenRam -Type Total -Verbose
#Xen RAM Free
Get-PLXenRam -Type Free -Verbose
#Xen Storage Repositories - getting details about all SR
Get-PLXenStorage -Verbose | Select-Object * -ExcludeProperty SROtherConfig | Sort-Object SRNameLabel | Out-GridView
#Xen Storage Repositories - dedicated for VMs, total, used and free space
Get-PLXenStorage | Where-Object { $_.SRNameLabel -match "ssd|hdd|nvme"}

#Xen Cpu Threads
Get-PLXenCPUCount -Verbose
#Xen Iso Repositories - Available Labels
Get-PLXenISORepository -Verbose
#Xen Iso Repositories - Details about availability, type and path
Get-PLXenISOLibrary -Verbose

Get-PLXenISOLibrary | Where-Object { $_.SRIsoOtherConfig.Keys -notmatch "dirty" } | Out-GridView  #show those which needs to be fixed
Get-PLXenISOLibrary | Where-Object { $_.SRIsoOtherconfig.Values -match "true" } #show those which are available for Xen
#($(Get-PLXenISOLibrary).SRIsoOtherconfig).Keys
#Get-PLXenISOLibrary | Where-Object {$_.SRIsoOtherconfig.Values -match "true"} | Select-Object SRIsoNameLabel | Get-PLXenIso -Verbose | Select-Object IsoLabel 
Get-PLXenISOLibrary | Where-Object { $_.SRIsoOtherconfig.Values -match "true" } #list available ISO Libraries
#for the available ISO Libraries list all iso files which are available for your disposal
Get-PLXenISOLibrary | Where-Object { $_.SRIsoOtherconfig.Values -match "true" } | Select-Object SRIsoNameLabel | Get-PLXenIso -Verbose | Select-Object IsoLabel,IsoDescription,IsoVirtualSize,IsoPhysicalUtilization,IsoIsToolsIso,SRNameLabel,SRNameDescription,SRUUID | Sort-Object IsoLabel | Out-GridView

#Xen ISO Storage Repositories
Get-PLXenIso -SRName $nodeIsoSR -Verbose
Get-PLXenIso -SRName $nodeIsoSR -Verbose | Select-Object IsoLabel | Where {$_.IsoLabel -match 'w2k19'} #node1

#Xen network
Get-PLXenNetwork -Verbose | Sort-Object NetworkBridge 
#endregion

#region Xen Automation - Xen - INVENTORY - list available templates, storage, iso
#$vm = @("_w10_mgmt","dc01","dc02") | Select-Object @{Name="VM";Expression={$_}}
#$vm = @("dc01","dc02") | Select-Object @{Name="VM";Expression={$_}}
#$vm = @('_authoring','dc01','dc02','rootCA','subCA','testVM')
#endregion
#endregion

#region Xen Automation - VM - CREATE
#New-PLXenVM -VmParam ($vmArray | Where-Object {$_.VMName -match $vmNameRegex}) -Firmware uefi -SecureBoot False -Verbose
foreach ($vm in ($vmArray | Where-Object {$_.VMName -match $vmNameRegex})){
    New-PLXenVM -VmParam $Vm -Firmware uefi -SecureBoot False -Verbose # Variable initialization are within the begin section of New-PLXenVm
}

New-PLXenVM -VmParam $VmParam -Firmware uefi -SecureBoot True -Verbose # Variable initialization are within the begin section of New-PLXenVm
#New-PLXenVM -VmParam $VmParam -Firmware bios -Verbose # Variable initialization are within the begin section of New-PLXenVm
#endregion

#region Xen Automation - VM - Start VM
Invoke-XenVM -Name $VmParam.VMName -XenAction Start -Async
#endregion

#region Xen Automation - VM - MODIFY - change boot order, autoPowerOn
#Start-Process 'https://discussions.citrix.com/topic/414777-xenserver-boot-mode-uefi-boot-for-machines-created-with-powershell-api/'
$allXenVm = (Get-XenVM | Where-Object { $_.is_a_template -eq $False -and !($_.other_config.default_template) -and $_.is_a_snapshot -eq $False} | Sort-Object -Property name_label).name_label
$xenVm = $allXenVm | Where-Object {$_ -match $vmNameRegex}
$xenVm = foreach($element in ($allXenVm | Where-Object {$_ -match $vmNameRegex})){
    Get-XenVM -Name $element
}

Set-PLXenVM -VMName $xenVm.name_label -BootOrder c -Verbose
Set-PLXenVM -VMName $xenVm.name_label -BootOrder cd -Verbose
Set-PLXenVM -VMNameRegex $vmNameRegex -BootOrder c -Verbose
Set-PLXenVM -VMNameRegex $vmNameRegex -BootOrder dc -Verbose
Set-PLXenVM -VMNameRegex $vmNameRegex -BootOrder cdn -Verbose

Set-PLXenVM -VMName $xenVM.name_label -AutoPowerOn $True -Verbose
Set-PLXenVM -VMName $xenVM.name_label -AutoPowerOn $False -Verbose
Set-PLXenVM -VMName $xenVM.name_label -AutoPowerOn 0 -Verbose
Set-PLXenVM -VMName $xenVM.name_label -AutoPowerOn 1 -Verbose
Set-PLXenVM -VMNameRegex $vmNameRegex -AutoPowerOn $True -Verbose
Set-PLXenVM -VMNameRegex $vmNameRegex -AutoPowerOn $False -Verbose

#region Xen Automation - VM - MODIFY - change boot order
$vm = ($vmArray | Where-Object {$_.VMName -match $vmNameRegex} | Select-Object @{Name="Name";Expression={$_.VMName}}).foreach{
        Get-XenVM -Name $_.Name
}

#$vm = Get-XenVM -Name 'bootOrder'
#$vm = Get-XenVm -Name ($vmArray | Where-Object {$_.VMName -match $vmNameRegex}).VMName

#c - hardDisk
#d - dvd
#n - network
$bootParams = @{order = 'cdn'}
#$bootParams = @{order = 'dcn'}
#$bootParams = @{order = 'c'}
#$bootParams = @{order = "dc"; firmware = "uefi"}
#$bootParams = @{order = "dc"; firmware = "bios"}

#Modify the VMthat it starts from hard drive or dvd
foreach($element in $vm){
    Set-XenVM -VM $element -HVMBootParams $bootParams -Verbose
    #xe vm-param-set uuid=<UUID> HVM-boot-params:order=ndc
}
#Set-XenVM -VM (Get-XenVM -Name 'bootOrder') -HVMBootParams $bootParams
#endregion

#region Xen Automation - VM - MODIFY - change autostart
#Modify the VM that it autostarts with the Hypervisor
$otherConfig = @{auto_poweron = 'true'}
$otherConfig = @{auto_poweron = 'false'}
foreach($element in $vm){
    Set-XenVM -VM $element -OtherConfig $otherConfig -Verbose
}
#endregion
#endregion

#region Xen Automation - CREATE VM - Unmount CD after sucesfull installation
#$vm = ($vmArray | Where-Object {$_.VMName -match $vmNameRegex} | Select-Object @{Name="Name";Expression={$_.VMName}}).foreach{
#        Get-XenVM -Name $_.Name
#}

foreach($element in ($vmArray | Where-Object {$_.VMName -match $vmNameRegex})){
    Write-Output "Performing the operation `"VBD.eject`" on target $($element.VMName)"
    Get-XenVm -Name $element.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object { $_.type -eq "CD" } | Invoke-XenVBD -XenAction Eject -Verbose #eject ISO
}

#Get-XenVm -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object { $_.type -eq "CD" } | Invoke-XenVBD -XenAction Eject #eject ISO
#endregion

#region Xen Automation - CREATE VM - Mount XenServer Tools
foreach($element in ($vmArray | Where-Object {$_.VMName -match $vmNameRegex})){
    Write-Output "Performing the operation `"VBD.insert`" on target $($element.VMName)"
    Get-XenVM -Name $element.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object { $_.type -eq "CD" } | Invoke-XenVBD -XenAction Insert -VDI (Get-XenVDI -Uuid (Get-PLXenIso -SRName $nodeIsoSR | Where-Object { $_.IsoLabel -match $xenServerToolsIso }).IsoUUID | Select-Object -ExpandProperty opaque_ref) -Verbose
}
#Get-XenVM -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object { $_.type -eq "CD" } | Invoke-XenVBD -XenAction Insert -VDI (Get-XenVDI -Uuid (Get-PLXenIso -SRName $nodeIsoSR | Where-Object { $_.IsoLabel -match $xenServerToolsIso }).IsoUUID | Select-Object -ExpandProperty opaque_ref)
#endregion

#region Xen Automation - CREATE VM - Unmount CD after sucesfull installation of XenTools
foreach($element in ($vmArray | Where-Object {$_.VMName -match $vmNameRegex})){
    Write-Output "Performing the operation `"VBD.eject`" on target $($element.VMName)"
    Get-XenVm -Name $element.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object { $_.type -eq "CD" } | Invoke-XenVBD -XenAction Eject -Verbose #eject ISO
}
#Get-XenVm -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object { $_.type -eq "CD" } | Invoke-XenVBD -XenAction Eject #eject ISO
#endregion

#endregion

$vmNameRegex = "dcLab"
$vmName = @('dcLab-NOK','dcLab-OK')
$vmName = @('_authoring')

$vmNameRegex = "fs|dc"
$vmName = @('_mgmt','_authoring','dc01','dc02')
#show all VMs parameters defined in the current configuration
$vmArray.VMName
$vmArray | Select-Object VMName,@{Name='RAMGB';Expression={$_.VMRAM/1GB}},@{Name='DiskGB';Expression={$_.VMDiskGB}},VMSR,MAC,NetworkName,VMSKU,HVMBootPolicy,VMBootISO,VMDescription | Out-GridView
$vmArray | Where-Object {$_.VMName -match 'fs'} | Select-Object VMName


Start-PLXenVM -VMName $vmName -Verbose
$vmArray | Where-Object {$_.VMName -match 'fs'} | Select-Object VMName | Start-PLXenVM -Verbose
$vmArray | Where-Object {$_.VMName -match 'dc'} | Select-Object VMName | Start-PLXenVM -Verbose
$vmArray | Where-Object {$_.VMName -match $vmNameRegex} | Select-Object VMName | Start-PLXenVM -Verbose

#region Xen Automation - VM Operations - EJECT iso / XenTools / Snapshot
$allXenVm = (Get-XenVM | Where-Object { $_.is_a_template -eq $False -and !($_.other_config.default_template) -and $_.is_a_snapshot -eq $False} | Sort-Object -Property name_label).name_label
$xenVm = $allXenVm | Where-Object {$_ -match $vmNameRegex}
$xenVm = foreach($element in ($allXenVm | Where-Object {$_ -match $vmNameRegex})){
    Get-XenVM -Name $element
}

#region Xen Automation - VM Operations - EJECT iso from the DVD bay
$xenVm | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object { $_.type -eq "CD" } | Invoke-XenVBD -XenAction Eject #eject ISO
#endregion

#region Xen Automation - VM Operations - XenTools - Mount XenTools to the DVD bay
$xenVm | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object { $_.type -eq "CD" } | Invoke-XenVBD -XenAction Insert -VDI (Get-XenVDI -Uuid (Get-PLXenIso -SRName $nodeIsoSR | Where-Object { $_.IsoLabel -match $xenServerToolsIso }).IsoUUID | Select-Object -ExpandProperty opaque_ref) -Verbose #mount iso
#endregion

#region Xen Automation - VM Operations - XenTools - Unmount XenTools from the DVD bay
#$nodeName.ForEach({
#    Get-XenVm -Name $_ | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object { $_.type -eq "CD" } | Invoke-XenVBD -XenAction Eject #eject ISO
#})
$xenVm | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object { $_.type -eq "CD" } | Invoke-XenVBD -XenAction Eject -Verbose #eject ISO
#endregion

#region Xen Automation - VM Operations - Snapshot - Take and Remove
$snapshotName = 'beforeInitialSetup'

#$vmName = ($vmArray | Where-Object {$_.VMName -match $vmNameRegex} | Select-Object @{Name="Name";Expression={$_.VMName}})

$allXenVm = (Get-XenVM | Where-Object { $_.is_a_template -eq $False -and !($_.other_config.default_template) -and $_.is_a_snapshot -eq $False} | Sort-Object -Property name_label).name_label
$xenVm = $allXenVm | Where-Object {$_ -match $vmNameRegex}
$xenVm = foreach($element in ($allXenVm | Where-Object {$_ -match $vmNameRegex})){
    Get-XenVM -Name $element
} 
$xenVm = $xenVm | Select-Object @{Name="VmName";Expression={$_.name_label}}


#region Xen Automation - VM Operations - Take a Snapshot
#New-PLXenSnapshotVM -VMName $vmName -SnapshotName $snapshotName -Verbose
New-PLXenSnapshotVM -VMName $xenVM.VMName -SnapshotName $snapshotName -Verbose
$xenVm | New-PLXenSnapshotVM -SnapshotName $snapshotName -Verbose
#each snapshot should have a unique name, then it works
#endregion

#region Xen Automation - VM Operations - Remove Snapshot
#Remove-PLXenSnapshotVM -VMName $VmName -SnapshotName $snapshotName -Verbose
Remove-PLXenSnapshotVM -VMName $VmName.VMName -SnapshotName $snapshotName -Verbose
$xenVm | Remove-PLXenSnapshotVM -SnapshotName $snapshotName -Verbose
#endregion
#endregion

#region Xen Automation - VM - INVENTORY - Show Network IP address
$allXenVm = (Get-XenVM | Where-Object { $_.is_a_template -eq $False -and !($_.other_config.default_template) -and $_.is_a_snapshot -eq $False} | Sort-Object -Property name_label)
$allxenVm = $allXenVm | Where-Object {$_.name_label -match $vmNameRegex}
#((Get-XenVM -Name $VmParam.VMName | Select -ExpandProperty guest_metrics | Get-XenVMGuestMetrics).networks.'0/ipv4/0')
(($allXenVm | Select-Object -ExpandProperty guest_metrics | Get-XenVMGuestMetrics).networks.'0/ipv4/0')
#endregion
#endregion

#region Xen Automation - MODIFY VM
#region Xen Automation - MODIFY VM - Xen-SetServerVmResources
# Start-Process 'https://github.com/santiagocardenas/xenserver-powershell-scripts/blob/master/Set-XenServerVMResources.ps1'
Set-Location -path "$Env:USERPROFILE\Documents\howtoLab\_scripts\2021\"
$VMparamModify = @{
    VMNames       = '[VMName]'
    CPUs          = 4
    MemoryGB      = 2
    XenServerHost = '[IP address of your XCPng host/pool master]'
    UserName      = '[XCPng user]'
    Password      = '[XCPng password]'
    NetworkNames  = 'Pool-wide eth0'
    TryDelay      = 5
    Tries         = 5
}
.\Xen-SetServerVMResources.ps1 @VMparamModify -Verbose

#.\Set-XenServerVMResources.ps1 -VMNames $VmParam.VMName `
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

#region Xen Automation - MODIFY VM - add disk to the VM and activate it
#authoring VM second disk for the iso and Segura OSD tooling to update the iso files
#show available storage repositories on which extra disk can be provisioned
Get-PLXenStorage | Select-Object SRNameLabel,SRNameDescription,SrType | Sort-Object SRNameLabel
$xenVm = Get-XenVM -Name $VmParam.VMName
#show drives which are not CD
$xenVm.VBDs | ForEach-Object {Get-XenVBD $_.opaque_ref | Where-Object { $_.type -notmatch "CD" }} | Select-Object @{Name="vmname";Expression={$VmParam.VMName}},mode,userdevice,uuid
#Get-XenVDI -Ref ($VM.VBDs | ForEach-Object {Get-XenVBD $_.opaque_ref | Where-Object { $_.type -notmatch "CD" }} | Select-Object -ExpandProperty VDI).opaque_ref

#extra drive can be created on slower or faster storage tier
$xenSr = Get-XenSR -Name 'node1_hdd'
#show available space on the Storage Repository
$xenSr | Select-Object @{Name="Name";Expression={$_.name_label}},@{Name="Description";Expression={$_.name_description}},@{Name="Used-GB";Expression={$_.physical_utilisation/1GB}},@{Name="Size-GB";Expression={$_.physical_size/1GB}},type
#deine disk size in GB
$subsequentDiskSize = 100
$subsequentDiskName = "{0}-{1}" -f $VmParam.VMName, "OsData"
$subsequentDiskDescription = "{0}-{1}-{2}" -f $vmParam.VMName,"OsData",$vmSourceTemplateObject.XenTemplateName
New-XenVDI -NameLabel $subsequentDiskName -VirtualSize ($subsequentDiskSize * 1073741824) -SR $xenSr -Type user -NameDescription $subsequentDiskDescription -Verbose
#Get-XenVDI | Where-Object {$_.name_description -eq $subsequentDiskDescription}
#2022.01.11 - tutaj jest jakis problem zwiazany z zakleszczeniem ktore sie pojawia jesli jest snapshot maszynki - koliduja nazwy dyskow - FIX this
$xenVdi = Get-XenVDI -Name $subsequentDiskName
#add disk to the VM
New-XenVBD -VM $xenVm.opaque_ref -VDI $xenVdi.opaque_ref -Type Disk -mode RW -Userdevice 1 -Bootable $False -Unpluggable $false -Verbose

# Show details about disks combined with VM
(Get-XenVM -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object {$_.type -eq "Disk"}) | Select-Object uuid,userdevice,bootable,mode,type,unpluggable,currently_attached,opaque_ref | Sort-Object userdevice
#(Get-XenVM -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object {$_.type -eq "Disk"}) | Select-Object -ExpandProperty VDI
#(Get-XenVM -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object {$_.type -eq "Disk"}) | Select-Object -ExpandProperty VM
#(Get-XenVM -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object {$_.type -eq "Disk"}) | Select-Object -ExpandProperty metrics
Get-XenVBD -Uuid (((Get-XenVM -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs) | Get-XenVBD | Where-Object {$_.type -eq "Disk"}) | Where-Object {$_.userdevice -eq 1}).uuid | Select-Object uuid,userdevice,bootable,mode,type,unpluggable,currently_attached,opaque_ref | Sort-Object userdevice

#Get-XenVBD -opaque_ref 'OpaqueRef:b692d0d7-b88c-4222-9422-58b8b2844a82'

Start-PLXenVM -VMName $VmParam.VMName -Verbose

# Activate disk - vm needs to be in running state to make it work
# 2022.01.1 - pieje bledem ze maszynka musi byc w running state a byla w halted i nie chce wykonac zaklecia
# w momencie gdy jest w running pieje ze device is already attached to the VM
Invoke-XenVBD -XenAction Plug -Uuid ((((Get-XenVM -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs) | Get-XenVBD | Where-Object {$_.type -eq "Disk"}) | Where-Object {$_.userdevice -eq 1}).uuid)

#Invoking VBD.create makes a VBD object on the XenServer installation and returns its object reference. However, 
#this call in itself does not have any side-effects on the running VM 
# (that is, if you go and look inside the running VM you will see that the block device has not been created). 
# The fact that the VBD object exists but that the block device in the guest is not active, is reflected by the fact that 
# the VBD object's currently_attached field is set to false.
#(Get-XenVM -Name $VmParam.VMName | Select -ExpandProperty VBDs | Get-XenVBD | Where-Object {$_.type -eq "Disk"}).currently_attached

#Set-XenVDI -NameLabel $VmParam.VMName

#endregion
#endregion

#region Xen Automation - REMOVE VM
#region Xen Automation - REMOVE CDs DVDs
$xenVm = Get-XenVM -Name $VmParam.VMName
#$VM.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object { $_.type -notmatch "CD" } } #show drives which are not CD
#$VM.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object { $_.type -match "CD" } } #show drives which are CD's
#Get-XenVBD -Uuid ($VM.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object {$_.type -notlike "CD"} }).uuid
$xenVm.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object { $_.type -notmatch "CD" } } | ForEach-Object { Get-XenVDI -Ref $_.VDI | Remove-XenVDI -Confirm:$true } #test this
#endregion

#region Xen Automation - REMOVE network interface bound with VM
$xenVm = Get-XenVM -Name $VmParam.VMName
#Get-XenVm -Name $_ | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object { $_.type -eq "CD" } | Invoke-XenVBD -XenAction Eject #eject ISO
$xenVm.VIFs | ForEach-Object { Get-XenVIF $_.opaque_ref | Remove-XenVIF -Confirm:$true } #Remove network interfaces from VM
#endregion

#region Xen Automation - DETACH disks and DVD from VM
$xenVm = Get-XenVm -Name $VmParam.VMName
$xenVm.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object { $_.type -match "CD" } | Remove-XenVBD -Confirm:$true } #detach DVD from VM
$xenVm.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object { $_.type -match "disk" -and $_.mode -match "RW" } | Remove-XenVBD -Confirm:$true } #detach disk from VM
#endregion

#region Xen Automation - REMOVE hard disk 1 combined with VM
$xenVm = Get-XenVM -Name $VmParam.VMName
#remove only the subsequent disk - Data Disk not the OS disk
$xenVm.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object {($_.type -notlike "CD") -and ($_.userdevice -eq 1)} } | ForEach-Object {Get-XenVDI -Ref $_.VDI | Remove-XenVDI -Confirm:$true}
#endregion

#region Xen Automation - REMOVE hard disk / DVD which are no longer needed
#in case you end up with two DVD bound to the VM, this is the way those can be removed
$xenVm = Get-XenVM -Name $VmParam.VMName
$xenVm.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object { $_.type -notmatch "CD" } } #show drives which are not CD
$xenVm.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object { $_.type -match "CD" } } #show drives which are CD's
#Get-XenVBD -Uuid ($xenVm.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object {$_.type -notlike "CD"} }).uuid
$xenVm.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object { $_.type -notmatch "CD" } } | ForEach-Object { Get-XenVDI -Ref $_.VDI | Remove-XenVDI -Confirm:$true } #test this
#$xenVm | Remove-XenVM #remove VM
#endregion

#region Xen Automation - REMOVE all virtual hard disks combined with VM
$xenVm = Get-XenVM -Name $VmParam.VMName
#$vm.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object {$_.type -notlike "CD"} } | Sort-Object userdevice
$xenVm.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object {$_.type -notlike "CD"} } | ForEach-Object {Get-XenVDI -Ref $_.VDI | Remove-XenVDI -Confirm:$true}
#$xenVm.opaque_ref
#$xenVm | Remove-XenVM -Confirm:$true #this will delete the vm object
#######
##$($VmParam.VMName).ForEach({
##    #Invoke-XenVBD -XenAction UnplugForce -Uuid ((((Get-XenVM -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs) | Get-XenVBD | Where-Object {$_.type -eq "Disk"}) | Where-Object {$_.userdevice -eq 1}).uuid)   
##    $xenSr = Get-XenSR -Name $VmParam.VMSR
##    Get-XenVDI -Name $_ | Where-Object {$_.xenSr.opaque_ref -like $xenSr.opaque_ref } | Select-Object -ExpandProperty VBDs | Remove-XenVDI -Confirm:$true
##    #Get-XenVDI | Where-Object {($_.xenSr.opaque_ref -like $xenSr.opaque_ref) -and ($_.name_label -match $_)} #| Where-Object {  }
##})
##Get-XenVDI -Name '_authoring' | Select-Object -ExpandProperty VBDs | Get-XenVBD | Select-Object -ExpandProperty VM
##Get-XenVBD -Uuid f2eacfcb-c7d6-408a-9215-32ef41816f71
#$nodeName.ForEach({
#    Get-XenVDI | Where-Object { $_.xenSr.opaque_ref -like $xenSr.opaque_ref } | Where-Object { $_.name_label -match $_ } | Remove-XenVDI -Confirm:$true
#})

##$nodeName.ForEach({
##    Get-XenVDI -Name $_ | Remove-XenVDI -Confirm:$true
##})
#endregion

#region Xen Automation - REMOVE virtual machine object from the Xen inventory
$xenVm = Get-XenVM -Name $VmParam.VMName
$xenVm | Remove-XenVM
#Get-XenVM -Name $VmParam.VMName
#endregion
#endregion

#region Xen Automation - KILL VM - sprawdzic po co ta czesc czy da sie to zintegrowac z REMOVE VM
$xenVm = Get-XenVM -Name $VmParam.VMName
#region Xen Automation - KILL VM - EJECT iso from the DVD bay
#Get-XenVm -Name $VmParam.VMName | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object { $_.type -eq "CD" } | Invoke-XenVBD -XenAction Eject #eject ISO
$xenVm | Select-Object -ExpandProperty VBDs | Get-XenVBD | Where-Object { $_.type -eq "CD" } | Invoke-XenVBD -XenAction Eject #eject ISO
#endregion

#region Xen Automation - KILL VM - REMOVE network interfaces bound with VM
$xenVm.VIFs | ForEach-Object { Get-XenVIF $_.opaque_ref | Remove-XenVIF -Confirm:$true } #Remove network interfaces from VM
#endregion

#region Xen Automation - KILL VM - DETACH disks and DVD from VM
$xenVm.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object { $_.type -match "CD" } | Remove-XenVBD -Confirm:$true } #detach DVD from VM
$xenVm.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object { $_.type -match "disk" -and $_.mode -match "RW" } | Remove-XenVBD -Confirm:$true } #detach disk from VM
#$VM.VBDs | ForEach-Object { Get-XenVBD $_.opaque_ref | Where-Object {$_.type -notmatch "CD"} } | ForEach-Object {Get-XenVDI -Ref $_.VDI | Remove-XenVDI -Confirm:$true} #detach disk from VM
#endregion

#region Xen Automation - KILL VM - REMOVE virtual disks combined with the VM
Get-XenVDI | Where-Object { $_.SR.opaque_ref -like $sr.opaque_ref } | Where-Object { $_.name_label -match $VmParam.VMName } | Remove-XenVDI -Confirm:$true
#endregion

#region Xen Atuomation - KILL VM - REMOVE VM Object / Skeleton - at this stage it should have any objects combined with it
$xenVm | Remove-XenVM #usun VMke
#Get-XenVM -Name $VmParam.VMName | Remove-XenVM -Confirm:$true #remove VM, it looks like it does not confirm the action, on the prompt you'll get the UUID of VM not it's name, don't be surprised
$xenVm | Remove-XenVM -Confirm:$true #remove VM, it looks like it does not confirm the action, on the prompt you'll get the UUID of VM not it's name, don't be surprised
#endregion
#endregion

#region Xen Automation - START STOP RESTART VM
#$vm | Start-PLXenVM -Verbose
Start-PLXenVM -VMName $VmParam.VMName -Verbose
#$vm | Restart-PLXenVM -Verbose
Restart-PLXenVM -VMName $VmParam.VMName -Verbose
#$vm | Stop-PLXenVM -Verbose
Stop-PLXenVM -VMName $VmParam.VMName -Verbose
#$vm | Stop-PLXenVM -Force -Verbose
Stop-PLXenVM -VMName $VmParam.VMName -Force -Verbose
#endregion

#endregion
