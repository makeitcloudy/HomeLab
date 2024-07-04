function Get-GitModule {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER One
    .PARAMETER Two
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
        
        [CmdletBinding()]
        Param
        (
            [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            $GithubUserName,

            [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            $ModuleName
        )
    
        BEGIN
        {
            $WarningPreference = "Continue"
            $VerbosePreference = "Continue"
            $InformationPreference = "Continue"
            Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - It downloads module from Github repository"
            $startDate = Get-Date

            #initialize variables
            #$ModuleName                    = "AutomatedLab"
            #$GitHubUserName                = 'makeitcloudy'
            $repoUrl                       = 'https://github.com',$GithubUserName,$ModuleName,'archive/refs/heads/main.zip' -join '/'

            $modulePath                    = "C:\Program Files\WindowsPowerShell\Modules\$ModuleName"

            $tempZipFileName               = $ModuleName,'.zip' -join ''
            $tempZipFullPath               = "$env:TEMP",$tempZipFileName -join '\'

            $extractedModuleTempFolderName = $ModuleName,'main' -join '-'
            $extractedModuleTempFullPath   = "$env:TEMP",$extractedModuleTempFolderName,$ModuleName -join '\'

        }
    
        PROCESS
        {
            try {
                # download the module from github
                Invoke-WebRequest -Uri $repoUrl -OutFile $tempZipFullPath
                # expand the archive to \AppData\Local\Temp
                Expand-Archive -Path $tempZipFullPath -DestinationPath $env:TEMP
                # copy the module folder from the repo directory to the C:\Program Files\WindowsPowerShell\Modules\[moduleName]
                Copy-Item -Path $extractedModuleTempFullPath -Destination $modulePath -Recurse -Force

                #cleanup
                # remove the downloaded repository zip file
                Remove-Item -Path $tempZipFullPath -Force
                # remove the extracted repository folder from the \AppData\Local\Temp
                Remove-Item -Path $(Join-Path -Path $env:TEMP -ChildPath $extractedModuleTempFolderName) -Recurse -Force
            }
            catch {
    
            }
        }
    
        END
        {
            $endDate = Get-Date
            Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
        }
    }