$githubUrl            = 'https://raw.githubusercontent.com/makeitcloudy/AutomatedLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory'
$fileName             = 'ADDS_setup.ps1'
$uri                  = $githubUrl,$fileName -join '/'

$outDirectoryPath     = "$env:USERPROFILE\Documents"
$outDirectoryFullPath = Join-Path $outDirectoryPath -ChildPath $fileName



Invoke-WebRequest -Uri $uri -OutFile $outDirectoryFullPath
#psedit $outDirectoryFullPath

if(Test-Path -Path $outDirectoryFullPath){
    & $outDirectoryFullPath -Computername $env:COMPUTERNAME
}
