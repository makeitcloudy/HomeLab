#region - always run - initialize variables
#region initialize variables - DSC
$drive                              = 'Z:'
$dscConfigFolder                    = 'DSCConfigs'
# DSC mof files full path
$dscConfigFullPath                  = Join-Path -Path $drive -ChildPath $dscConfigFolder

# DSC configuration location
$dscConfigPath                      = "$env:USERPROFILE\Documents\dsc_config_domainControllers"
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


Set-Location -Path $dscConfigPath
#endregion


#region DSC - prereq - localhost - modules for the DSC to work
# 2024 TODO:
# * add commandlets which search the PSgallery for the DSC

#region DSC - prereq - localhost - OPTION 1 - install with function
$modules = @{
    'ActiveDirectoryDsc'    = '6.4.0'
    'NetworkingDsc'         = '9.0.0'
    'ComputerManagementDsc' = '9.0.0'
}

# AutomatedLab - contains functions which are crucial for the whole logic to work properly
# Install-Modules is one of the functions within the AutomatedLab module

Install-Modules -modules $modules
#endregion

#region DSC - prereq - localhost - OPTION 2 - install manually
Install-Module -Name ActiveDirectoryDsc -RequiredVersion '6.4.0' -Repository PSGallery -Force -AllowClobber
Install-Module -Name NetworkingDsc -RequiredVersion '9.0.0'-Repository PSGallery -Force -AllowClobber
Install-Module -Name ComputerManagementDsc -RequiredVersion '9.0.0' -Repository PSGallery -Force -AllowClobber
#endregion
#endregion

#region DSC - prereq - remote node - modules for the DSC to work
#region DSC - prereq - remote node - OPTION 1 - download from PSGallery on the target nodes
# the modules should be installed locally as well as on the target servers
#execute this on the domain controllers

Install-Module -Name ActiveDirectoryDsc -RequiredVersion '6.4.0' -Repository PSGallery -Force
Install-Module -Name NetworkingDsc -RequiredVersion '9.0.0' -Repository PSGallery -Force
Install-Module -Name ComputerManagementDsc -RequiredVersion '9.0.0' -Repository PSGallery -Force
#endregion

#region DSC - prereq - remote node - OPTION 2 - copy modules to the destination nodes
# 2024.06 TODO:
# * make use of the CopyDSCResource functions
# * integrate functions with AutomatedLab module

#endregion
#endregion

#region DSC - LCM 
# now modify the ConfigData.psd1
# * update the CertificateFile location if needed
# * update the Thumbprint
(Get-ChildItem -Path Cert:\LocalMachine\My\ | Where-Object {$_.FriendlyName -eq $($selfSignedCertificate.FriendlyName)}).Thumbprint | clip
psedit $dscConfigDataPath

#region - LCM
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
#endregion

#endregion

# region DSC - configure
## WinRM - test

$AdminUsername                      = "administrator"
$AdminPassword                      = ConvertTo-SecureString "Password1$" -AsPlainText -Force
$AdminCredential                    = New-Object System.Management.Automation.PSCredential ($AdminUsername, $AdminPassword)

$dc01 = New-PSSession -ComputerName '10.2.134.201' -Name 'dc01_core' -Credential $AdminCredential
$dc02 = New-PSSession -ComputerName '10.2.134.202' -Name 'dc02_core' -Credential $AdminCredential

Invoke-Command -Session $dc01 -ScriptBlock {$env:computername}
Invoke-Command -Session $dc02 -ScriptBlock {$env:computername}

HADC -ConfigurationData C:\Users\labuser\Documents\dsc_configuration\ad\ConfigurationData.psd1 `
    -SafemodeAdministratorCred (Get-Credential -UserName Administrator -Message "Enter Domain Safe Mode Administrator Password") `
    -DomainAdministratorCred (Get-Credential -UserName lab\administrator -Message "Enter Domain Administrator Credential") `
    -ADUserCred (Get-Credential -UserName Test.User -Message "Enter AD User Credential")

# Make sure that LCM is set to continue configuration after reboot.
Set-DSCLocalConfigurationManager -Path .\HADC –Verbose
#endregion

#region DSC
Find-DSCResource | Where-Object {$_.Name -like "ActiveDirectory"}

.\HADC.ps1

Start-DscConfiguration -Path "$env:USERPROFILE\Documents\dsc_configuration\ad\HADC" -Wait -Verbose -Force

#endregion

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force