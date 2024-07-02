# Create a credential object
$AdminUsername                 = "Administrator"
$AdminPassword                 = ConvertTo-SecureString "Password1$" -AsPlainText -Force
$AdminCredential               = New-Object System.Management.Automation.PSCredential ($AdminUsername, $AdminPassword)

# once the domain is configured then the dc01\administrator should be used to connect to the domain controller
# if the domain is not there regular account: administrator or dc02\administrator

# Create a CIM session to the target node using the credential
$cimSession201 = New-CimSession -ComputerName "10.2.134.201" -Credential $AdminCredential
$cimSession202 = New-CimSession -ComputerName "10.2.134.201" -Credential $AdminCredential

# Example of invoking a CIM method
Invoke-CimMethod -CimSession $cimSession201 -Namespace root\cimv2 -ClassName Win32_Process -MethodName Create -Arguments @{CommandLine="notepad.exe"}
Invoke-CimMethod -CimSession $cimSession202 -Namespace root\cimv2 -ClassName Win32_Process -MethodName Create -Arguments @{CommandLine="notepad.exe"}

# Remove the CIM session after the operation
Remove-CimSession -CimSession $cimSession201
Remove-CimSession -CimSession $cimSession202

######3

$creds = Get-Credential
$creds201 = get-Credential
Enter-PSSession -ComputerName 10.2.134.202 -Credential $creds
Enter-PSSession -ComputerName 10.2.134.201 -Credential $creds

Test-NetConnection -ComputerName 10.2.134.202 -Port 5985
Test-NetConnection -ComputerName 10.2.134.201 -Port 5985


Test-NetConnection -ComputerName 10.2.134.202 -Port 3389
Test-NetConnection -ComputerName 10.2.134.201 -Port 3389
