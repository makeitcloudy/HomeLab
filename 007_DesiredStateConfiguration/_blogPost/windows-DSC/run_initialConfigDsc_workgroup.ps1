# Start-Process PowerShell_ISE -Verb RunAs
# run in elevated powershell session

# Set-InitialConfigDsc is part of the AutomatedLab module
# it has been downloaded during the preparation steps (when the vmtools were installed)

# at this stage the target node has correct name

#region - Initial Setup - Workgroup
# For succesfull execution Domain does NOT have to be available, DNS should resolve public domains
# Execute this piece of when configuring target node in the Workgroup
Set-InitialConfigDsc -NewComputerName $env:computername -Option Workgroup -Verbose
#endregion