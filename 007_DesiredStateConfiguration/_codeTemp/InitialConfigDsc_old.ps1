function Set-InitialConfiguration {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER mgmNodeIP
    .EXAMPLE
    .LINK
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$MgmtNodeIPAddress
    )
    
    BEGIN {
        $WarningPreference = "Continue"
        $VerbosePreference = "Continue"
        $InformationPreference = "Continue"
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - winRM configuration basics"
        $startDate = Get-Date
    }

PROCESS {
        # https://woshub.com/using-psremoting-winrm-non-domain-workgroup/

        #region server
        # Make sure that the WinRM service is running on the target user’s computer:
        Get-Service -Name "*WinRM*" | Select-Object status
        # If the service is not running, enable it:
        Enable-PSRemoting

        Get-NetConnectionProfile
        # if the network connection is set to public, need to change it to private
        Set-NetConnectionProfile -NetworkCategory Private
        # proof it's private
        #Get-NetConnectionProfile

        # Open firewall for the management node IP address

        Write-Information "Management Node IP Address : $($MgmtNodeIPAddress)"
        Set-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)" -RemoteAddress $mgmtNodeIP
        Enable-NetFirewallRule -DisplayName "Windows Remote Management (HTTP-In)"

        # The WinRM HTTP Listener on the remote computer only allows connection with Kerberos authentication.
        Get-ChildItem -Path WSMan:\localhost\Service\Auth\

        # Type            Name                           SourceOfValue   Value
        # ----            ----                           -------------   -----
        # System.String   Basic                                          false
        # System.String   Kerberos                                       true
        # System.String   Negotiate                                      true
        # System.String   Certificate                                    false
        # System.String   CredSSP                                        false
        # System.String   CbtHardeningLevel                              Relaxed

        Get-Item WSMan:\localhost\Client\TrustedHosts
    }

    END {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}