#Start-Process PowerShell_ISE -Verb RunAs
# run in elevated PowerShell session
Set-Location -Path "$env:USERPROFILE\Documents"

Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory_demo.ps1' -OutFile "$env:USERPROFILE\Documents\ActiveDirectory_demo.ps1" -Verbose
#psedit "$env:USERPROFILE\Documents\ActiveDirectory_demo.ps1"

# run_InitialSetup.ps1 has been run, so the VM is already renamed
# DSC configuration data precise the node names
# at this stage the computername is already renamed and it's name is : dc01
. "$env:USERPROFILE\Documents\ActiveDirectory_demo.ps1" -ComputerName $env:Computername
