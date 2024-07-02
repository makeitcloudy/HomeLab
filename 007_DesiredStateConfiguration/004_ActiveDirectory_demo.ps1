
# 1. create folder 004_ActiveDirectory
# 2. download to the abovementioned directory ConfigData.psd1 and ConfigureAD.ps1
# 3. download 004_ActiveDirectory_demo.ps1 to $env:USERPROFILE\Documents folder

# https://www.cloudninja.nu/post/2021/02/using-azure-dsc-to-configure-a-new-active-directory-domain/

# https://medium.com/@emilfabrice/deploy-active-directory-with-dsc-c06bd8bf3a64
# https://gist.githubusercontent.com/fabricesemti80/a776b85767df3453f253a5a773437214/raw/3f685583c3563b1b7f376d366730529590ae41a7/New-ADDSC.ps1
# https://gist.githubusercontent.com/fabricesemti80/a776b85767df3453f253a5a773437214/raw/6b0dd9a340e3d1c5c898e6b5e04e90e427fd6498/New-ADDSC.psm1

# TARGET NODE - NETBIOS
# https://techbits.io/the-netbios-name-ad-is-already-in-use/

# netbios settings - change from enabled to disabled - windows server 2022
# ipconfig /all | findstr "NetBIOS"
# wmic NICConfig where TcpipNetbiosOptions=0 call SetTcpipNetbios 2



#region - initialize variables - DSC structure
$dscCodeRepoUrl                            = 'https://raw.githubusercontent.com/makeitcloudy/AutomatedLab/feature/007_DesiredStateConfiguration'
$dsc_004_ActiveDirectory_FolderName        = '004_ActiveDirectory'
$dsc_004_ActiveDirectory_FileName          = '004_ActiveDirectory_demo.ps1'

$dscCodeRepo_004_ActiveDirectory_url       = $dscCodeRepoUrl,$dsc_004_ActiveDirectory_FolderName -join '/'

#$downloadsFolder                           = $("$env:USERPROFILE\Downloads")
$certificate_FolderName                    = '__certificate'

$dscSelfSignedCertificateName              = 'dscSelfSignedCertificate'
#$dscSelfSignedCerCertificateName           = $dscSelfSignedCertificateName,'cer' -join '.'
$dscSelfSignedPfxCertificateName           = $dscSelfSignedCertificateName,'pfx' -join '.'

$selfSignedCertificate                     = @{
    Subject                                = "CN=${ENV:ComputerName}"
    EKU                                    = 'Document Encryption'
    KeyUsage                               = 'KeyEncipherment, DataEncipherment'
    SAN                                    = ${ENV:ComputerName}
    FriendlyName                           = 'DSC Credential Encryption certificate'
    Exportable                             = $true
    StoreLocation                          = 'LocalMachine'
    KeyLength                              = 2048
    ProviderName                           = 'Microsoft Enhanced Cryptographic Provider v1.0'
    AlgorithmName                          = 'RSA'
    SignatureAlgorithm                     = 'SHA256'
}

$dscConfig_FolderName                      = 'dscConfig'
$dscOutput_FolderName                      = '__output'
$lcm_FolderName                            = 'LCM'

$nodeName                                  = '_w10mgmt'

$configData_psd1_fileName                  = 'ConfigData.psd1'
#$configureLCM_ps1_fileName                 = 'ConfigureLCM.ps1'
$configureNode_ps1_fileName                = 'ConfigureAD.ps1'

$configData_psd1_url                       = $dscCodeRepo_004_ActiveDirectory_url,$configData_psd1_fileName -join '/'
#$configureLCM_ps1_url                      = $dscCodeRepo_004_ActiveDirectory_url,$configureLCM_ps1_fileName -join '/'
$configureNode_ps1_url                     = $dscCodeRepo_004_ActiveDirectory_url,$configureNode_ps1_fileName -join '/'

$dscConfigDirectoryPath                    = Join-Path -Path "$env:SYSTEMDRIVE" -childPath $dscConfig_FolderName
$dscConfigCertificateDirectoryPath         = Join-Path -Path $dscConfigDirectoryPath -ChildPath $certificate_FolderName
$dscConfigOutputDirectoryPath              = Join-Path -Path $dscConfigDirectoryPath -ChildPath $dscOutput_FolderName
$dscConfigNodeDirectoryPath                = Join-Path -Path $dscConfigDirectoryPath -ChildPath $nodeName
$dscConfig_004_ActiveDirectory_Path        = Join-Path -Path $dscConfigNodeDirectoryPath -ChildPath $dsc_004_ActiveDirectory_FolderName

$configData_psd1_FullPath                  = Join-Path -Path $dscConfig_004_ActiveDirectory_Path -ChildPath $configData_psd1_fileName
#$configureLCM_ps1_FullPath                 = Join-Path -Path $dscConfig_004_ActiveDirectory_Path -ChildPath $configureLCM_ps1_fileName 
$configureNode_ps1_FullPath                = Join-Path -Path $dscConfig_004_ActiveDirectory_Path -ChildPath $configureNode_ps1_fileName

#$newSelfSignedCertificateExFullPath        = Join-Path -Path $dscConfigCertificateDirectoryPath -ChildPath $newSelfSignedCertificateExFileName
#$dscSelfSignedCerCertificateFullPath       = Join-Path -Path $dscConfigCertificateDirectoryPath -ChildPath $dscSelfSignedCerCertificateName
$dscSelfSignedPfxCertificateFullPath       = Join-Path -Path $dscConfigCertificateDirectoryPath -ChildPath $dscSelfSignedPfxCertificateName

$dscConfigLCMDirectoryPath                 = Join-Path -Path $dscConfigOutputDirectoryPath -ChildPath $lcm_FolderName
#endregion

Set-Location -Path $dscConfigDirectoryPath

#region initialize credentials
$AdminUsername                 = "Administrator"
$AdminPassword                 = ConvertTo-SecureString "Password1$" -AsPlainText -Force
$AdminCredential               = New-Object System.Management.Automation.PSCredential ($AdminUsername, $AdminPassword)

$SafemodeAdministratorName     = 'Administrator'
$SafemodeAdministratorPassword = ConvertTo-SecureString "Password1$" -AsPlainText -Force
$SafemodeAdministratorCred     = New-Object System.Management.Automation.PSCredential ($SafemodeAdministratorName, $SafemodeAdministratorPassword)

#https://community.spiceworks.com/t/dns-issue-i-have-to-enter-fqdn-to-join-domain-but-why/636506/10
$domainAdministratorName       = 'lab.local\Administrator'
$domainAdministratorPassword   = ConvertTo-SecureString "Password1$" -AsPlainText -Force
$domainAdministratorCred       = New-Object System.Management.Automation.PSCredential ($domainAdministratorName, $domainAdministratorPassword)

$adUserName                    = 'Test.User'
$adUserPassword                = ConvertTo-SecureString "Password1$" -AsPlainText -Force
$adUserCredential              = New-Object System.Management.Automation.PSCredential ($adUserName, $adUserPassword)

#self signed certificate password
$mypwd                         = ConvertTo-SecureString -String "Password1$" -Force -AsPlainText
#endregion

#region find DSC resource - helper commands to find DSC Resources
#https://learn.microsoft.com/en-us/powershell/dsc/configurations/reboot-a-node?view=dsc-1.1
Get-Module -Name ComputerManagementDsc -ListAvailable
Get-DscResource -Module ComputerManagementDsc
Get-DscResource PendingReboot -Syntax

Find-DscResource -tag dsc
Find-DscResource -Filter "Firewall"
Find-DscResource -Filter "xPendingReboot"
Find-DscResource -Name Firewall #available in ModuleName - NetworkingDsc

Get-Module -Name PSDscResources -ListAvailable
Get-Module -Name PSDesiredStateConfiguration -ListAvailable
Get-Module -Name NetworkingDsc -ListAvailable
Get-Module -Name ComputerManagementDsc -ListAvailable
Get-Module -Name ActiveDirectoryDsc -ListAvailable
Get-Module -Name FirewallDsc -ListAvailable

$moduleName = 'NetworkingDsc'
Find-Module $moduleName | Tee-Object -Variable m
$m | Format-list Author,PublishedDate,ProjectUri,Description
$m.AdditionalMetadata.DscResources
Start-Process $m.ProjectUri
Start-Process ("https://www.powershellgallery.com/packages?q=",$m.Name -join '')

Find-Module -Name $moduleName -AllVersions

Get-DscResource -Module NetworkingDsc #show available resources
Get-DscResource DnsServerAddress -Syntax
Get-DscResource Computer -Syntax

Get-DscResource IPAddress -Syntax
Get-DscResource IPAddressOption -Syntax
Get-DscResource DefaultGatewayAddress -Syntax
Get-DscResource Netbios -Syntax
Get-DscResource HostsFile -Syntax
Get-DscResource NetIPInterface -Syntax

Get-DscResource Firewall -Syntax
Get-DscResource DnsClientGlobalSetting -Syntax
Get-DscResource DnsConnectionSuffix -Syntax
#endregion

#region downloads the configuration
Invoke-WebRequest -Uri $configData_psd1_url -OutFile $configData_psd1_FullPath
Invoke-WebRequest -Uri $configureNode_ps1_url -OutFile $configureNode_ps1_FullPath

#endregion

#region DSC - prereq - localhost - OPTION 1 - install with function
$modules = @{
    'ActiveDirectoryDsc'    = '6.4.0'
    'NetworkingDsc'         = '9.0.0'
    'ComputerManagementDsc' = '9.1.0'
}

# AutomatedLab - contains functions which are crucial for the whole logic to work properly
# Install-Modules is one of the functions within the AutomatedLab module

Install-Modules -modules $modules
#endregion

#region DSC - prereq - localhost - OPTION 2 - install manually
Install-Module -Name ActiveDirectoryDsc -RequiredVersion '6.4.0' -Repository PSGallery -Force -AllowClobber
Install-Module -Name NetworkingDsc -RequiredVersion '9.0.0'-Repository PSGallery -Force -AllowClobber
Install-Module -Name ComputerManagementDsc -RequiredVersion '9.1.0' -Repository PSGallery -Force -AllowClobber

Get-Module -Name NetworkingDsc -ListAvailable
Get-Module -Name ComputerManagementDsc -ListAvailable
Get-Module -Name ActiveDirectoryDsc -ListAvailable

$moduleName = 'ComputerManagementDsc'
Get-DscResource -Module $moduleName
Find-Module -Name $moduleName -AllVersions
#Get-Command -Noun Module
#Uninstall-Module -Name $moduleName -RequiredVersion 9.0.0
#Get-Module -Name $moduleName -ListAvailable

#endregion
#endregion

#region DSC - prereq - remote node - run 4 steps in one go
#region DSC - prereq - remote node - check winRM connectivity
Get-PSSession |Remove-PSSession

Get-Item WSMan:\localhost\Client\TrustedHosts
#Set-Item WSMan:\localhost\Client\TrustedHosts -Concatenate -Value '10.2.134.201'
$dc01 = New-PSSession -ComputerName '10.2.134.201' -Name 'dc01_core' -Credential $AdminCredential
$dc02 = New-PSSession -ComputerName '10.2.134.202' -Name 'dc02_core' -Credential $AdminCredential

# no DNS entries on your network device / DNS server
#$dc01 = New-PSSession -ComputerName 'dc01' -Name 'dc01_core' -Credential $AdminCredential
#$dc02 = New-PSSession -ComputerName 'dc02' -Name 'dc02_core' -Credential $AdminCredential

Invoke-Command -Session $dc01,$dc02 -ScriptBlock {$env:computername}
#endregion

#region DSC - prereq - remote node - create folder structure for DSC Configuration
Invoke-Command -Session $dc01,$dc02 -ScriptBlock {New-Item -Path ${using:dscConfigDirectoryPath} -ItemType Directory}
Invoke-Command -Session $dc01,$dc02 -ScriptBlock {New-Item -Path ${using:dscConfigCertificateDirectoryPath} -ItemType Directory}
Invoke-Command -Session $dc01,$dc02 -ScriptBlock {Test-Path -Path ${using:dscConfigCertificateDirectoryPath}}
#endregion

#region DSC - prereq - remote node - copy certificate to the target node
#check if the certificate is in place
Test-Path -Path $dscSelfSignedPfxCertificateFullPath

Copy-Item -ToSession $dc01 -Path $dscSelfSignedPfxCertificateFullPath -Destination $dscSelfSignedPfxCertificateFullPath
Copy-Item -ToSession $dc02 -Path $dscSelfSignedPfxCertificateFullPath -Destination $dscSelfSignedPfxCertificateFullPath
#endregion

#region DSC - prereq - remote node - import pfx certificate
Invoke-Command -Session $dc01,$dc02 -ScriptBlock {Import-PfxCertificate -FilePath ${using:dscSelfSignedPfxCertificateFullPath} -CertStoreLocation Cert:\LocalMachine\My -Password ${using:mypwd}}
Invoke-Command -Session $dc01,$dc02 -ScriptBlock {Import-PfxCertificate -FilePath ${using:dscSelfSignedPfxCertificateFullPath} -CertStoreLocation Cert:\LocalMachine\Root -Password ${using:mypwd}}
#Import-PfxCertificate -FilePath "$env:SystemDrive\Temp\dscSelfSignedCertificate.pfx" -CertStoreLocation Cert:\LocalMachine\My -Password $mypwd
#Import-PfxCertificate -FilePath "$env:SystemDrive\Temp\dscSelfSignedCertificate.pfx" -CertStoreLocation Cert:\LocalMachine\Root -Password $mypwd
#endregion
#endregion

#region DSC - prereq - remote node - modules for the DSC to work - pick OPTION 0
#region DSC - prereq - remote node - OPTION 0 - invoke the installation remotelly via winRM session
Invoke-Command -Session $dc01,$dc02 -ScriptBlock {Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force}
#Invoke-Command -Session $dc02 -ScriptBlock {Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force}

Invoke-Command -Session $dc01,$dc02 -ScriptBlock {
    Install-Module -Name ActiveDirectoryDsc -RequiredVersion '6.4.0' -Repository PSGallery -Force
    Install-Module -Name NetworkingDsc -RequiredVersion '9.0.0' -Repository PSGallery -Force
    Install-Module -Name ComputerManagementDsc -RequiredVersion '9.1.0' -Repository PSGallery -Force
}

Invoke-Command -Session $dc01,$dc02 -ScriptBlock {
    Get-Module -Name NetworkingDsc -ListAvailable
    Get-Module -Name ComputerManagementDsc -ListAvailable
    Get-Module -Name ActiveDirectoryDsc -ListAvailable
}
#endregion

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
psedit $configData_psd1_FullPath

#region - NOT NEEDED HERE - LCM - the LCM is configured internally within the configuration - configure certificate thumbprint
# Import the configuration data
#$ConfigData = .\ConfigData.psd1
$ConfigData = Import-PowerShellDataFile -Path $configData_psd1_FullPath

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

$ConfigData = Import-PowerShellDataFile -Path $configData_psd1_FullPath
#Write-Output $configData_psd1_FullPath
#$ConfigData.AllNodes
. $configureNode_ps1_FullPath
psedit $configureNode_ps1_FullPath


#ConfigureAD -ConfigurationData $configData_psd1_FullPath `
#    -SafemodeAdministratorCred (Get-Credential -UserName Administrator -Message "Enter Domain Safe Mode Administrator Password") `
#    -DomainAdministratorCred (Get-Credential -UserName lab\administrator -Message "Enter Domain Administrator Credential") `
#    -ADUserCred (Get-Credential -UserName Test.User -Message "Enter AD User Credential") `
#    -OutPutPath $dscConfigOutputDirectoryPath

ConfigureAD -ConfigurationData $ConfigData `
    -ManagementNodeIPv4Address '10.2.134.239' `
    -SafemodeAdministratorCred $SafemodeAdministratorCred `
    -DomainAdministratorCred $domainAdministratorCred `
    -ADUserCred $adUserCredential -OutputPath $dscConfigOutputDirectoryPath -PsDscRunAsCredential $AdminCredential

ConfigureAD -ConfigurationData $ConfigData `
    -ManagementNodeIPv4Address '10.2.134.239' `
    -SafemodeAdministratorCred $SafemodeAdministratorCred `
    -DomainAdministratorCred $domainAdministratorCred `
    -ADUserCred $adUserCredential -OutputPath $dscConfigOutputDirectoryPath -PsDscRunAsCredential $domainAdministratorCred -Verbose

# Make sure that LCM is set to continue configuration after reboot.
#Set-DSCLocalConfigurationManager -Path .\HADC –Verbose -Credential $AdminCredential
Set-DscLocalConfigurationManager -Path $dscConfigOutputDirectoryPath -Verbose -Credential $AdminCredential
#Set-DscLocalConfigurationManager -Path $dscConfigOutputDirectoryPath -Verbose -Credential (Get-Credential -UserName '.\administrator' -Message 'x')
#Get-Item WSMan:\localhost\Client\TrustedHosts


Get-PSSession | Remove-PSSession
$dc01 = New-PSSession -ComputerName '10.2.134.201' -Name 'dc01_core' -Credential (Get-Credential -UserName 'dc01\administrator' -Message 'x')
$dc02 = New-PSSession -ComputerName '10.2.134.202' -Name 'dc02_core' -Credential (Get-Credential -UserName 'dc02\administrator' -Message 'x')

Invoke-command -Session $dc01,$dc02 -ScriptBlock {Get-DscConfigurationStatus -CimSession localhost} 

# Test-NetConnection -ComputerName '10.2.134.201' -Port 5985 # port is opened
# Invoke-command -ComputerName '10.2.134.201' -ScriptBlock {$ENV:ComputerName} -Credential $AdminCredential - does not work anymore

#Invoke-Command -Session $dc01 -ScriptBlock {Get-DscLocalConfigurationManager -CimSession localhost}
#Invoke-Command -Session $dc02 -ScriptBlock {Get-DscLocalConfigurationManager -CimSession localhost}

#Invoke-Command -Session $dc01,$dc02 -ScriptBlock {Get-DscLocalConfigurationManager -CimSession localhost}
#Invoke-Command -Session $dc01,$dc02 -ScriptBlock {Get-DscConfigurationStatus}
#Invoke-Command -Session $dc01,$dc02 -ScriptBlock {Stop-DscConfiguration -Force}

# Start DSC Configuration
#Start-DscConfiguration -Path C:\Users\labuser\Documents\dsc_config_domainControllers\HADC -Verbose -Wait -Force -Credential $AdminCredential

#run this twice
# 1st. to execute the code until reboot (ip, netbios, rename)
# 2nd. to run the code which needs to proceed after the reboot
Start-DscConfiguration -Path $dscConfigOutputDirectoryPath -Verbose -Wait -Force -Credential $AdminCredential

Start-DscConfiguration -Path $dscConfigOutputDirectoryPath -Verbose -Wait -Force -Credential $domainAdministratorCred
#endregion

#region DSC
Find-DSCResource | Where-Object {$_.Name -like "ActiveDirectory"}
#endregion

#endregion

#Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Enter-PSSession -ComputerName '10.2.134.202' -Credential $AdminCredential
Enter-PSSession -ComputerName 'dc01' -Credential $AdminCredential
Invoke-Command -ComputerName '10.2.134.202' -ScriptBlock {$ENV:ComputerName} -Credential $AdminCredential
#Get-DscLocalConfigurationManager -CimSession '10.2.134.202' 
Get-Item WSMan:\localhost\Client\TrustedHosts