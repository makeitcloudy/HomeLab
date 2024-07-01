#region w10mgmt - initial configuration
# file is bound with 000_w10mgmt_initialConfig
# $dscConfigPath - should be created on w10mgmt VM, files

# * ConfigurationData.psd1
# * ConfigureLCM.ps1
# * ConfigureNode.ps1

# stored in $dscConfigPath directory

# * w10mgmt_initialConfig_demo.ps1 

# stored in $env:USERPROFILE\Documents directory
# it contains commandlines for succesfull execution of the DSC Configuration stored in
# three files mentioned above

#region w10mgmt - initial configuration 
$env:COMPUTERNAME

#region w10mgmt - initial checks
update-help
Get-ExecutionPolicy
Get-Service -Name WinRM #stopped
Test-WSMan -ComputerName localhost #can not connect 
Get-Item WSMan:\localhost\Client\TrustedHosts #winRM is not running hence error during execution
#endregion

#region w10mgmt - change network interface name
### assumption - there is only one network interface 
### Get the current network interface with a name that is not "Ethernet"
#$tempNetworkInterfaceName = 'Eth'
#$networkInterface = Get-NetAdapter | Where-Object { $_.Name -ne 'Ethernet' }
#
### Check if a network interface was found and rename it to "Ethernet"
#if ($networkInterface) {
#    Rename-NetAdapter -Name $networkInterface.Name -NewName $tempNetworkInterfaceName
#} else {
#    Write-Output "No network interface found to rename."
#}
#endregion

#region WinRM configuration
Set-NetConnectionProfile -NetworkCategory Private
Enable-PSRemoting
Get-Item WSMan:\localhost\Client\TrustedHosts #empty
#endregion
#endregion

#region 001 - DSC - demo
# double check if this is a best practice
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force

Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force

# Seems 'PSDesiredStateConfiguration' module can not be installed otherwise it throws error during the LCM setup

# Import-Module : The version of Windows PowerShell on this computer is '5.1.19041.2364'. The module 'C:\Program Files\WindowsPowerShell\Modules\PSDesiredS
# tateConfiguration\2.0.7\PSDesiredStateConfiguration.psd1' requires a minimum Windows PowerShell version of '6.1' to run. Verify that you have the minimum
#  required version of Windows PowerShell installed, and then try again.
# At line:3 char:25
# + ...             Import-Module PSDesiredStateConfiguration -Verbose:$false ...
# +                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#     + CategoryInfo          : ResourceUnavailable: (C:\Program File...figuration.psd1:String) [Import-Module], InvalidOperationException
#     + FullyQualifiedErrorId : Modules_InsufficientPowerShellVersion,Microsoft.PowerShell.Commands.ImportModuleCommand
#  
# PSDesiredStateConfiguration\Configuration : The module 'PSDesiredStateConfiguration' could not be loaded. For more information, run 'Import-Module PSDesi
# redStateConfiguration'.
# At C:\Users\labuser\Documents\dsc_config_w10mgmt\ConfigureLCM.ps1:2 char:1
# + Configuration ConfigureLCM {
# + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#     + CategoryInfo          : ObjectNotFound: (PSDesiredStateC...n\Configuration:String) [], CommandNotFoundException
#     + FullyQualifiedErrorId : CouldNotAutoLoadModule

#Install-Module -Name 'PSDesiredStateConfiguration' -Force -AllowClobber

#Get-Module -ListAvailable -Name 'PSDesiredStateConfiguration' | Uninstall-Module
#Get-Module -ListAvailable -Name 'PSDesiredStateConfiguration' | Remove-Module

#region - always run - initialize variables
#region initialize variables - DSC
$drive                              = 'C:'
$dscConfigFolder                    = 'dscConfig'
# DSC mof files full path
$dscConfigFullPath                  = Join-Path -Path $drive -ChildPath $dscConfigFolder

# DSC configuration location
$dscConfigPath                      = "$env:SYSTEMDRIVE\dscConfig\_w10mgmt\"
# DSC configuration data file - stored in the same directory as DSC configuration
$dscConfigDataFileName              = "ConfigData.psd1"
# DSC configuration data file full path
$dscConfigDataPath                  = Join-Path -Path $dscConfigPath -ChildPath $dscConfigDataFileName

# Provide credentials for DSC to use
$AdminUsername                      = "labuser"
$AdminPassword                      = ConvertTo-SecureString "Password1$" -AsPlainText -Force
$AdminCredential                    = New-Object System.Management.Automation.PSCredential ($AdminUsername, $AdminPassword)
#endregion

#region initialize variables - New-SelfSignedCertificateEx.ps1 function
$mypwd                               = ConvertTo-SecureString -String "Password1$" -Force -AsPlainText

$newSelfsignedCertificateExGithubUrl = 'https://raw.githubusercontent.com/Azure/azure-libraries-for-net/master/Samples/Asset/New-SelfSignedCertificateEx.ps1'

$newSelfSignedCertificateExFileName  = 'New-SelfSignedCertificateEx.ps1'
$downloadsFolder                     = $("$env:USERPROFILE\Downloads")
$newSelfSignedCertificateExFullPath  = Join-Path -Path $dscConfigFullPath -ChildPath $newSelfSignedCertificateExFileName

$dscSelfSignedCertificateName        = 'dscSelfSignedCertificate'
$dscSelfSignedCerCertificateName     = $dscSelfSignedCertificateName,'cer' -join '.'
$dscSelfSignedPfxCertificateName     = $dscSelfSignedCertificateName,'pfx' -join '.'

#endregion

#region create path for DSC outputs
If(!(Test-Path -Path $dscConfigFullPath)){
        try{
            New-Item -Path $dscConfigFullPath -ItemType Directory
        }
        catch{

        }
    }
#endregion

# set the location to the path where the DSC configuration is stored
Set-Location -Path $dscConfigPath
#endregion

#region - run once - DSC prerequisites
#region DSC - download prereq function
#Start-Process 'https://github.com/Azure/azure-libraries-for-net/blob/master/Samples/Asset/New-SelfSignedCertificateEx.ps1'
Invoke-WebRequest -Uri $newSelfsignedCertificateExGithubUrl -OutFile $newSelfSignedCertificateExFullPath
#endregion

#region DSC - Install Missing modules
# if the modules are not installed then
# the execution of 
#
# . .\ConfigureNode.ps1 
#
# throws errors

Install-Module -Name 'PSDscResources' -RequiredVersion 2.12.0.0 -Force -AllowClobber
Install-Module -Name 'ComputerManagementDsc' -RequiredVersion 9.1.0 -Force -AllowClobber
Install-Module -Name 'NetworkingDsc' -RequiredVersion 9.0.0 -Force -AllowClobber

#Get-Module -ListAvailable -Name 'NetworkingDsc'
#Get-Module -ListAvailable -Name 'ComputerManagementDsc'

#Get-Module -Name NetworkingDsc -ListAvailable        #not available
#Get-Module -Name ComputerManagementDsc -ListAvailable #v1.1
#endregion

#region DSC - create self signed certificates
$dscSelfSignedCerCertificateFullPath = Join-Path -Path $dscConfigFullPath -ChildPath $dscSelfSignedCerCertificateName
$dscSelfSignedPfxCertificateFullPath = Join-Path -Path $dscConfigFullPath -ChildPath $dscSelfSignedPfxCertificateName

. $newSelfSignedCertificateExFullPath

$selfSignedCertificate = @{
 Subject               = "CN=${ENV:ComputerName}"
 EKU                   = 'Document Encryption'
 KeyUsage              = 'KeyEncipherment, DataEncipherment'
 SAN                   = ${ENV:ComputerName}
 FriendlyName          = 'DSC Credential Encryption certificate'
 Exportable            = $true
 StoreLocation         = 'LocalMachine'
 KeyLength             = 2048
 ProviderName          = 'Microsoft Enhanced Cryptographic Provider v1.0'
 AlgorithmName         = 'RSA'
 SignatureAlgorithm    = 'SHA256'
}

#$selfSignedCertificate
#$selfSignedCertificate.FriendlyName

New-SelfsignedCertificateEx @selfSignedCertificate

Get-ChildItem -Path Cert:\LocalMachine\My\ | Where-Object {$_.FriendlyName -eq $($selfSignedCertificate.FriendlyName)} | Export-Certificate -Type cer -FilePath $dscSelfSignedCerCertificateFullPath -Force

# 3. export certificate (with Private key) to C:\DscPrivateKey.pfx

#Get-ChildItem -Path Cert:\LocalMachine\My\ | where{$_.Thumbprint -eq "4eeee9dca7dd5ccf70e47e46ac1128ddddbbb321"} | Export-PfxCertificate -FilePath "$env:USERPROFILE\Documents\dscSelfSignedCertificate\mypfx.pf" -Password $mypwd
Get-ChildItem -Path Cert:\LocalMachine\My\ | Where-Object {$_.FriendlyName -eq $($selfSignedCertificate.FriendlyName)} | Export-PfxCertificate -FilePath $dscSelfSignedPfxCertificateFullPath -Password $mypwd

#Import-PfxCertificate -FilePath "$env:SystemDrive\Temp\dscSelfSignedCertificate.pfx" -CertStoreLocation Cert:\LocalMachine\My -Password $mypwd
#Import-PfxCertificate -FilePath "$env:SystemDrive\Temp\dscSelfSignedCertificate.pfx" -CertStoreLocation Cert:\LocalMachine\Root -Password $mypwd

# now modify the ConfigData.psd1
# * update the CertificateFile location if needed
# * update the Thumbprint
(Get-ChildItem -Path Cert:\LocalMachine\My\ | Where-Object {$_.FriendlyName -eq $($selfSignedCertificate.FriendlyName)}).Thumbprint | clip
psedit $dscConfigDataPath
#endregion
#endregion

#region - run once - LCM - configure certificate thumbprint
# Import the configuration data
#$ConfigData = .\ConfigData.psd1
$ConfigData = Import-PowerShellDataFile -Path $dscConfigDataPath
#$ConfigData.AllNodes

. .\ConfigureLCM.ps1

# Generate the MOF file for LCM configuration
ConfigureLCM -ConfigurationData $ConfigData -OutputPath $(Join-Path -Path $dscConfigFullPath -ChildPath 'LCM')

# Apply LCM configuration
Set-DscLocalConfigurationManager -Path $(Join-Path -Path $dscConfigFullPath -ChildPath 'LCM') -Verbose

# check LCM configuration
# for the CIM sessions to work the WIMrm should be configured first
Get-DscLocalConfigurationManager -CimSession localhost
#endregion

#region - run anytime - Import Configuration Data
$ConfigData = Import-PowerShellDataFile -Path $dscConfigDataPath
#$ConfigData.AllNodes
#psedit $dscConfigDataPath

. .\ConfigureNode.ps1

# Generate the MOF files and apply the configuration
# Credentials are used within the configuration file - hence SelfSigned certificate is needed as there is no Active Directory Certification Services
NodeInitialConfig -ConfigurationData $ConfigData -AdminCredential $AdminCredential -OutputPath $dscConfigFullPath -Verbose

Start-DscConfiguration -Path $dscConfigFullPath -Wait -Verbose -Force
#endregion
#endregion