@{
    AllNodes = @(
    @{
            Role                 = 'newVM'
            #NodeName            = 'localhost'
            NodeName             = 'localhost'
            #ComputerName        = 'w10mgmt'
            InterfaceAlias       = 'Eth0'
            WorkgroupDnsServers  = @('10.2.134.254')
            WorkgroupName        = 'Workgroup'
            DomainDnsServers     = @('10.2.134.201', '10.2.134.202')
            DomainName           = 'lab.local'
            JoinOu               = 'OU=Computers,DC=lab,DC=local'
            TrustedHosts         = 'localhost'
            #TrustedHosts        = 'localhost,10.2.134.201,10.2.134.202'               # Target Node IP addresses for winRM connectivity
            CertificateFile      = 'C:\dsc\certificate\dscSelfSignedCertificate.cer'   # The path to the .cer file containing the public key of the Encryption Certificate used to encrypt credentials for this node.
            #Thumbprint          = 'EF280FE58AC3E1B8BC211122866248282B44E7D8'          # The thumbprint of the Encryption Certificate used to decrypt the credentials on target node. The value of the thumbprint changes each time the Self Signed Certificate is generated

        },
        @{
            Role                = 'FileServer'
            NodeName            = 'fs01'
            JoinOu              = 'OU=Computers,DC=lab,DC=local'
            DataDrivePDiskId    = 1    #Profile Disk
            DataDrivePLetter    = 'P'  #Profile Disk Letter
        },
        @{
            Role                = 'FileServer'
            NodeName            = 'fs02'
            JoinOu              = 'OU=Computers,DC=lab,DC=local'
            DataDrivePDiskId    = 1    #Profile Disk
            DataDrivePLetter    = 'P'  #Profile Disk Letter
        },
        @{
            DomainName             = 'lab.local'                      #FIXME: your domain FQDN
            DomainNetbiosName      = 'mot'                            #FIXME: your domain NetBIOS
            Role                   = 'SQLServer'
            NodeName               = 'sql01'
            JoinOu                 = 'OU=Computers,DC=lab,DC=local'
            DataDriveSDiskId       = 1                                                   # SQL Data Disk
            DataDriveSLetter       = 'S'                                                 # SQL Data Disk Letter
            SQLInstallSourcePath   = 'D:\'                                               # SQL  -defaultInstance - SQL ISO is mounted here
            SQLDataDrive           = 'C:\'
            Instances = @(
                @{
                    Name           = 'MSSQLSERVER'
                    Features       = 'SQLENGINE,AS'
                    #Features       = 'SQLENGINE,FULLTEXT,RS,AS,IS'
                }
            )            
            SQLAdminAccount        = 'Administrator'
            InstallManagementTools = $False
            CertificateFile        = 'C:\dsc\certificate\dscSelfSignedCertificate.cer'   # The path to the .cer file containing the public key of the Encryption Certificate used to encrypt credentials for this node.
        },
        @{
            DomainName             = 'lab.local'                      #FIXME: your domain FQDN
            DomainNetbiosName      = 'mot'                            #FIXME: your domain NetBIOS
            Role                   = 'SQLServer'
            NodeName               = 'sql02'
            JoinOu                 = 'OU=Computers,DC=lab,DC=local'
            DataDriveSDiskId       = 1                                                   # SQL Data Disk
            DataDriveSLetter       = 'S'                                                 # SQL Data Disk Letter
            SQLInstallSourcePath   = 'D:\'                                               # SQL  -defaultInstance - SQL ISO is mounted here
            SQLDataDrive           = 'C:\'
            Instances = @(
                @{
                    Name           = 'MSSQLSERVER'
                    Features       = 'SQLENGINE,AS'
                    #Features       = 'SQLENGINE,FULLTEXT,RS,AS,IS'
                }
            )            
            SQLAdminAccount        = 'Administrator'  # TODO: there should be a domain account/group existing already, during AD setup - at this stage (2024.07.15) - domain admin is also the SQL administrator
            InstallManagementTools = $False
            CertificateFile        = 'C:\dsc\certificate\dscSelfSignedCertificate.cer'   # The path to the .cer file containing the public key of the Encryption Certificate used to encrypt credentials for this node.
        }        
    )
}