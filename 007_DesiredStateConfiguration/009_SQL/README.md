# SQL

## SQL - DefaultInstance

2024.08.08 - SQL_defaultInstance_configuration.ps1 - works - tested with SQL 2019 
Once the SMS 17 has been installed on w10mgmt - connection to SQL instance worked
firewallON, no Firewall exceptions
at this point with MOT\administrator credentials

Tested on Desktop Experience

SMS Server Management Studio
Installed: 14.0.17289.0
Latest   : 20.2.30.0

**TODO:** add domain structure and groups and expand the configuration by SQLAdmins
**TODO:** Test the installation of SQL on SQL core

https://www.microsoft.com/en-us/evalcenter/download-sql-server-2017-rtm
https://www.microsoft.com/en-us/evalcenter/download-sql-server-2019
https://www.microsoft.com/en-us/evalcenter/download-sql-server-2022

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

```bash
xe vm-cd-insert vm='a_sql01_dexp' cd-name='SQLServer2019-x64-ENU.iso'
```

Unmount disk, after installation.


### 4. On MGMT Node - install SMSS

https://www.sqlservercentral.com/articles/install-ssms-using-powershell-dsc
SSMS-Setup-ENU.msi - 20.1.10.0 - msi available on the fileshare

[https://learn.microsoft.com/en-us/sql/ssms/release-notes-ssms?view=sql-server-ver16#previous-ssms-releases](SSMS earlier versions)

## X. Blog post - Initial Testing

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


## XX. Installation

FEATURES=SQLENGINE,AS /ASCONFIGDIR="C:\MSOLAP\Config" /QUIET="True" 
/SQLTEMPDBLOGDIR="C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Data" 
/AGTSVCACCOUNT="Administrator" 
/SQLBACKUPDIR="C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup" 
/SQLTEMPDBLOGFILEGROWTH="64" 
/IACCEPTSQLSERVERLICENSETERMS="True" 
/ACTION="Install" 
/ASSYSADMINACCOUNTS="\Administrator" "Administrator" "Administrator" 
/SQLSYSADMINACCOUNTS="\Administrator" "Administrator" "Administrator" 
/ASSERVERMODE="TABULAR" 
/INSTALLSHAREDDIR="C:\Program Files\Microsoft SQL Server" 
/SQLSVCPASSWORD="********" 
/SQLTEMPDBFILESIZE="1024" 
/AGTSVCPASSWORD="********" 
/ASLOGDIR="C:\MSOLAP\Log" 
/INSTALLSQLDATADIR="C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Data" 
/SQLTEMPDBFILEGROWTH="512" 
/SQLTEMPDBDIR="C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Data" 
/SQLCOLLATION="Latin1_General_100_CI_AS_KS" 
/ASTEMPDIR="C:\MSOLAP\Temp" 
/SQLUSERDBDIR="C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Data" 
/UPDATEENABLED="False" 
/ASDATADIR="C:\MSOLAP\Data" 
/SQLUSERDBLOGDIR="C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Data" 
/INSTANCENAME="MSSQLSERVER" 
/ASSVCPASSWORD="********" 
/INSTANCEDIR="C:\Program Files\Microsoft SQL Server" 
/INSTALLSHAREDWOWDIR="C:\Program Files (x86)\Microsoft SQL Server" 
/SQLTEMPDBLOGFILESIZE="128" 
/ASSVCACCOUNT="Administrator" 

/SQLTEMPDBFILECOUNT="4" 
/ASBACKUPDIR="C:\MSOLAP\Backup" 
/SQLSVCACCOUNT="Administrator"


### Troubleshooting 

C:\Program Files\Microsoft SQL Server\150\Setup Bootstrap\Log\20240715_145438

Summary_sql02_20240715.log