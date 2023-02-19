Import-Module OSDBuilder
# windows 2019 datacenter core
Import-OSmedia -ShowInfo
Import-OSMedia -ImageIndex 3 -SkipGrid -Update -BuildNetFX -Verbose
New-OSBMediaISO -FullName 'O:\OSDBuilder\OSBuilds\Windows Server 2019 Standard Evaluation x64 1809 17763.4010'
get-help Import-OSMedia -ShowWindow


# windows 2019 desktop experience datacenter
Import-OSmedia -ShowInfo
Import-OSMedia -ImageIndex 4 -SkipGrid -Update -BuildNetFX -Verbose
New-OSBMediaISO -FullName 'O:\OSDBuilder\OSBuilds\Windows Server 2019 Datacenter Evaluation Desktop Experience x64 1809 17763.4010'

# windows 2022 desktop experience datacenter
Import-OSmedia -ShowInfo
Import-OSMedia -ImageIndex 4 -SkipGrid -Update -BuildNetFX -Verbose
New-OSBMediaISO -FullName 'O:\OSDBuilder\OSBuilds\Windows Server 2022 Datacenter Evaluation Desktop Experience x64 21H2 20348.1547'

# windows 2022 datacenter core
Import-OSmedia -ShowInfo
Import-OSMedia -ImageIndex 3 -SkipGrid -Update -BuildNetFX -Verbose
New-OSBMediaISO -FullName 'O:\OSDBuilder\OSBuilds\Windows Server 2022 Datacenter Evaluation x64 21H2 20348.1547'
