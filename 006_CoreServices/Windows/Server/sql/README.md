# SQL

* [SQL Server 2019 Evaluation Center](https://www.microsoft.com/en-us/evalcenter/download-sql-server-2019)
* [SQL Server 2022 Evaluation Center](https://www.microsoft.com/en-us/evalcenter/download-sql-server-2022)

## Links

* [SQLServerDsc](https://github.com/dsccommunity/SqlServerDsc/blob/main/source/Examples/Resources/SqlSetup/1-InstallDefaultInstanceSingleServer.ps1)
* [Step-By-Step: Creating a SQL Server Always On Availability Group](https://techcommunity.microsoft.com/t5/itops-talk-blog/step-by-step-creating-a-sql-server-always-on-availability-group/ba-p/648772) - MS techcommunity
* https://carlwebster.com/implementing-microsoft-sql-server-2016-standard-basic-availability-groups-use-citrix-virtual-apps-and-desktops/


## TCP listener

https://support.citrix.com/article/CTX200088/database-connection-issues-in-xendesktop-and-provisioning-services

SQL database cannot be accessed due to remote connections or firewall not being enabled. you need to add in the port (1433) to the SQL IP rather than leaving it as default all.

Open up SQL Server confugration manager → SQL server network configuration → properties of TCP/IP → IP Addresses tab → scroll to bottom and set the IP All TCP Port to 1433 (it should already be an empty box)
use - [Database Connection Issues in XenDesktop and Provisioning Services](https://support.citrix.com/article/CTX200088/database-connection-issues-in-xendesktop-and-provisioning-services) 1 for reference.