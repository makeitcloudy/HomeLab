# run in elevated PowerShell session
#region initialize variables
$scriptName     = 'windows-preparation.ps1'
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
windows-preparation
#endregion