# get the syntax of the resource
# it will show how to use the resource within the configuration
Get-DscResource $dscResource -Syntax

# find resources
# all the resources published in the Gallery
Find-DscResource -tag dsc

Find-DscResource -name xWebSite
# install it on the authoring node
# install it on any node where it will be used
Install-Module xWebAdministration

#region install DSC modules - prerequisites
$winRMsession = New-PSSession -ComputerName vm1
Invoke-Command -ScriptBlock {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12} -Session $winRMsession

Invoke-Command {$ProgressPreference = 'silentlycontinue'} -Session $winRMsession
Invoke-Command {Install-Module ComputerManagementDSC,NetworkingDSC -Force} -Session $winRMsession
Invoke-Command {Get-Module -Name ComputerManagementDSC,NetworkingDsc -ListAvailable} -Session $winRMsession
Invoke-Command {Get-DscResource HostsFile,SMBShare} -session $s | Select-Object Name,ModuleName,Version

Remove-PSSession -Session $s

Clear-Host
#endregion

#region remove DSC module
#Get-Module -ListAvailable -Name 'PSDscResources' | Uninstall-Module
#Get-Module -ListAvailable -Name 'PSDscResources' | Remove-Module

#Get-Module -ListAvailable -Name 'PSDesiredStateConfiguration' | Uninstall-Module
#Get-Module -ListAvailable -Name 'PSDesiredStateConfiguration' | Remove-Module
# restart ISE session
#endregion

# 1. Define requiremets - business need
# 2. Create DSC Configuration - authoring
# 3. Compile the configuration - One configuration per server | MOF artifact
# 4. Deploy configuration - LCM implements configuration | you may need to configure the LCM
# *. Start-DscConfiguration

# LCM
# * ApplyOnly
# * ApplyAndMonitor
# * ApplyAndAutoCorrect
# * MonitorOnly

# * One configuration per server
# * Last configuration applied 'wins'
# * Configurations can un-do settings
# * Configuration files are critical and sensitive
# * Build test and remediations

$PSVersionTable
#PSVersion - 5.1.19041.1237

whoami /groups /fo csv | ConvertFrom-Csv | Sort-Object 'Group Name' | Select-Object 'Group Name'
#the account is member of domain admins already - to make life convinient

#region DSC - first run
# Sample.ps1 - contains the Configuration Sample {}
. .\Sample.ps1
Invoke-Command {Test-Path -Path c:\dscdemo} -ComputerName vm1
sample #generate mof file
Start-DscConfiguration -Path C:\Sample -Verbose -Wait

Get-DscConfiguration -CimSession vm1
Get-DscLocalConfigurationManager -CimSession vm1
#endregion

#region DSC - 1. authoring configuration
# Dsc resources live in powershell modules
# once modules are installed then the ISE gives the intellisense and autocomplete

Get-DscResource File -Syntax

## Using DSC Resources
# DSC Resource modules must be installed on target nodes
# * Deploy using your procedures
# Import resource modules in your configuration
# * Include module version
# Pay attenot to required settings
# Configurations run unattended under SYSTEM
# * some resources may allow using other context

# 1. Author the configuration
# 2. Save the configuration in .ps1 file
# 3. Load it into memory
. .\basicConfig.ps1
Get-Command BasicConfig
Get-Help BasicConfig
# 4. Compiling the configuration
# If you do not specify the path the folder will be created using the configuration name
BasicConfig -OutputPath .
#endregion

#region LCM
# * Software element that manages DSC locally
# * Applies and monitors configurations
# * Can check for new configurations (pull)
Get-DscLocalConfigurationManager

Get-DscLocalConfigurationManager -CimSession vm1

# Option 1. add the resource to the node configuration
LocalConfigurationManager {
    RebootNodeIFNeeded = $True
    ConfigurationMode  = "ApplyAndAutoCorrect"
    ActionAfterReboot  = "ContinueConfiguration"
    RefreshMode        = "Push"
}

# Option 2. create a separate configuration
[DscLocalConfigurationManager()]
Configuration LCMConfig {
    Node vm1 {
        Settings {
            RebootNodeIFNeeded = $True
            ConfigurationMode  = "ApplyAndAutoCorrect"
            ActionAfterReboot  = "ContinueConfiguration"
            RefreshMode        = "Push"
        }
    }
}

# Run the configuration
# .meta.mof file is created
#endregion

#region DSC Resource
Get-Module PowerShellGet -ListAvailable
Get-Module PackageManagement -ListAvailable

# those modules are installed on your operating system - so you can not just run update-module
# you should use Install-Module -Force paramater
# once the packages are installed within the operating system there is no way to update modules, you should install them with -Force parameter
Install-Module -Name 'PowerShellGet' -RequiredVersion 2.2.5 -Force -AllowClobber
#endregion

#region DSC - Find DSC resource
# find a module that a resource exist in

$dscResource = 'smbShare'
Find-DscResource -Name $dscResource | Tee-Object -Variable r
$r.ModuleName

Find-Module $r.ModuleName| Tee-Object -Variable m
$m | Format-list Author,PublishedDate,ProjectUri,Description
$m.AdditionalMetadata.DscResources
Start-Process $m.ProjectUri
Start-Process ("https://www.powershellgallery.com/packages?q=",$m.Name -join '')

### Install the module
Install-Module -Name $r.ModuleName -RequiredVersion 9.1.0 -Force

Get-Module -Name $r.ModuleName -ListAvailable

###

Get-Module -Name NetworkingDsc -ListAvailable
Get-DscResource -Module NetworkingDsc
Get-DscResource DnsServerAddress -Syntax

Find-DscResource -tag dsc
Find-DscResource -Filter "Firewall"
Find-DscResource -Name Firewall

### Find DSC Resource
Find-DscResource -Name hosts
Find-DscResource -Filter "hosts"
Find-DscResource -Name hostsfile
#endregion

#region Author DSC Configuration
# ISE -> CTRL+J (Code Snippets) -> DSC Configuration Simple
# CTRL + SPACE
#endregion

#region DSC - Target Node Preparation
# * you need admin credentials on target nodes
# * PowerShell remoting must be enabled
Test-WSMan
New-CimSession #DSC under the hood is using CIM session / not the powershell session
# if you do a cim session towards target node, then DSC will work

# * versions of the module should match on the authoring and target nodes

Get-Module -Name PSDesiredStateConfiguration -ListAvailable
Get-Module -Name ComputerManagementDsc -ListAvailable
Get-Module -Name NetworkingDsc -ListAvailable
#endregion

#region DSC - 2. Deploying a Configuration
Start-DscConfiguration
Start-DscConfiguration -ComputerName vm1 #backgroundjob
Stop-DscConfiguration #to kill a deployment job
Start-DscConfiguration -ComputerName vm1 -Wait -Verbose -UseExisting #to re-apply existing/current configuration -rerun reappy / when not in LCM Autoapply
Restore-DscConfiguration -CimSession vm1 #use to re-apply the previous configuration

### Status and Testing
Get-DscConfiguration -CimSession vm1
Test-DscConfiguration -ComputerName vm1
Test-DscConfiguration -ComputerName vm1 -Detailed
#endregion