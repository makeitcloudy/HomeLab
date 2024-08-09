        #region - Domain Setup - OPTIONAL - STARTER ORGANIZATIONAL UNITS
        
        #lab.local/_Governed
        #OU=_Governed,DC=lab,DC=local
        ADOrganizationalUnit '_GovernedOU'
        {
            Name       = '_Governed'
            Path       = $DomainContainer
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[WaitForADDomain]WaitForDomainInstall'
        }

        #region /lab.local/_Governed/Accounts

        ADOrganizationalUnit '_GovernedAccountsOU'
        {
            Name       = 'Accounts'
            Path       = "OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedOU'
        }
        
        #/lab.local/_Governed/Accounts/Admin
        ADOrganizationalUnit '_GovernedAccountsAdminOU'
        {
            Name       = 'Admin'
            Path       = "OU=Accounts,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedAccountsOU'
        }

        #/lab.local/_Governed/Accounts/Service
        ADOrganizationalUnit '_GovernedAccountsServiceOU'
        {
            Name       = 'Service'
            Path       = "OU=Accounts,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedAccountsOU'
        }
        
        #/lab.local/_Governed/Accounts/User
        ADOrganizationalUnit '_GovernedAccountsUserOU'
        {
            Name       = 'User'
            Path       = "OU=Accounts,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedAccountsOU'
        }
        #endregion

        #region /lab.local/_Governed/Groups
        ADOrganizationalUnit '_GovernedGroupsOU'
        {
            Name       = 'Groups'
            Path       = "OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedOU'        
        }
        #/lab.local/_Governed/Groups/Admin
        ADOrganizationalUnit '_GovernedGroupsAdminOU'
        {
            Name       = 'Admin'
            Path       = "OU=Groups,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedGroupsOU'
        }
        #/lab.local/_Governed/Groups/User
        ADOrganizationalUnit '_GovernedGroupsUserOU'
        {
            Name       = 'User'
            Path       = "OU=Groups,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedGroupsOU'
        }
        #/lab.local/_Governed/Groups/Application
        ADOrganizationalUnit '_GovernedGroupsApplicationOU'
        {
            Name       = 'Application'
            Path       = "OU=Groups,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedGroupsOU'
        }
        #endregion

        #/lab.local/_Governed/Infra
        ADOrganizationalUnit '_GovernedInfraOU'
        {
            Name       = 'Infra'
            Path       = "OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedOU'        
        }
        
        #region /lab.local/_Governed/Infra/Citrix
        ADOrganizationalUnit '_GovernedInfraCitrixOU'
        {
            Name       = 'Citrix'
            Path       = "OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraOU'
        }
        #/lab.local/_Governed/Infra/Citrix/CVAD
        ## GPO: Citrix VDA Computer Settings -> User configuration settings disabled
        ## GPO: Citrix VDA Users All (including Admins) -> Computer configuration settings disabled
        ## GPO: Citrix VDA USers Non-Admins (lockdown) -> Computer configuration settings disabled
        ADOrganizationalUnit '_GovernedInfraCitrixCVADOU'
        {
            Name       = 'CVAD'
            Path       = "OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixOU'
        }

        #/lab.local/_Governed/Infra/Citrix/CVAD/RDSH2008R2
        ADOrganizationalUnit '_GovernedInfraCitrixCVADRDSH2008R2OU'
        {
            Name       = 'RDSH2008R2'
            Path       = "OU=CVAD,OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixCVADOU'
        }

        #/lab.local/_Governed/Infra/Citrix/CVAD/RDSH2012R2
        ADOrganizationalUnit '_GovernedInfraCitrixCVADRDSH2012R2OU'
        {
            Name       = 'RDSH2012R2'
            Path       = "OU=CVAD,OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixCVADOU'
        }
        
        #/lab.local/_Governed/Infra/Citrix/CVAD/RDSH2016
        ADOrganizationalUnit '_GovernedInfraCitrixCVADRDSH2016OU'
        {
            Name       = 'RDSH2016'
            Path       = "OU=CVAD,OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixCVADOU'
        }        

        #/lab.local/_Governed/Infra/Citrix/CVAD/RDSH2019
        ADOrganizationalUnit '_GovernedInfraCitrixCVADRDSH2019'
        {
            Name       = 'RDSH2019'
            Path       = "OU=CVAD,OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixCVADOU'
        }

        #/lab.local/_Governed/Infra/Citrix/CVAD/RDSH2019-Office
        ADOrganizationalUnit '_GovernedInfraCitrixCVADRDSH2019-OfficeOU'
        {
            Name       = 'RDSH2019-Office'
            Path       = "OU=CVAD,OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixCVADOU'
        }

        #/lab.local/_Governed/Infra/Citrix/CVAD/RDSH2019-App0
        ADOrganizationalUnit '_GovernedInfraCitrixCVADRDSH2019-App0OU'
        {
            Name       = 'RDSH2019-App0'
            Path       = "OU=CVAD,OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixCVADOU'
        }
        #/lab.local/_Governed/Infra/Citrix/CVAD/RDSH2022
        ADOrganizationalUnit '_GovernedInfraCitrixCVADRDSH2022OU'
        {
            Name       = 'RDSH2022'
            Path       = "OU=CVAD,OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixCVADOU'
        }

        #/lab.local/_Governed/Infra/Citrix/CVAD/RDSH2022-Office
        ADOrganizationalUnit '_GovernedInfraCitrixCVADRDSH2022-OfficeOU'
        {
            Name       = 'RDSH2022-Office'
            Path       = "OU=CVAD,OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixCVADOU'
        }

        #/lab.local/_Governed/Infra/Citrix/CVAD/RDSH2022-App0
        ADOrganizationalUnit '_GovernedInfraCitrixCVADRDSH2022-App0OU'
        {
            Name       = 'RDSH2022-App0'
            Path       = "OU=CVAD,OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixCVADOU'
        }

        #/lab.local/_Governed/Infra/Citrix/CVAD/RDSH2025
        ADOrganizationalUnit '_GovernedInfraCitrixCVADRDSH2025'
        {
            Name       = 'RDSH2025'
            Path       = "OU=CVAD,OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixCVADOU'
        }

        #/lab.local/_Governed/Infra/Citrix/CVAD/RDSH2025-Office
        ADOrganizationalUnit '_GovernedInfraCitrixCVADRDSH2025-OfficeOU'
        {
            Name       = 'RDSH2025-Office'
            Path       = "OU=CVAD,OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixCVADOU'
        }        

        #/lab.local/_Governed/Infra/Citrix/CVAD/RDSH2025-App0
        ADOrganizationalUnit '_GovernedInfraCitrixCVADRDSH2025-App0OU'
        {
            Name       = 'RDSH2025-App0'
            Path       = "OU=CVAD,OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixCVADOU'
        }        
        #/lab.local/_Governed/Infra/Citrix/CVAD/Win11Common
        ADOrganizationalUnit '_GovernedInfraCitrixCVADWin11CommonOU'
        {
            Name       = 'Win11Common'
            Path       = "OU=CVAD,OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixCVADOU'
        }        
        #/lab.local/_Governed/Infra/Citrix/CVAD/Win10Common
        ADOrganizationalUnit '_GovernedInfraCitrixCVADWin10CommonOU'
        {
            Name       = 'Win10Common'
            Path       = "OU=CVAD,OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixCVADOU'
        }

        #/lab.local/_Governed/Infra/Citrix/CVAD/Win7Common
        ADOrganizationalUnit '_GovernedInfraCitrixCVADWin7CommonOU'
        {
            Name       = 'Win7Common'
            Path       = "OU=CVAD,OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixCVADOU'
        }        

        #/lab.local/_Governed/Infra/Citrix/CVAD/Win7-App0
        ADOrganizationalUnit '_GovernedInfraCitrixCVADWin7-App0OU'
        {
            Name       = 'Win7-App0'
            Path       = "OU=CVAD,OU=Citrix,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraCitrixCVADOU'
        }
        #endregion

        #region /lab.local/_Governed/Infra/Microsoft
        ADOrganizationalUnit '_GovernedInfraMicrosoftOU'
        {
            Name       = 'Microsoft'
            Path       = "OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraOU'
        }

        #/lab.local/_Governed/Infra/Microsoft/ADCS
        ADOrganizationalUnit '_GovernedInfraMicrosoftADCSOU'
        {
            Name       = 'ADCS'
            Path       = "OU=Microsoft,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraMicrosoftOU'
        }

        #/lab.local/_Governed/Infra/Microsoft/DHCP
        ADOrganizationalUnit '_GovernedInfraMicrosoftDHCPOU'
        {
            Name       = 'DHCP'
            Path       = "OU=Microsoft,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraMicrosoftOU'
        }

        #/lab.local/_Governed/Infra/Microsoft/FS
        ADOrganizationalUnit '_GovernedInfraMicrosoftFSOU'
        {
            Name       = 'FS'
            Path       = "OU=Microsoft,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraMicrosoftOU'
        }

        #region /lab.local/_Governed/Infra/Microsoft/RDS
        ADOrganizationalUnit '_GovernedInfraMicrosoftRDSOU'
        {
            Name       = 'RDS'
            Path       = "OU=Microsoft,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraMicrosoftOU'
        }

        #/lab.local/_Governed/Infra/Microsoft/RDS/RDGW
        ADOrganizationalUnit '_GovernedInfraMicrosoftRDSRDGWOU'
        {
            Name       = 'RDGW'
            Path       = "OU=RDS,OU=Microsoft,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraMicrosoftRDSOU'
        }
        #/lab.local/_Governed/Infra/Microsoft/RDS/RDCB
        ADOrganizationalUnit '_GovernedInfraMicrosoftRDSRDCBOU'
        {
            Name       = 'RDCB'
            Path       = "OU=RDS,OU=Microsoft,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraMicrosoftRDSOU'
        }
        #/lab.local/_Governed/Infra/Microsoft/RDS/RDWI
        ADOrganizationalUnit '_GovernedInfraMicrosoftRDSRDWIOU'
        {
            Name       = 'RDWI'
            Path       = "OU=RDS,OU=Microsoft,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraMicrosoftRDSOU'
        }

        #/lab.local/_Governed/Infra/Microsoft/RDS/RDSH
        ADOrganizationalUnit '_GovernedInfraMicrosoftRDSRDSHOU'
        {
            Name       = 'RDSH'
            Path       = "OU=RDS,OU=Microsoft,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraMicrosoftRDSOU'
        }

        #/lab.local/_Governed/Infra/Microsoft/RDS/VDI
        ADOrganizationalUnit '_GovernedInfraMicrosoftRDSVDIOU'
        {
            Name       = 'VDI'
            Path       = "OU=RDS,OU=Microsoft,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraMicrosoftRDSOU'
        }
        #endregion

        #/lab.local/_Governed/Infra/Microsoft/SQL
        ADOrganizationalUnit '_GovernedInfraMicrosoftSQLOU'
        {
            Name       = 'SQL'
            Path       = "OU=Microsoft,OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraMicrosoftOU'
        }
        #endregion

        #/lab.local/_Governed/Infra/Parallels
        ADOrganizationalUnit '_GovernedInfraParallelsOU'
        {
            Name       = 'Parallels'
            Path       = "OU=Infra,OU=_Governed,$DomainContainer"
            Ensure     = 'Present'
            Credential = $DomainCredential
            DependsOn  = '[ADOrganizationalUnit]_GovernedInfraOU'
        }
        #endregion

        #region - Domain Setup - OPTIONAL -  ACCOUNTS
        # https://github.com/dsccommunity/ActiveDirectoryDsc/wiki/ADUser
        #region - Domain Setup - OPTIONAL -  ACCOUNTS - /lab.local/_Governed/Accounts/Admin
        ADUser 'a_piotr'
        {
            Ensure                = 'Present'
            Enabled               = $true
            DomainName            = $Node.DomainName
            Path                  = "OU=Admin,OU=Accounts,OU=_Governed,$DomainContainer"
            UserPrincipalName     = "a_piotr@lab.local"
            UserName              = 'a_piotr'
            DisplayName           = 'a_piotr'
            Description           = 'Administrative Account'
            
            Password              = 'Password1$'
            #PasswordNeverResets  = $true
            PasswordNeverExpires  = $false
            ChangePasswordAtLogon = $false
            
            #PsDscRunAsCredential = [PSCredential]]
            DependsOn             = '[ADOrganizationalUnit]_GovernedAccountsAdminOU'
        }
        #endregion
        
        #region - Domain Setup - OPTIONAL -  ACCOUNTS - /lab.local/_Governed/Accounts/Service
        ADUser 'svc_ctxsqldb'
        {
            Ensure                = 'Present'
            Enabled               = $true
            DomainName            = $Node.DomainName
            Path                  = "OU=Admin,OU=Accounts,OU=_Governed,$DomainContainer"
            UserPrincipalName     = "svc_ctxsqldb@lab.local"
            UserName              = 'svc_ctxsqldb'
            DisplayName           = 'svc_ctxsqldb'
            Description           = 'SQL - Service Account - Citrix related'
            Password              = 'Password1$'
            #PasswordNeverResets  = $true
            PasswordNeverExpires  = $false
            ChangePasswordAtLogon = $false
            
            #PsDscRunAsCredential = [PSCredential]]
            DependsOn             = '[ADOrganizationalUnit]_GovernedAccountsServiceOU'
        }
        #endregion
        
        #region - Domain Setup - OPTIONAL -  ACCOUNTS - /lab.local/_Governed/Accounts/User
        #ADUser 'u_piotr'
        #{
        #    Ensure              = 'Present'
        #    UserName            = 'u_piotr'
        #    Password            = 'Password1$'
        #    PasswordNeverResets = $true
        #    DomainName          = $Node.DomainName
        #    Path                = "OU=User,OU=Accounts,OU=_Governed,$DomainContainer"
        #    DependsOn           = '[ADOrganizationalUnit]_GovernedAccountsUserOU'
        #}        
        ADUser 'u_piotr'
        {
            Ensure                = 'Present'
            Enabled               = $true
            DomainName            = $Node.DomainName
            Path                  = "OU=Admin,OU=Accounts,OU=_Governed,$DomainContainer"
            UserPrincipalName     = "a_piotr@lab.local"
            UserName              = 'a_piotr'
            DisplayName           = 'a_piotr'
            Description           = 'string'
            Password              = 'Password1$'
            #PasswordNeverResets  = $true
            PasswordNeverExpires  = $false
            ChangePasswordAtLogon = $false
            #PsDscRunAsCredential = [PSCredential]]
            DependsOn             = '[ADOrganizationalUnit]_GovernedAccountsUserOU'
        }
        #endregion
        
        #endregion

        #region Domain Setup - OPTIONAL - GROUPS
        #region Domain Setup - OPTIONAL - GROUPS - /lab.local/_Governed/Groups/Admin
        #endregion
        
        #region Domain Setup - OPTIONAL - GROUPS - /lab.local/_Governed/Groups/User
        #endregion

        #region Domain Setup - OPTIONAL - GROUPS - /lab.local/_Governed/Groups/Application
        #endregion

        #endregion