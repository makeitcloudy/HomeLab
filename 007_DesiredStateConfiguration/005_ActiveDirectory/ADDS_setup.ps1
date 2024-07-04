<#
.SYNOPSIS
Script to setup Active  Directory

.DESCRIPTION
    This script is intended to set up a functioning AD forest with 1x root domain controller and one or more additional domain controllers

    The script uses - for now - a  self-signed cert to encryot the password, the thumbprint of this should be supplied on the machine.


.NOTES
    (Use the `Create-SelfSignedCert` function in the module to generate a cert if this is needed)
.LINK
    https://codeandkeep.com/Dsc-Install-AD-Forest/
    https://codeandkeep.com/Dsc-Encrypting-Credentials/
    https://github.com/dsccommunity/ActiveDirectoryDsc/wiki/ADDomain
    https://github.com/dsccommunity/ActiveDirectoryDsc/wiki/WaitForADDomain
    https://github.com/dsccommunity/ActiveDirectoryDsc/wiki/ADOrganizationalUnit
    https://github.com/dsccommunity/NetworkingDsc
    https://github.com/dsccommunity/NetworkingDsc/wiki
    https://github.com/dsccommunity/NetworkingDsc/wiki/IPAddress
    https://github.com/dsccommunity/NetworkingDsc/wiki/DnsServerAddress
.EXAMPLE

        # if (-not $cred){
        #     $cred = (Get-Credential -Message "Enter new domain's credential")
        # }


        # # install domain - using existing cert
        # & "\\tsclient\C\PROJECTS\dsc\SS.INFRA.DSC\NewAD\New-ADDSC.ps1"`
        # -domainCred $cred `
        # -certThumbprint "67A454BF08E151ACB012108D2EC4094258A4F494"

#>


[CmdletBinding()]
param (
    # Store the current directory path
    #[Parameter(Mandatory = $false)] [string]
    #$CurrentPath = (Split-Path -Parent $PSCommandPath),
    # Required modules
    
    #[Parameter(Position = 0, Mandatory = $true)]
    #[String]$computerName = 'dc01'

    #[Parameter(Mandatory = $false)]
    #$modules = @{
    #    'ActiveDirectoryDsc'    = '6.4.0'
    #    'NetworkingDsc'         = '9.0.0'
    #    'ComputerManagementDsc' = '9.1.0'
    #},
    
    # If module installation is also needed
    #[Parameter(Mandatory = $false)] [switch]
    #$preReq,
    
    # DSC encryption certificate
    #[Parameter(Mandatory = $false)] [string]
    #$certThumbprint,
    
    # Domain admin credential (the local admin credential will be set to this one!)
    #! user user@domain.com for the user
    #[Parameter(Mandatory = $false)] [pscredential]
    #$domainCred,
    
    # The certificate file generated by 'Create-SelfSignedCert'
    #[Parameter(Mandatory = $false)] [string]
    #$certFilePath = 'C:\dsc\certificate\dscSelfSignedCertificate.cer'
)

BEGIN
{

#region 1. DSC - Initialize Variables
#region Initialize Variables - Missing Modules
$modules = @{
    'ActiveDirectoryDsc'                    = '6.4.0'
    'NetworkingDsc'                         = '9.0.0'
    'ComputerManagementDsc'                 = '9.1.0'
}
#endregion

#region Initialize Variables - Credentials
#https://community.spiceworks.com/t/dns-issue-i-have-to-enter-fqdn-to-join-domain-but-why/636506/10

$AdministratorUserName                      = 'Administrator'
$AdministratorPassword                      = 'Password1$'
$AdministratorPasswordSecureString          = ConvertTo-SecureString $AdministratorPassword -AsPlainText -Force
$AdministratorCred                          = New-Object System.Management.Automation.PSCredential ($AdministratorUserName, $AdministratorPasswordSecureString)

$SafemodeAdministratorUserName             = 'Administrator'
$SafemodeAdministratorPassword             = 'Password1$'
$SafemodeAdministratorPasswordSecureString = ConvertTo-SecureString $SafemodeAdministratorPassword -AsPlainText -Force
$SafemodeAdministratorCred                 = New-Object System.Management.Automation.PSCredential ($SafemodeAdministratorUserName, $SafemodeAdministratorPasswordSecureString)


$domainAdministratorUserName               = 'lab.local\Administrator'
$domainAdministratorPassword               = 'Password1$'
$domainAdministratorPasswordSecureString   = ConvertTo-SecureString $domainAdministratorPassword -AsPlainText -Force
$domainAdministratorCred                   = New-Object System.Management.Automation.PSCredential ($domainAdministratorUserName, $domainAdministratorPasswordSecureString)

#if (-not $AdministratorCred){
#    $AdministratorCred = (Get-Credential -Message "Enter new domain's credential")
#}
#endregion

#region Initialize Variables - Folder structure
# each time you modify the folder structure ammend the $arrayFolderStructure variable accordingly

$dsc_FolderName                            = 'dsc'             #C:\dsc\

$config_FolderName                         = 'config'          #C:\dsc\config\ - # it stores the DSC configuration
$localhost_FolderName                      = 'localhost'       #C:\dsc\config\localhost\ - # it stores the configurations run locally on the localhost (Node)

$certificate_FolderName                    = 'certificate'     #C:\dsc\certificate\ - # it stores self signed certificate used to secure DSC credentials
$function_FolderName                       = 'function'        #C:\dsc\function\
$module_FolderName                         = 'module'          #C:\dsc\module\ - # it stores the Module which contains various functions

$output_FolderName                         = '_output'         #C:\dsc\_output\ - # it stores the results of the DSC compilation
$LCM_FolderName                            = 'LCM'             #C:\dsc\_output\LCM\

$ADDS_FolderName                           = 'ActiveDirectory' #C:\dsc\config\localhost\ActiveDirectory\ - # it contains the configurations of ActiveDirectory


#C:\dsc\
$dsc_DirectoryPath                         = Join-Path -Path "$env:SYSTEMDRIVE" -childPath $dsc_FolderName

#C:\dsc\config\
$dscConfig_DirectoryPath                   = Join-Path -Path $dsc_DirectoryPath -childPath $config_FolderName
#C:\dsc\config\localhost\
$dscConfigLocahost_DirectoryPath           = Join-Path -Path $dscConfig_DirectoryPath -ChildPath $localhost_FolderName
#C:\dsc\config\localhost\ActiveDirectory\
$dscConfigLocalhostADDS_DirectoryPath      = Join-Path -Path $dscConfigLocahost_DirectoryPath -ChildPath $ADDS_FolderName

#C:\dsc\certificate\
$dscCertificate_DirectoryPath              = Join-Path -Path $dsc_DirectoryPath -ChildPath $certificate_FolderName

#C:\dsc\function\
$dscFunction_DirectoryPath                 = Join-Path -Path $dsc_DirectoryPath -ChildPath $function_FolderName

#C:\dsc\module\
$dscModule_DirectoryPath                   = Join-Path -Path $dsc_DirectoryPath -ChildPath $module_FolderName

#C:\dsc\_output\
$dscOutput_DirectoryPath                   = Join-Path -Path $dsc_DirectoryPath -ChildPath $output_FolderName
#C:\dsc\_output\ActiveDirectory
$dscOutputADDS_DirectoryPath               = Join-Path -Path $dscOutput_DirectoryPath -ChildPath $ADDS_FolderName
#C:\dsc\_output\LCM
$dscOutputLCM_DirectoryPath               = Join-Path -Path $dscOutput_DirectoryPath -ChildPath $LCM_FolderName
#endregion

#region Initialize Variables - Function - C:\dsc\function\New-SelfSignedCertificateEx.ps1
# it contains the Function to prepare the self signed certificate
$newSelfSignedCertificateEx_FileName       = 'New-SelfSignedCertificateEx.ps1'
$newSelfsignedCertificateEx_GithubUrl      = 'https://raw.githubusercontent.com/Azure/azure-libraries-for-net/master/Samples/Asset',$newSelfSignedCertificateEx_FileName -join '/'

$dscFunction_NewSelfSignedCertificateEx_FullPath = Join-Path -Path $dscFunction_DirectoryPath -ChildPath $newSelfSignedCertificateEx_FileName

$selfSignedCertificateParams               = @{
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

$selfSignedCertificatePrivateKeyPassword              = 'Password1$'
$selfSignedCertificatePrivateKeyPasswordSecureString  = ConvertTo-SecureString -String $selfSignedCertificatePrivateKeyPassword -Force -AsPlainText
#endregion

#region Initialize Variables - Self Signed Certificate
$dscSelfSignedCertificate_FileName         = 'dscSelfSignedCertificate'
$dscSelfSignedCerCertificate_FileName      = $dscSelfSignedCertificate_FileName,'cer' -join '.'
$dscSelfSignedPfxCertificate_FileName      = $dscSelfSignedCertificate_FileName,'pfx' -join '.'

$dscSelfSignedCerCertificate_FullPath      = Join-Path -Path $dscCertificate_DirectoryPath -ChildPath $dscSelfSignedCerCertificate_FileName
$dscSelfSignedPfxCertificate_FullPath      = Join-Path -Path $dscCertificate_DirectoryPath -ChildPath $dscSelfSignedPfxCertificate_FileName
#endregion

#region Initialize Variables - Configuration - ADDS
$dscConfigLocalhostADDS_ps1_FileName       = 'ADDS_configuration.ps1'

$dscConfigLocalhostADDS_GithubUrl          = 'https://raw.githubusercontent.com/makeitcloudy/AutomatedLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory'
$dscConfigLocalhostADDS_ps1_GithubUrl      = $dscConfigLocalhostADDS_GithubUrl,$dscConfigLocalhostADDS_ps1_FileName -join '/'

#C:\dsc\config\localhost\ActiveDirectory\New-ADDSC.ps1
$dscConfigLocalhostADDS_ps1_FullPath       = Join-Path -Path $dscConfigLocalhostADDS_DirectoryPath -ChildPath $dscConfigLocalhostADDS_ps1_FileName
#endregion

#endregion

#region 2. DSC - Prepare Prerequisites

#region 2.1. Create Directory Structure
$arrayFolderStructure = @(
    $dsc_DirectoryPath,
    $dscConfig_DirectoryPath,
    $dscConfigLocahost_DirectoryPath,
    $dscConfigLocalhostADDS_DirectoryPath
    $dscCertificate_DirectoryPath,
    $dscFunction_DirectoryPath,
    $dscModule_DirectoryPath,
    $dscOutput_DirectoryPath,
    $dscOutputADDS_DirectoryPath,
    $dscOutputLCM_DirectoryPath
)

$arrayFolderStructure.ForEach({
    if(!(Test-Path -Path $_)){
        try {
            New-Item -Path $_ -ItemType Directory -Force
        }
        catch {
            Write-Error "Something went wrong"
        }
    }
    else {
        Write-Output "$_ - already exist"
    }
})

#endregion

#region 2.2. Download code from from Github
# Function: SelfSigned Certificate
#https://raw.githubusercontent.com/Azure/azure-libraries-for-net/master/Samples/Asset/New-SelfSignedCertificateEx.ps1
Invoke-WebRequest -Uri $newSelfsignedCertificateEx_GithubUrl -OutFile $dscFunction_NewSelfSignedCertificateEx_FullPath -Verbose

# DSC Configuration: - localhost ADDS
#configuration_ADDS.ps1
#https://raw.githubusercontent.com/makeitcloudy/AutomatedLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory/configuration_ADDS.ps1
Invoke-WebRequest -Uri $dscConfigLocalhostADDS_ps1_GithubUrl -OutFile $dscConfigLocalhostADDS_ps1_FullPath -Verbose

#New-ADDSC.psm1
#Invoke-WebRequest -Uri $dscConfigLocalhostADDS_psm1_GithubUrl -OutFile $dscConfigLocalhostADDS_psm1_FullPath -Verbose
#endregion

#region 2.3. Self Signed Certificate - Generate and Export to CER & PFX
if (!(Get-ChildItem -Path Cert:\LocalMachine\My\ | Where-Object {$_.FriendlyName -eq $($selfSignedCertificateParams.FriendlyName)})){
# Load the function into memory
    . $dscFunction_NewSelfSignedCertificateEx_FullPath
    try {
        New-SelfsignedCertificateEx @selfSignedCertificateParams
    }
    catch {

    }
}
else {
    Write-Output "Certificate already exist - Friendly Name: $($selfSignedCertificateParams.FriendlyName)"
}

# Exporting certificate to CER and PFX
if(!(Test-Path -Path $dscSelfSignedCerCertificate_FullPath)){
    try {
        Get-ChildItem -Path Cert:\LocalMachine\My\ | Where-Object {$_.FriendlyName -eq $($selfSignedCertificateParams.FriendlyName)} | Export-Certificate -Type cer -FilePath $dscSelfSignedCerCertificate_FullPath -Force
    }
    catch {

    }
}
else {
    Write-Output "Certificate CER File already exist - Path: $($dscSelfSignedCerCertificate_FullPath)"
}

if(!(Test-Path -Path $dscSelfSignedPfxCertificate_FullPath)){
    try {
        Get-ChildItem -Path Cert:\LocalMachine\My\ | Where-Object {$_.FriendlyName -eq $($selfSignedCertificateParams.FriendlyName)} | Export-PfxCertificate -FilePath $dscSelfSignedPfxCertificate_FullPath -Password $selfSignedCertificatePrivateKeyPasswordSecureString
    }
    catch {

    }    
}
else {
    Write-Output "Certificate PFX File already exist - Path: $($dscSelfSignedPfxCertificate_FullPath)"
}
#endregion

#region 2.4. Install Missing Modules - TODO:
#region AUTOMATYCZNIE
# AutomatedLab - contains functions which are crucial for the whole logic to work properly
# Install-Modules is one of the functions within the AutomatedLab module

Install-Modules -modules $modules
#endregion

#region MANUALNIE
### wywolanie manualne

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force
Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force

Install-Module -Name 'PSDscResources' -RequiredVersion 2.12.0.0 -Force -AllowClobber
Install-Module -Name 'ActiveDirectoryDsc' -RequiredVersion 6.4.0 -Force -AllowClobber
Install-Module -Name 'ComputerManagementDsc' -RequiredVersion 9.1.0 -Force -AllowClobber
Install-Module -Name 'NetworkingDsc' -RequiredVersion 9.0.0 -Force -AllowClobber
#endregion
#endregion
#endregion

#region 3. DSC - LCM - Self Signed CertificateCertificate - Thumbprint
$selfSignedCertificateThumbprint = (Get-ChildItem -Path Cert:\LocalMachine\My\ | Where-Object {$_.FriendlyName -eq $($selfSignedCertificateParams.FriendlyName)}).Thumbprint

#$selfSignedCertificateThumbprint | clip
#psedit $dscConfigLocalhostADDS_ps1_FullPath
#psedit $dscConfigLocalhostADDS_psm1_FullPath

#endregion

}

PROCESS
{

    #^ Customize this with your details
    $configData = @{
        AllNodes = @(
            @{
                NodeName                    = '*'
                
                ManagementNodeIPv4Address   = '10.2.134.239'
                InterfaceAlias              = 'Eth0'

                DomainName                  = 'lab.local' #FIXME: your domain FQDN
                DomainNetbiosName           = 'mot'       #FIXME: your domain NetBIOS
                Thumbprint                  = $selfSignedCertificateThumbprint
                CertificateFile             = $dscSelfSignedCerCertificate_FullPath
                NTDSPath                    = 'C:\Windows\NTDS'
                LogPath                     = 'C:\Windows\Logs'
                SysvolPath                  = 'C:\Windows\SYSVOL'
                TimeZone                    = 'Central European Standard Time' #https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-time-zones?view=windows-11
                Locale                      = 'pl-PL'                          #https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-input-locales-for-windows-language-packs?view=windows-11
             }

            @{
                NodeName                    = 'dc01'                           #FIXME
                Role                        = 'RootDomainController'
                IPV4Address                 = '10.2.134.201/24'
                DefaultGatewayAddress       = '10.2.134.254'
                DNSServers                  = '127.0.0.1', '1.1.1.1' #NOTE: Cloudflare IP is optional
                # # domain settings -->
                ComplexityEnabled           = $false
                MinPasswordLength           = 8
                FirstSite                   = 'Lab-Site'                       #FIXME: your first site's name
                #AdditionalSites             = @('Lab-SH', 'Lab-HQ', 'Lab-BR') #FIXME: additional sites
                #SitelinkPrimaryMembers      = @('Lab-OY', 'Lab-SH', 'Lab-HQ') #FIXME: optional
                #SitelinkSecondaryMembers    = @('Lab-SH', 'Lab-OY', 'Lab-BR') #FIXME: optional
                NTPServer                   = '0.pl.pool.ntp.org'              #FIXME: prefered NTP server
                FailOverNTPServers          = ('1.pl.pool.ntp.org','2.pl.pool.ntp.org')  #FIXME: alternative NTP server
            }

            @{
                NodeName                    = 'dc02'                           #FIXME: additional DC
                Role                        = 'MemberDomainController'
                IPV4Address                 = '10.2.134.202/24'                #FIXME: additional DC IP
                DefaultGatewayAddress       = '10.2.134.254'
                DNSServers                  = '10.2.134.201', '1.1.1.1'        #FIXME: first DC + any optional DNS servers
                Site                        = 'Lab-Site'                       #FIXME: any valid site created on the first DC
                IsGlobalCatalog             = $true
                NTPServer                   = '0.pl.pool.ntp.org'              #FIXME: prefered NTP server
                FailOverNTPServers          = ('3.pl.pool.ntp.org','time.windows.com') #FIXME: alternative NTP server
            }
        )
    }

    # load the configuration into memory for it's execution
    . $dscConfigLocalhostADDS_ps1_FullPath

    if ($ENV:ComputerName -match 'dc01')
    {
        Write-Output "$env:ComputerName - Role: RootDomainController"
        #^ Generate configuration MOF files for the first DC
        DomainFirstDC -ConfigurationData $configData `
            -OutputPath $dscOutputADDS_DirectoryPath `
            -DomainCredential $AdministratorCred `
            -SafemodePassword $AdministratorCred  
    }
    else
    {
        Write-Output "$env:ComputerName - Role: MemberDomainController"
        #^ Generate configuration MOF files for the additional DCs
        DomainAdditionalDCs -ConfigurationData $configData `
            -OutputPath $dscOutputADDS_DirectoryPath `
            -DomainCredential $domainAdministratorCred `
            -SafemodePassword $SafemodeAdministratorCred
    }

    #^ Configure the LCM
    # LCM is included within the configuration
    # stored within the same directory as the compilation MOF files
    Set-DscLocalConfigurationManager -Path $dscOutputADDS_DirectoryPath -Force -Verbose

    # check if the certificate thumbprint is within the LCM settings
    #Get-DscLocalConfigurationManager -CimSession localhost

    #^ Apply the Dsc Configuration
    Start-DscConfiguration -Path $dscOutputADDS_DirectoryPath -Force -Wait -Verbose
}

END
{
    #^ Verify status of the configuration
    #$state = (Test-DscConfiguration -Path $dscOutputADDS_DirectoryPath)
    #Write-Host $($state.ResourcesNotInDesiredState | Format-Table -AutoSize -Wrap | Out-String) -ForegroundColor Red
    #Write-Host $($state.ResourcesInDesiredState | Format-Table -AutoSize -Wrap | Out-String) -ForegroundColor Green
    #Write-Warning 'Please review resources displayed in RED!'
}