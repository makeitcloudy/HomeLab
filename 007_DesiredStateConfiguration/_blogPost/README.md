#

## windows-preparation

Run_initialSetup.ps1 is used in:

* [windows-preparation](https://makeitcloudy.pl/windows-preparation/) - paragraph 2.0.2
* [windows-role-DSC](https://makeitcloudy.pl/windows-role-DSC/) - through deployments of Windows Roles

### run_initialSetup.ps1

Core here is a duplicate (anytime the source is updated, those changes should be reflected here in README.md) of:

* [run_initialSetup.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/windows-preparation/run_initialSetup.ps1) - GitHub
* [run_initialSetup.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/_blogPost/windows-preparation/run_initialSetup.ps1) - GitHub raw
* [InitialConfig.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfig.ps1) - GitHub
* [InitialConfig.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfig.ps1) - GitHub raw


```powershell
#Start-Process PowerShell_ISE -Verb RunAs
# run in elevated PowerShell session
#region initialize variables
$scriptName     = 'InitialConfig.ps1'
$uri            = 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode',$scriptName -join '/'
$path           = "$env:USERPROFILE\Documents"
$outFile        = Join-Path -Path $path -ChildPath $scriptName

#endregion

# set the execution policy
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force

#region download function Get-GitModule.ps1
Set-Location -Path $path
Invoke-WebRequest -Uri $uri -OutFile $outFile -Verbose
#psedit $outFile

# load function into memory
. $outFile
#psedit $outfile
Set-InitialConfiguration -Verbose
#endregion

Restart-Computer -Force

```

## windows-dsc

### run_adds.ps1

Core here is a duplicate (anytime the source is updated, those changes should be reflected here in README.md) of:

* [run_adds.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/windows-DSC/run_adds.ps1) - GitHub
* [run_adds.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/_blogPost/windows-DSC/run_adds.ps1) - GitHub raw
* [ActiveDirectory_demo.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/005_ActiveDirectory_demo.ps1) - GitHub
* [ActiveDirectory_demo.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory_demo.ps1) - GitHub raw

```powershell
#Start-Process PowerShell_ISE -Verb RunAs
# run in elevated PowerShell session
Set-Location -Path "$env:USERPROFILE\Documents"

Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory_demo.ps1' -OutFile "$env:USERPROFILE\Documents\ActiveDirectory_demo.ps1" -Verbose
#psedit "$env:USERPROFILE\Documents\ActiveDirectory_demo.ps1"

# at this stage the computername is already renamed and it's name is : dc01
. "$env:USERPROFILE\Documents\ActiveDirectory_demo.ps1" -ComputerName $env:Computername
```