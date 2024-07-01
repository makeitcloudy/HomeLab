#region - always run - initialize variables
#region initialize variables - DSC
$drive                              = 'C:'
$dscConfigFolder                    = 'dscConfig'
# DSC mof files full path
$dscConfigFullPath                  = Join-Path -Path $drive -ChildPath $dscConfigFolder

# DSC configuration location
$dscConfigPath                      = "$env:USERPROFILE\Documents\dsc_config_domainControllers"
# DSC configuration data file - stored in the same directory as DSC configuration
$dscConfigDataFileName              = "ConfigData.psd1"
# DSC configuration data file full path
$dscConfigDataPath                  = Join-Path -Path $dscConfigPath -ChildPath $dscConfigDataFileName

# Provide credentials for DSC to use
$AdminUsername                      = "administrator"
$AdminPassword                      = ConvertTo-SecureString "Password1$" -AsPlainText -Force
$AdminCredential                    = New-Object System.Management.Automation.PSCredential ($AdminUsername, $AdminPassword)

#endregion

#region initialize variables - New-SelfSignedCertificateEx.ps1 function
Set-Location -Path $dscConfigPath
#endregion