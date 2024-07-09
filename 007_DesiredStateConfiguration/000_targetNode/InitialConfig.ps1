# This code aggregates the steps mentioned in the
# https://makeitcloudy.pl/windows-prepraration/
# instead of running code from sections, it can be run in one go
# as a result the management VM is ready for the steps listed in
# https://makeitcloudy.pl/windows-DSC/

### Assumptions
### 1. At this stage VM is installed
### 2. The VM tools ISO is mounted into the VM in XCP-ng

# TODO
# Add itempotency to VMTools - installation
# 

function Set-InitialConfiguration {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER mgmNodeIP
    .EXAMPLE
    .LINK
    #>

    [CmdletBinding()]    
    [CmdletBinding()]
    param (

    )

    BEGIN
    {
        $WarningPreference = "Continue"
        $VerbosePreference = "Continue"
        $InformationPreference = "Continue"
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - InitialConfig.ps1"
        $startDate = Get-Date
    }

    PROCESS
    {
        #region 2.1.1 - VMTools - installation
        # run on VM (in elevated powershell session)
        #Start-Process PowerShell_ISE -Verb RunAs

        # https://support.citrix.com/article/CTX222533/install-xenserver-tools-silently
        # https://forums.lawrencesystems.com/t/xcp-ng-installing-citrix-agent-for-windows-via-powershell-script/13855

        $PackageName = 'managementagent-9.3.3-x64'
        $InstallerType = 'msi'

        $LogApp = 'C:\Windows\Temp\CitrixHypervisor-9.3.3.log'

        $opticalDriveLetter = (Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DriveType -eq 5}).DeviceID
        Get-ChildItem -Path $opticalDriveLetter
        #$Source = "$PackageName" + "." + "$InstallerType"
        $UnattendedArgs = "/i $(Join-Path -Path $opticalDriveLetter -ChildPath $($PackageName,$InstallerType -join '.')) ALLUSERS=1 /Lv $LogApp /quiet /norestart"

        # should throw 0
        (Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru).ExitCode
        #Invoke-Item -Path $LogApp
        #endregion

        #region 3.1 - Configure WinRM
        #Rename-Computer -NewName 'w10mgmt' -Force -Restart
        #$winRMServiceName = 'winRM' 

        #check if CurrentUser is enough or LocalMachine is the correct one
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force

        # check if it is a desktop operating system
        # in case it is then change the execution policy
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName
        switch($os.ProductType){
            '1' {
                    Write-Information 'DesktopOS'
                    #if((Get-Service -Name $winRMServiceName).Status -match 'Stopped'){
                    #    Write-Warning "WinRM service is stopped"
                    #    Start-Service -Name $winRMServiceName
                    
                    #region - NetConnectionProfile - set to private
                    try {
                        Write-Information 'Set NetConnectionProfile to Private'
                        Set-NetConnectionProfile -NetworkCategory Private | Out-Null
                        #Get-Item WSMan:\localhost\Client\TrustedHosts #empty
                    }
                    catch {

                    }
                    #endregion

                    #region - Enable PS Remoting
                    try {
                        Write-Information 'Enable-PSRemoting'
                        $VerbosePreference = 'SilentlyContinue'
                        Enable-PSRemoting | Out-Null
                        $VerbosePreference = 'Continue'
                    }
                    catch {

                    }
                    
                    try {
                        #region 3 - RSAT Tools
                        Write-Information 'Add-WindowsCapability'
                        Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0* | Out-Null
                        #endregion                        
                    }
                    catch {
                        <#Do this if a terminating exception happens#>
                    }
                    #endregion
                }
            '3' {
                    Write-Information 'ServerOs'
                    # PS Remoting seems to be configured already for the succesfull execution
                }
        }

        #endregion

        #region 3.2 - PowerShell Module - AutomatedLab - Download from Github
        # run in elevated PowerShell session
        #region initialize variables
        $scriptName     = 'Get-GitModule.ps1'
        $uri            = 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode',$scriptName -join '/'
        $path           = "$env:USERPROFILE\Documents"
        $outFile        = Join-Path -Path $path -ChildPath $scriptName

        $githubUserName = 'makeitcloudy'
        $moduleName     = 'AutomatedLab'
        #endregion

        #region download function Get-GitModule.ps1
        Set-Location -Path $path
        Invoke-WebRequest -Uri $uri -OutFile $outFile -Verbose
        #psedit $outFile

        # load function into memory
        . $outFile
        Get-GitModule -GithubUserName $githubUserName -ModuleName $moduleName -Verbose
        #endregion

        #removal of the function
        Remove-Item -Path $outFile -Force -Verbose

        # troubleshooting
        #Get-Module -Name $moduleName -ListAvailable
        #Get-Command -Module $moduleName
        #endregion

        #region 3.3 - PowerShell Module - AutomatedXCPng - Download from Github
        # run in elevated PowerShell session
        # follow the guidelines: https://github.com/makeitcloudy/AutomatedXCPng
        # There prerequisite for the AutomatedXCPng to work properly is - Citrix Hypervisor Powershell Module / SDK

        $githubUserName = 'makeitcloudy'
        $moduleName     = 'AutomatedXCPng'

        Get-GitModule -GithubUserName $githubUserName -ModuleName $moduleName -Verbose

        # troubleshooting
        #Get-Module -Name $moduleName -ListAvailable
        #Get-Command -Module $moduleName
        #endregion

        #region 3.4 - Power Plan
        try {
            #$powerPlanName = 'Ultimate Performance'
            $powerPlanName = 'High Performance' 
            $p = Get-CimInstance -Namespace root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = '$($powerPlanName)'"
            $planGuid = $p.InstanceID.Split("\")[-1]
            $cleanGuid = $planGuid -replace '^\{(.*)\}$', '$1'
            powercfg /SETACTIVE $cleanGuid
        }
        catch {

        }
        #endregion

        Write-Information 'If everything went well, please proceed with steps described in blogpost: https://makeitcloudy.pl/windows-DSC/'
    }

    END
    {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}