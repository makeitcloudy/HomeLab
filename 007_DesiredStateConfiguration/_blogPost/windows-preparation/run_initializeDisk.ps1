#Start-Process PowerShell_ISE -Verb RunAs
# Run in elevated powershell session

# Anytime current code is updated, those changes should be reflected in the README.md file

# Disk should be connected to the VM, otherwise code won't work

# https://www.itprotoday.com/powershell/use-powershell-to-initialize-a-disk-and-create-partitions
# Z: | GPT | data drive

$driveLetter = 'Z'
$fileSystemLabel = 'dataDisk'
Get-Disk | Select-Object Number, IsOffline
#Initialize-Disk -Number 1 -PartitionStype GPT

$rawDisk = Get-Disk | Where-Object {$_.PartitionStyle -eq 'Raw'}
$rawDisk | Initialize-Disk -PartitionStyle GPT
New-Partition -DiskNumber $rawDisk.DiskNumber -DriveLetter $driveLetter -UseMaximumSize
Format-Volume -DriveLetter $driveLetter -FileSystem NTFS
get-volume -DriveLetter $driveLetter | Set-Volume -NewFileSystemLabel $fileSystemLabel
Get-ChildItem -Path $($driveLetter,':' -join '')
Get-PSDrive