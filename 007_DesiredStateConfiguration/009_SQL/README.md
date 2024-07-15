# SQL

## SQL - DefaultInstance

### 1. SQL - DefaultInstance -  VM provisioning

```bash
# Provision VM

# Add extra disk
/opt/scripts/vm_add_disk.sh --vmName 'a_sql01_dexp' --storageName 'node4_hdd_sdc_lsi' --diskName 'a_sql01_dexp_SDrive' --deviceId 4 --diskGB 10  --description 'a_sql01_dexp_SdataDrive'
```

Do not have to initialize the drive with PowerShell. Desired State resource from StorageDsc module handles that.


### 2. SQL - DefaultInstance - VMTools installation

```

```

### 3. SQL - DefaultInstance - Mount SQL

xe vm-cd-insert vm='a_sql01_dexp' cd-name='SQLServer2019-x64-ENU.iso'

### Initial Testing

```powershell
#Start-Process PowerShell_ISE -Verb RunAs
# run in elevated PowerShell session
Set-Location -Path "$env:USERPROFILE\Documents"

#$sqlDefaultInstanceConfiguration = 'SQL_defaultInstance_configuration.ps1'
#$sqlDefaultInstanceSetup = 'SQL_defaultInstance_setup.ps1'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/009_SQL/SQL_defaultInstance_configuration.ps1' -OutFile "$env:USERPROFILE\Documents\SQL_defaultInstance_configuration.ps1" -Verbose
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/009_SQL/SQL_defaultInstance_setup.ps1' -OutFile "$env:USERPROFILE\Documents\SQL_defaultInstance_setup.ps1" -Verbose
#psedit "$env:USERPROFILE\Documents\SQL_defaultInstance_setup.ps1"
#psedit "$env:USERPROFILE\Documents\SQL_defaultInstance_configuration.ps1"

# at this stage the computername is already renamed and it's name is : dc01
#. "$env:USERPROFILE\Documents\ActiveDirectory_demo.ps1" -ComputerName $env:Computername
```