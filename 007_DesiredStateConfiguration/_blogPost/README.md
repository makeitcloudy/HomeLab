#

## windows-dsc

## windows-preparation

Run_initialSetup.ps1 is used in:

*
*

### run_initialSetup.ps1

Core here is a duplicate (anytime it's modified there, those changes should be reflected here in README.md) of:

* [run_initialSetup.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/windows-preparation/run_initialSetup.ps1) - github
* [run_initialSetup.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/_blogPost/windows-preparation/run_initialSetup.ps1) - github raw

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