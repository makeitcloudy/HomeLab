# https://forums.lawrencesystems.com/t/xcp-ng-installing-citrix-agent-for-windows-via-powershell-script/13855

Write-Verbose "Loading Functions" -Verbose

function get-latestVersion {
    $uri = "https://pvupdates.vmd.citrix.com/updates.latest.tsv"
    $results = @()
    $temp = New-TemporaryFile
    wget $uri -OutFile $temp
    $raw = get-content $temp
    foreach ($line in $raw) 
    {
        $parts = $line.split("`t")
        $result = @{ 
            "URL"=$parts[0];
            "Version"=[version]$parts[1];
            "Size"=$parts[2];
            "Architecture"=$parts[3]
        }
        $results += $result
    }
    Write-Output $results
}

Write-Verbose "Setting Arguments" -Verbose
$StartDTM = (Get-Date)

$Vendor = "Citrix"
$Product = "XenServer"
$PackageName = "managementagentx64"
$Latest = get-latestVersion | ? architecture -eq "x64"
$Version = $Latest.version
$InstallerType = "msi"
$Source = "$PackageName" + "." + "$InstallerType"
$LogPS = "C:\Windows\Temp\$Vendor $Product $Version PS Wrapper.log"
$LogApp = "C:\Windows\Temp\XS65FP1.log"
$UnattendedArgs = "/i $PackageName.$InstallerType ALLUSERS=1 /Lv $LogApp /quiet /norestart"
$URL = $Latest.url

Start-Transcript $LogPS

if( -Not (Test-Path -Path $Version ) )
{
    New-Item -ItemType directory -Path $Version
}

CD $Version

Write-Verbose "Downloading $Vendor $Product $Version" -Verbose
If (!(Test-Path -Path $Source)) {
    Invoke-WebRequest -Uri $url -OutFile $Source
         }
        Else {
            Write-Verbose "File exists. Skipping Download." -Verbose
         }

Write-Verbose "Starting Installation of $Vendor $Product $Version" -Verbose
(Start-Process msiexec.exe -ArgumentList $UnattendedArgs -Wait -Passthru).ExitCode

Write-Verbose "Customization" -Verbose

Write-Verbose "Stop logging" -Verbose
$EndDTM = (Get-Date)
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalSeconds) Seconds" -Verbose
Write-Verbose "Elapsed Time: $(($EndDTM-$StartDTM).TotalMinutes) Minutes" -Verbose
Stop-Transcript