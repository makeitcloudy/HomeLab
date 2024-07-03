# store the future domain admin credentials

#region 0 - VM preparation
$computerName = 'dc01' #FIXME

#region 0.0 - Install VM Tools
# at this stage install the tools silently
# do NOT reboot VM - it is rebooted during renaming

#endregion

#region 0.1 - Rename Computer
Rename-Computer -NewName $computerName -Force -Restart
#endregion

#region 0.2 - Zaimportowac Modul Automated Lab
# Pobrac folder z     : https://github.com/makeitcloudy/AutomatedLab/tree/feature/AutomatedLab
# Zapisac zawartosc do: C:\dsc\module\AutomatedLab
# Skopiowac do lokalizacji z modulami
# Zaimportowac Modul do sesji PS

#region TODO
# 1. zrobic modul AutomatedLab
# 2. zrzucic modul na Github
# 3. pobrac go lokalnie
# 4. zapisac / skopiowac do lokalizacji z modulami
# 5. zaladowac, tutaj tylko wywolac funkcje odpowiedzialna za instalacje modulow
# 6. nazwy wraz z wersjami modulow zdefiniowane jako parametr na gorze - przy inicjowaniu zmiennych

#endregion




#region 2. Run it
#Import Module to memory
. $dscConfigLocalhostADDS_psm1_FullPath

. $dscConfigLocalhostADDS_ps1_FullPath -domainCred $AdministratorCred -certThumbprint $selfSignedCertificateThumbprint
psedit $dscConfigLocalhostADDS_ps1_FullPath
#endregion


#region 3. Troubleshoot
$configData.AllNodes.Thumbprint
$configData.AllNodes.CertificateFile
#endregion


# run the script
#& "\\tsclient\C\PROJECTS\dsc\SS.INFRA.DSC\NewAD\New-ADDSC.ps1"`
# -domainCred $cred `
# -certThumbprint "64bd5b4725f03221e6b03cf8d376d3bbbd569917" `
# -prereq

$downloadsPath = "$env:USERPROFILE\Downloads"

$uri = 'https://raw.githubusercontent.com/makeitcloudy/AutomatedLab/feature/007_DesiredStateConfiguration/005_ADDS_blogEntry.ps1'
$outFile = Join-Path -Path $downloadsPath -ChildPath 'ADDS_demo.ps1'

Set-Location -Path $downloadsPath

Invoke-WebRequest -Uri $uri -OutFile $outFile -Verbose
psedit $outfile