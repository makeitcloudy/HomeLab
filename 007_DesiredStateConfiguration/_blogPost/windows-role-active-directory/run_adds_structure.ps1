#cmd
#powershell
#Start-Process PowerShell -Verb RunAs
# run in elevated PowerShell session
Set-Location -Path "$env:USERPROFILE\Documents"

Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory/ADDS_structure.ps1' -OutFile "$env:USERPROFILE\Documents\ADDS_structure.ps1" -Verbose

#psedit "$env:USERPROFILE\Documents\ADDS_structure.ps1"

# it launches the process of the Active Directory structure creation
.\ADDS_structure.ps1