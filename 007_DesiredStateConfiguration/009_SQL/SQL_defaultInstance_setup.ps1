<#
.SYNOPSIS
Script to setup SQL Server >= 2016

.DESCRIPTION
    This script is intended to set up a functioning File Server.

    The LCM should be already configured within the initial configuration, as per the blog posts describing the process on https://makeitcloudy.pl


.NOTES
    (Use the `Create-SelfSignedCert` function in the module to generate a cert if this is needed)
.LINK
    https://codeandkeep.com/Dsc-Encrypting-Credentials/
    https://github.com/dsccommunity/NetworkingDsc
    https://github.com/dsccommunity/NetworkingDsc/wiki
    https://github.com/dsccommunity/StorageDsc
    https://github.com/dsccommunity/StorageDsc/wiki
.EXAMPLE

#>


[CmdletBinding()]
param (
)

BEGIN
{
    #region 1. DSC - Initialize Variables

    #region Initialize Variables - Missing Modules
    $modules = @{
        'PSDscResources'                        = '2.12.0.0'
        'xPSDesiredStateConfiguration'          = '9.1.0'
        #'ComputerManagementDsc'                 = '9.1.0'
        #'NetworkingDsc'                         = '9.0.0'
        'SqlServerDsc'                          = '16.6.0'
        'StorageDsc'                            = '6.0.1'
    }
    #endregion

    #region Initialize Variables - Folder structure
    # each time you modify the folder structure ammend the $arrayFolderStructure variable accordingly

    $dsc_FolderName                          = 'dsc'             #C:\dsc\

    $config_FolderName                       = 'config'          #C:\dsc\config\ - # it stores the DSC configuration
    $localhost_FolderName                    = 'localhost'       #C:\dsc\config\localhost\ - # it stores the configurations run locally on the localhost (Node)

    #$certificate_FolderName                 = 'certificate'     #C:\dsc\certificate\ - # it stores self signed certificate used to secure DSC credentials
    #$function_FolderName                    = 'function'        #C:\dsc\function\
    #$module_FolderName                      = 'module'          #C:\dsc\module\ - # it stores the Module which contains various functions

    $output_FolderName                       = '_output'         #C:\dsc\_output\ - # it stores the results of the DSC compilation
    $LCM_FolderName                          = 'LCM'             #C:\dsc\_output\LCM\

    $SQL_FolderName                           = 'SQLServer' #C:\dsc\config\localhost\FileServer\ - # it contains the configurations of FileServer

    #C:\dsc\
    $dsc_DirectoryPath                       = Join-Path -Path "$env:SYSTEMDRIVE" -childPath $dsc_FolderName

    #C:\dsc\config\
    $dscConfig_DirectoryPath                 = Join-Path -Path $dsc_DirectoryPath -childPath $config_FolderName
    #C:\dsc\config\localhost\
    $dscConfigLocahost_DirectoryPath         = Join-Path -Path $dscConfig_DirectoryPath -ChildPath $localhost_FolderName
    #C:\dsc\config\localhost\FileServer\
    $dscConfigLocalhostSQL_DirectoryPath      = Join-Path -Path $dscConfigLocahost_DirectoryPath -ChildPath $SQL_FolderName

    #C:\dsc\certificate\
    ##$dscCertificate_DirectoryPath          = Join-Path -Path $dsc_DirectoryPath -ChildPath $certificate_FolderName

    #C:\dsc\function\
    ##$dscFunction_DirectoryPath             = Join-Path -Path $dsc_DirectoryPath -ChildPath $function_FolderName

    #C:\dsc\module\
    ##$dscModule_DirectoryPath               = Join-Path -Path $dsc_DirectoryPath -ChildPath $module_FolderName

    #C:\dsc\_output\
    $dscOutput_DirectoryPath                 = Join-Path -Path $dsc_DirectoryPath -ChildPath $output_FolderName
    #C:\dsc\_output\FileServer
    $dscOutputSQL_DirectoryPath               = Join-Path -Path $dscOutput_DirectoryPath -ChildPath $SQL_FolderName
    #C:\dsc\_output\LCM
    $dscOutputLCM_DirectoryPath              = Join-Path -Path $dscOutput_DirectoryPath -ChildPath $LCM_FolderName
    #endregion

    #region Initialize Variables - Configuration - SQL Server
    $configData_psd1_fileName                = 'ConfigData.psd1'

    $configDataSQL_GithubUrl                 = 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_initialConfig'
    $configData_psd1_url                     = $configDataSQL_GithubUrl,$configData_psd1_fileName -join '/'

    #C:\dsc\config\localhost\FileServer\ConfigData.psd1
    $configData_psd1_FullPath                = Join-Path -Path $dscConfigLocalhostSQL_DirectoryPath -ChildPath $configData_psd1_fileName

    $dscConfigLocalhostSQL_ps1_FileName      = 'SQL_defaultInstance_configuration.ps1'

    $dscConfigLocalhostSQL_GithubUrl         = 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/009_SQL'
    $dscConfigLocalhostSQL_ps1_GithubUrl     = $dscConfigLocalhostSQL_GithubUrl,$dscConfigLocalhostSQL_ps1_FileName -join '/'

    #C:\dsc\config\localhost\FileServer\FS_member_configuration.ps1
    $dscConfigLocalhostSQL_ps1_FullPath      = Join-Path -Path $dscConfigLocalhostSQL_DirectoryPath -ChildPath $dscConfigLocalhostSQL_ps1_FileName
    #endregion

    #endregion

    #region 2. DSC - Prepare Prerequisites

    #region 2.1. Create Directory Structure
    $arrayFolderStructure = @(
        #$dsc_DirectoryPath,
        #$dscConfig_DirectoryPath,
        #$dscConfigLocahost_DirectoryPath,
        $dscConfigLocalhostSQL_DirectoryPath,
        #$dscCertificate_DirectoryPath,
        #$dscFunction_DirectoryPath,
        #$dscModule_DirectoryPath,
        #$dscOutput_DirectoryPath,
        $dscOutputSQL_DirectoryPath
        #$dscOutputLCM_DirectoryPath
    )

    $arrayFolderStructure.ForEach({
        if(!(Test-Path -Path $_)){
            try {
                New-Item -Path $_ -ItemType Directory -Force
            }
            catch {
                Write-Error 'Something went wrong'
            }
        }
        else {
            Write-Output "$_ - already exist"
        }
    })

    #endregion

    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force
    Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force

    #region 2.2. Download ConfigData.pds1 and SQL_defaultInstance_configuration.ps1 from from Github

    # DSC Configuration: - localhost FileServices
    #FS_member_configuration.ps1
    #https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/007_FileServices/FS_member_configuration.ps1
    try {
        Invoke-WebRequest -Uri $dscConfigLocalhostSQL_ps1_GithubUrl -OutFile $dscConfigLocalhostSQL_ps1_FullPath -Verbose    
    }
    catch {

    }
    
    try {
        Invoke-WebRequest -Uri $configData_psd1_url -OutFile $configData_psd1_FullPath -Verbose
    }
    catch {

    }
    #endregion
    #endregion

}
PROCESS
{
    #region Install Missing Modules
    # AutomatedLab - contains functions which are crucial for the whole logic to work properly
    # Install-Modules is one of the functions within the AutomatedLab module

    Install-Modules -modules $modules
    #endregion

    #region Set-Location
    try {
        # set the location to the path where the DSC configuration is stored
        Write-Information "Change current directory: $($dscConfig_DirectoryPath)"
        Set-Location -Path $dscConfig_DirectoryPath    
    }
    catch {
        <#Do this if a terminating exception happens#>
    }
    #endregion

    #region DSC - Import the configuration data
    #$ConfigData = .\ConfigData.psd1
    $configData = Import-PowerShellDataFile -Path $configData_psd1_FullPath

    #$ConfigData.AllNodes
    #endregion

    #Get-DscLocalConfigurationManager -CimSession localhost

    #region DSC - Load the configuration into memory for it's execution
    try {
        . $dscConfigLocalhostSQL_ps1_FullPath
    }
    catch {

    }
    #endregion

    #region DSC - Compile the configuration
    try {
        Write-Information "$env:ComputerName - Role: File Server Member"
        #^ Generate configuration MOF files for the SQL Server
        sqlDefaultInstance2016orLater -ConfigurationData $configData `
                          -OutputPath $dscOutputSQL_DirectoryPath
    }
    catch {

    }
    #endregion

    #region DSC - Start Configuration
    try {
        #^ Apply the Dsc Configuration
        Start-DscConfiguration -Path $dscOutputSQL_DirectoryPath -Force -Wait -Verbose
    }
    catch {

    }
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