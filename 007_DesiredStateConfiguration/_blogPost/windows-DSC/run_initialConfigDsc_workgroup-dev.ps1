# It requires the AutomatedLab Module available on the VM.
# It runs the function from the AutomatedLab module.

# Start-Process PowerShell_ISE -Verb RunAs
# run in elevated powershell session

# Set-InitialConfigDsc is part of the AutomatedLab module
# it has been downloaded during the preparation steps (when the vmtools were installed)

# at this stage the target node has correct name

#region - Initial Setup - Workgroup
# For succesfull execution Domain does NOT have to be available, DNS should resolve public domains
# Execute this piece of when configuring target node in the Workgroup
Set-InitialConfigDevDsc -NewComputerName $env:computername -Option Workgroup -Verbose
# Funtion runs InitialConfigDsc-dev.ps1 file which makes use of the ConfigData-dev.psd1 for the DSC configuration
#endregion