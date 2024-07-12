<#
    .DESCRIPTION
        This example shows how to install a default instance of SQL Server, and
        Analysis Services in Tabular mode, on a single server.
        It contains configurations that apply to Sql Server 2016 or later only.

    .NOTES
        SQL Server setup is run using the SYSTEM account. Even if SetupCredential is provided
        it is not used to install SQL Server at this time (see issue #139).

        SQL 2019 is supported - 7.15 CU6 - 2402

    .LINK
        https://www.microsoft.com/en-us/sql-server/sql-server-downloads

    .LINK
        https://github.com/dsccommunity/SqlServerDsc/blob/main/source/Examples/Resources/SqlSetup/7-InstallDefaultInstanceSingleServer2016OrLater.ps1

    .LINK
        https://support.citrix.com/article/CTX114501/supported-databases-for-virtual-apps-and-desktops-and-citrix-provisioning-pvs

    .LINK
        https://support.citrix.com/article/CTX262776/faq-recommended-database-collations-for-citrix-products

    .LINK
        https://www.carlwebster.com/downloads/download-info/pdf-building-websters-lab-v2-1/

    .LINK
        https://carlwebster.sharefile.com/d-s7b19fcb822e4479b9af75572afdb6291
        #>

Configuration sqlDefaultInstance2016orLater
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $SqlInstallCredential,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $SqlAdministratorCredential = $SqlInstallCredential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $SqlServiceCredential,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $SqlAgentServiceCredential = $SqlServiceCredential
    )

    Import-DscResource -ModuleName 'xPSDesiredStateConfiguration' -ModuleVersion '9.1.0'
    Import-DscResource -ModuleName 'SqlServerDsc'

    Node $AllNodes.NodeName {

        #region Install prerequisites for SQL Server

        ## it is assumed that the .NET 3.5 is available and installed as a feature on the OS already
        ## here it is done during the OSD phase - preparation of the unatended ISO

        ##    [X] .NET Framework 3.5 Features                     NET-Framework-Features         Installed
        ##    [X] .NET Framework 3.5 (includes .NET 2.0 and 3.0)  NET-Framework-Core             Installed
        ##    [ ] HTTP Activation                                 NET-HTTP-Activation            Available
        ##    [ ] Non-HTTP Activation                             NET-Non-HTTP-Activ             Available
        ##[X] .NET Framework 4.8 Features                         NET-Framework-45-Fea...        Installed
        ##    [X] .NET Framework 4.8                              NET-Framework-45-Core          Installed
        ##   [ ] ASP.NET 4.8                                      NET-Framework-45-ASPNET        Available
        ##    [X] WCF Services                                    NET-WCF-Services45             Installed
        ##        [ ] HTTP Activation                             NET-WCF-HTTP-Activat...        Available
        ##        [ ] Message Queuing (MSMQ) Activation           NET-WCF-MSMQ-Activat...        Available
        ##        [ ] Named Pipe Activation                       NET-WCF-Pipe-Activat...        Available
        ##        [ ] TCP Activation                              NET-WCF-TCP-Activati...        Available
        ##        [X] TCP Port Sharing                            NET-WCF-TCP-PortShar...        Installed

        #WindowsFeature 'NetFramework35'
        #{
        #    Name   = 'NET-Framework-Core'
        #    Source = '\\fileserver.company.local\images$\Win2k12R2\Sources\Sxs' # Assumes built-in Everyone has read permission to the share and path.
        #    Ensure = 'Present'
        #}

        #region storage
        WaitforDisk DataDriveProfile
        {
            DiskId           = $Node.DataDrivePDiskId
            RetryIntervalSec = 60
            RetryCount       = 60
            #DependsOn        = '[Computer]JoinDomain'
        }

        Disk VolumeProfile
        {
            DiskId      = $Node.DataDrivePDiskId
            DriveLetter = $Node.DataDrivePLetter
            DependsOn   = '[WaitforDisk]DataDriveProfile'
        }
        #endregion

        WindowsFeature 'NetFramework45'
        {
            Name   = 'NET-Framework-45-Core'
            Ensure = 'Present'
            DependsOn = '[Disk]VolumeProfile'
        }
        #endregion Install prerequisites for SQL Server

        #region Install SQL Server
        foreach ($Instance in $Node.Instances)
        {
            $Features = $Instance.Features
            if ([System.String]::IsNullOrEmpty($Features))
            {
                #$Features = 'SQLENGINE,FULLTEXT,RS,AS,IS'
                $Features = 'SQLENGINE,AS'
            } # if

            SqlSetup ($Instance.Name)
            {
                # SQL Server 2016 — C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\
                # SQL Server 2017 — C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\
                # SQL Server 2019 — C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\
                # SQL Server 2022 — C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\

                ForceReboot            = $false
                UpdateEnabled          = 'False'
                SourcePath             = $Node.SourcePath
                InstanceName           = $Instance.Name
                Features               = $Features
                #SQLSysAdminAccounts    = 'MOT\Domain Administrators', $SqlAdministratorCredential.UserName
                SQLSysAdminAccounts    = "$($Node.DomainName)\$($Node.SQLAdminAccount)", $SqlAdministratorCredential.UserName
                #ASSysAdminAccounts     = 'MOT\Domain Administrators', $SqlAdministratorCredential.UserName
                ASSysAdminAccounts     = "$($Node.DomainName)\$($Node.SQLAdminAccount)", $SqlAdministratorCredential.UserName
                InstallSharedDir       = "$($Node.SQLDataDrive):\Program Files\Microsoft SQL Server"
                InstallSharedWOWDir    = "$($Node.SQLDataDrive):\Program Files (x86)\Microsoft SQL Server"
                InstanceDir            = "$($Node.SQLDataDrive):\Program Files\Microsoft SQL Server"
                InstallSQLDataDir      = "$($Node.SQLDataDrive):\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Data"
                SQLUserDBDir           = "$($Node.SQLDataDrive):\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Data"
                SQLUserDBLogDir        = "$($Node.SQLDataDrive):\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Data"
                SQLTempDBDir           = "$($Node.SQLDataDrive):\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Data"
                SQLTempDBLogDir        = "$($Node.SQLDataDrive):\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Data"
                SQLBackupDir           = "$($Node.SQLDataDrive):\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup"
                
                ASDataDir              = 'C:\MSOLAP\Data'
                ASLogDir               = 'C:\MSOLAP\Log'
                ASBackupDir            = 'C:\MSOLAP\Backup'
                ASTempDir              = 'C:\MSOLAP\Temp'
                SQLCollation           = 'Latin1_General_100_CI_AS_KS' #https://www.carlstalhood.com/delivery-controller-2402-ltsr-and-licensing/
                SQLSvcAccount          = $SqlServiceCredential
                AgtSvcAccount          = $SqlAgentServiceCredential
                ASSvcAccount           = $SqlServiceCredential
                ASServerMode           = 'TABULAR'
                ASConfigDir            = 'C:\MSOLAP\Config'
                SqlTempdbFileCount     = 4
                SqlTempdbFileSize      = 1024
                SqlTempdbFileGrowth    = 512
                SqlTempdbLogFileSize   = 128
                SqlTempdbLogFileGrowth = 64
                PsDscRunAsCredential   = $SqlInstallCredential
                #DependsOn              = '[WindowsFeature]NetFramework35', '[WindowsFeature]NetFramework45'
                DependsOn              = '[WindowsFeature]NetFramework45'
            }

            SqlServerFirewall ($Instance.Name)
            {
                # https://support.citrix.com/article/CTX200088/database-connection-issues-in-xendesktop-and-provisioning-services
                SourcePath   = $Node.SourcePath
                InstanceName = $Instance.Name
                Features     = $Features
                DependsOn    = "[SqlServerSetup]$($Instance.Name)"
            }
        }

        if ($Node.InstallManagementTools)
        {
            SqlServerSetup SQLMT
            {
                SourcePath           = $Node.SourcePath
                InstanceName         = 'NULL'
                Features             = 'SSMS,ADV_SSMS'
                PsDscRunAsCredential = $InstallerCredential
                DependsOn            = '[Computer]JoinDomain', '[WindowsFeature]NET35Install'
            }
        }
        #endregion Install SQL Server
    }
        
}