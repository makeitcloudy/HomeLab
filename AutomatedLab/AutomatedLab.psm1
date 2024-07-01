function Install-Modules
{
    <#
    .PARAMETER modules
    $modules = @{
    'Module1' = '1.0'
    'Module2' = '2.3'
    'Module3' = '3.5'
}
    #>
    param (
        [Parameter(Mandatory)]
        $modules
    )
    if ( -not(Get-PSRepository -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '*psgallery*' }) )
    {
        Write-Host -fore Magenta '>> Fixing PsGallery, please wait... <<'
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        Register-PSRepository -Default -Verbose
    }
    foreach ($moduleName in $modules.Keys)
    {
        $desiredVersion = $modules[$moduleName]
        $installedModule = Get-Module -Name $moduleName -ListAvailable -ErrorAction SilentlyContinue | Where-Object { $_.Version -eq $desiredVersion }
        if ($null -eq $installedModule)
        {
            try {
                Write-Verbose "$moduleName version $desiredVersion is not installed on $($Env:COMPUTERNAME). Installing..."
                Install-Module -Name $moduleName -RequiredVersion $desiredVersion -Force -Confirm:$false
                Write-Verbose "$moduleName version $desiredVersion has been installed on $($Env:COMPUTERNAME)."
            }

            catch {

            }

        }
        else
        {
            Write-Verbose "$moduleName version $desiredVersion is already installed on $($Env:COMPUTERNAME)."
        }
    }
}
