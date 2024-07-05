#Start-Process PowerShell_ISE -Verb RunAs
# https://www.itprotoday.com/powershell/use-powershell-to-initialize-a-disk-and-create-partitions
# Z: | GPT | data drive

$driveLetter = 'Z'
Get-Disk | Select-Object Number, IsOffline
#Initialize-Disk -Number 1 -PartitionStype GPT

$rawDisk = Get-Disk | Where-Object {$_.PartitionStyle -eq ‘Raw’}
$rawDisk | Initialize-Disk -PartitionStyle GPT
New-Partition -DiskNumber $rawDisk.DiskNumber -DriveLetter $driveLetter -UseMaximumSize
Format-Volume -DriveLetter $driveLetter -FileSystem NTFS
Get-ChildItem -Path $($driveLetter,':' -join '')
Get-PSDrive