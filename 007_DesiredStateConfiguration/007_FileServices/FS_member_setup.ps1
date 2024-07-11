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
        'PSDscResources'                        = '2.12.0.0'
        'ComputerManagementDsc'                 = '9.1.0'
        'NetworkingDsc'                         = '9.0.0'
        'StorageDsc'                            = '6.0.1'
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

    #$certificate_FolderName                    = 'certificate'     #C:\dsc\certificate\ - # it stores self signed certificate used to secure DSC credentials
    #$function_FolderName                       = 'function'        #C:\dsc\function\
    #$module_FolderName                         = 'module'          #C:\dsc\module\ - # it stores the Module which contains various functions

    $output_FolderName                         = '_output'         #C:\dsc\_output\ - # it stores the results of the DSC compilation
    $LCM_FolderName                            = 'LCM'             #C:\dsc\_output\LCM\

    $FS_FolderName                             = 'FileServer' #C:\dsc\config\localhost\FileServer\ - # it contains the configurations of FileServer

    #C:\dsc\
    $dsc_DirectoryPath                         = Join-Path -Path "$env:SYSTEMDRIVE" -childPath $dsc_FolderName

    #C:\dsc\config\
    $dscConfig_DirectoryPath                   = Join-Path -Path $dsc_DirectoryPath -childPath $config_FolderName
    #C:\dsc\config\localhost\
    $dscConfigLocahost_DirectoryPath           = Join-Path -Path $dscConfig_DirectoryPath -ChildPath $localhost_FolderName
    #C:\dsc\config\localhost\FileServer\
    $dscConfigLocalhostFS_DirectoryPath      = Join-Path -Path $dscConfigLocahost_DirectoryPath -ChildPath $FS_FolderName

    #C:\dsc\certificate\
    ##$dscCertificate_DirectoryPath              = Join-Path -Path $dsc_DirectoryPath -ChildPath $certificate_FolderName

    #C:\dsc\function\
    ##$dscFunction_DirectoryPath                 = Join-Path -Path $dsc_DirectoryPath -ChildPath $function_FolderName

    #C:\dsc\module\
    ##$dscModule_DirectoryPath                   = Join-Path -Path $dsc_DirectoryPath -ChildPath $module_FolderName

    #C:\dsc\_output\
    $dscOutput_DirectoryPath                   = Join-Path -Path $dsc_DirectoryPath -ChildPath $output_FolderName
    #C:\dsc\_output\FileServer
    $dscOutputFS_DirectoryPath               = Join-Path -Path $dscOutput_DirectoryPath -ChildPath $FS_FolderName
    #C:\dsc\_output\LCM
    $dscOutputLCM_DirectoryPath               = Join-Path -Path $dscOutput_DirectoryPath -ChildPath $LCM_FolderName
    #endregion

    #region Initialize Variables - Function - C:\dsc\function\New-SelfSignedCertificateEx.ps1
    # it contains the Function to prepare the self signed certificate
    ##$newSelfSignedCertificateEx_FileName       = 'New-SelfSignedCertificateEx.ps1'
    ##$newSelfsignedCertificateEx_GithubUrl      = 'https://raw.githubusercontent.com/Azure/azure-libraries-for-net/master/Samples/Asset',$newSelfSignedCertificateEx_FileName -join '/'

    ##$dscFunction_NewSelfSignedCertificateEx_FullPath = Join-Path -Path $dscFunction_DirectoryPath -ChildPath $newSelfSignedCertificateEx_FileName

    ##$selfSignedCertificateParams               = @{
    ##    Subject                                = "CN=${ENV:ComputerName}"
    ##    EKU                                    = 'Document Encryption'
    ##    KeyUsage                               = 'KeyEncipherment, DataEncipherment'
    ##    SAN                                    = ${ENV:ComputerName}
    ##    FriendlyName                           = 'DSC Credential Encryption certificate'
    ##    Exportable                             = $true
    ##    StoreLocation                          = 'LocalMachine'
    ##    KeyLength                              = 2048
    ##    ProviderName                           = 'Microsoft Enhanced Cryptographic Provider v1.0'
    ##    AlgorithmName                          = 'RSA'
    ##    SignatureAlgorithm                     = 'SHA256'
    ##}

    ##$selfSignedCertificatePrivateKeyPassword              = 'Password1$'
    ##$selfSignedCertificatePrivateKeyPasswordSecureString  = ConvertTo-SecureString -String $selfSignedCertificatePrivateKeyPassword -Force -AsPlainText
    #endregion

    #region Initialize Variables - Self Signed Certificate
    ##$dscSelfSignedCertificate_FileName         = 'dscSelfSignedCertificate'
    ##$dscSelfSignedCerCertificate_FileName      = $dscSelfSignedCertificate_FileName,'cer' -join '.'
    ##$dscSelfSignedPfxCertificate_FileName      = $dscSelfSignedCertificate_FileName,'pfx' -join '.'

    ##$dscSelfSignedCerCertificate_FullPath      = Join-Path -Path $dscCertificate_DirectoryPath -ChildPath $dscSelfSignedCerCertificate_FileName
    ##$dscSelfSignedPfxCertificate_FullPath      = Join-Path -Path $dscCertificate_DirectoryPath -ChildPath $dscSelfSignedPfxCertificate_FileName
    #endregion

    #region Initialize Variables - Configuration - ADDS
    $dscConfigLocalhostFS_ps1_FileName       = 'FS_member_configuration.ps1'

    $dscConfigLocalhostFS_GithubUrl          = 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/007_FileServices'
    $dscConfigLocalhostFS_ps1_GithubUrl      = $dscConfigLocalhostFS_GithubUrl,$dscConfigLocalhostFS_ps1_FileName -join '/'

    #C:\dsc\config\localhost\FileServer\New-ADDSC.ps1
    $dscConfigLocalhostFS_ps1_FullPath       = Join-Path -Path $dscConfigLocalhostFS_DirectoryPath -ChildPath $dscConfigLocalhostFS_ps1_FileName
    #endregion

    $configData_psd1_fileName                  = 'ConfigData.psd1'
    $configDataFS_GithubUrl                    = 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/001_initialConfig'
    $configData_psd1_url                       = $configDataFS_GithubUrl,$configData_psd1_fileName -join '/'

    $configData_psd1_FullPath                  = Join-Path -Path $dscConfigLocalhostFS_DirectoryPath -ChildPath $configData_psd1_fileName

    #endregion

    #region 2. DSC - Prepare Prerequisites

    #region 2.1. Create Directory Structure
    $arrayFolderStructure = @(
        #$dsc_DirectoryPath,
        #$dscConfig_DirectoryPath,
        #$dscConfigLocahost_DirectoryPath,
        $dscConfigLocalhostFS_DirectoryPath,
        #$dscCertificate_DirectoryPath,
        #$dscFunction_DirectoryPath,
        #$dscModule_DirectoryPath,
        #$dscOutput_DirectoryPath,
        $dscOutputFS_DirectoryPath
        #$dscOutputLCM_DirectoryPath
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

    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force
    Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force

    #region 2.2. Download code from from Github
    # Function: SelfSigned Certificate
    #https://raw.githubusercontent.com/Azure/azure-libraries-for-net/master/Samples/Asset/New-SelfSignedCertificateEx.ps1
    ##Invoke-WebRequest -Uri $newSelfsignedCertificateEx_GithubUrl -OutFile $dscFunction_NewSelfSignedCertificateEx_FullPath -Verbose

    # DSC Configuration: - localhost FileServices
    #configuration_ADDS.ps1
    #https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory/configuration_ADDS.ps1
    Invoke-WebRequest -Uri $dscConfigLocalhostFS_ps1_GithubUrl -OutFile $dscConfigLocalhostFS_ps1_FullPath -Verbose

    Invoke-WebRequest -Uri $configData_psd1_url -OutFile $configData_psd1_FullPath -Verbose

    #New-ADDSC.psm1
    #Invoke-WebRequest -Uri $dscConfigLocalhostADDS_psm1_GithubUrl -OutFile $dscConfigLocalhostADDS_psm1_FullPath -Verbose
    #endregion

    #region 2.3. Self Signed Certificate - Generate and Export to CER & PFX
    ##if (!(Get-ChildItem -Path Cert:\LocalMachine\My\ | Where-Object {$_.FriendlyName -eq $($selfSignedCertificateParams.FriendlyName)})){
    # Load the function into memory
    ##    . $dscFunction_NewSelfSignedCertificateEx_FullPath
    ##    try {
    ##        New-SelfsignedCertificateEx @selfSignedCertificateParams
    ##    }
    ##    catch {

    ##    }
    ##}
    ##else {
    ##    Write-Output "Certificate already exist - Friendly Name: $($selfSignedCertificateParams.FriendlyName)"
    ##}

    # Exporting certificate to CER and PFX
    ##if(!(Test-Path -Path $dscSelfSignedCerCertificate_FullPath)){
    ##    try {
    ##        Get-ChildItem -Path Cert:\LocalMachine\My\ | Where-Object {$_.FriendlyName -eq $($selfSignedCertificateParams.FriendlyName)} | Export-Certificate -Type cer -FilePath $dscSelfSignedCerCertificate_FullPath -Force
    ##    }
    ##    catch {

    ##    }
    ##}
    ##else {
    ##    Write-Output "Certificate CER File already exist - Path: $($dscSelfSignedCerCertificate_FullPath)"
    ##}

    ##if(!(Test-Path -Path $dscSelfSignedPfxCertificate_FullPath)){
    ##    try {
    ##        Get-ChildItem -Path Cert:\LocalMachine\My\ | Where-Object {$_.FriendlyName -eq $($selfSignedCertificateParams.FriendlyName)} | Export-PfxCertificate -FilePath $dscSelfSignedPfxCertificate_FullPath -Password $selfSignedCertificatePrivateKeyPasswordSecureString
    ##    }
    ##    catch {

    ##    }    
    ##}
    ##else {
    ##    Write-Output "Certificate PFX File already exist - Path: $($dscSelfSignedPfxCertificate_FullPath)"
    ##}
    #endregion

    
    #endregion


}

PROCESS
{
    #region 2.4. Install Missing Modules - TODO:
    #region AUTOMATYCZNIE
    # AutomatedLab - contains functions which are crucial for the whole logic to work properly
    # Install-Modules is one of the functions within the AutomatedLab module

    Install-Modules -modules $modules
    #endregion

        #region - Set-Location
        try {
            # set the location to the path where the DSC configuration is stored
            Write-Information "Change current directory: $($dscConfig_DirectoryPath)"
            Set-Location -Path $dscConfig_DirectoryPath    
        }
        catch {
            <#Do this if a terminating exception happens#>
        }
        #endregion

    # load the configuration into memory for it's execution
    . $dscConfigLocalhostFS_ps1_FullPath

    if ($ENV:ComputerName -match 'fs01')
    {
        Write-Output "$env:ComputerName - Role: File Server Member"
        #^ Generate configuration MOF files for the first DC
        MEMBER_FILESERVER -ConfigurationData $configData `
            -OutputPath $dscOutputFS_DirectoryPath `
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
    # stored within the same directory as the compilation MOF files - NOT TRUE ANYMORE
    ##Set-DscLocalConfigurationManager -Path $dscOutputFS_DirectoryPath -Force -Verbose
    Set-DscLocalConfigurationManager -Path $dscOutputLCM_DirectoryPath -Force -Verbose

    # check if the certificate thumbprint is within the LCM settings
    #Get-DscLocalConfigurationManager -CimSession localhost

    #^ Apply the Dsc Configuration
    Start-DscConfiguration -Path $dscOutputFS_DirectoryPath -Force -Wait -Verbose


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




    #region DSC - RUN IT!
    $ConfigData = Import-PowerShellDataFile -Path $configData_psd1_FullPath
    #Write-Output $configData_psd1_FullPath
    #$ConfigData.AllNodes
    . $configureNode_ps1_FullPath
    psedit $configureNode_ps1_FullPath

    ConfigureAD -ConfigurationData $ConfigData `
        -AdministratorCred $AdminCredential `
        -DomainAdministratorCred $domainAdministratorCred `
        -SafemodeAdministratorCred $SafemodeAdministratorCred `
        -ADUserCred $adUserCredential -OutputPath $dscConfigOutputDirectoryPath -PsDscRunAsCredential $AdminCredential -Verbose

    #Set-DscLocalConfigurationManager -Path $dscConfigOutputDirectoryPath -Verbose -Credential $AdminCredential

    #region DSC - LCM - run it !
    $nodesAD = @('10.2.134.201','10.2.134.202')
    $nodesAD.foreach({
        $tempCimSession = New-CimSession -ComputerName $_ -Credential $AdminCredential
        Set-DscLocalConfigurationManager -Path $dscConfigOutputDirectoryPath -CimSession $tempCimSession -Verbose
        Get-DscLocalConfigurationManager -CimSession $tempCimSession -Verbose
    })
    #endregion

}

END
{
    #^ Verify status of the configuration
    #$state = (Test-DscConfiguration -Path $dscOutputADDS_DirectoryPath)
    #Write-Host $($state.ResourcesNotInDesiredState | Format-Table -AutoSize -Wrap | Out-String) -ForegroundColor Red
    #Write-Host $($state.ResourcesInDesiredState | Format-Table -AutoSize -Wrap | Out-String) -ForegroundColor Green
    #Write-Warning 'Please review resources displayed in RED!'
}
