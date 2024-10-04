@{
    AllNodes = @(
    @{
            Role                 = 'newVM'                                            # targetNode
            #NodeName            = 'localhost'
            NodeName             = '*'
            #ComputerName        = 'w10mgmt'
            InterfaceAlias       = 'Eth0'
            WorkgroupDnsServers  = @('10.2.134.254')
            WorkgroupName        = 'Workgroup'
            DomainDnsServers     = @('10.2.134.1', '10.2.134.2')
            DomainName           = 'lab.local'
            JoinOu               = 'OU=Computers,DC=lab,DC=local'
            TrustedHosts         = 'localhost'
            #TrustedHosts        = 'localhost,10.2.134.201,10.2.134.202'               # Target Node IP addresses for winRM connectivity
            CertificateFile      = 'C:\dsc\certificate\dscSelfSignedCertificate.cer'   # The path to the .cer file containing the public key of the Encryption Certificate used to encrypt credentials for this node.
            #Thumbprint          = 'EF280FE58AC3E1B8BC211122866248282B44E7D8'          # The thumbprint of the Encryption Certificate used to decrypt the credentials on target node. The value of the thumbprint changes each time the Self Signed Certificate is generated

        },
        # MGMT Node
        @{
            Role                        = 'MgmtNode'
            NodeName                    = 'w10mgmt'
            IPV4Address                 = '10.2.134.249/24'                            # IP address should go hand in hand with Firewall rules for the remote management, otherwise it wont work
            DefaultGatewayAddress       = '10.2.134.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },
        # Active Directory Certification Services
        # ADCS Root - not added to the domain
        # ADCS Sub - domain joined
        @{
            Role                        = 'CertificationServices'
            NodeName                    = 'adcsr'
            IPV4Address                 = '10.2.134.3/24'
            DefaultGatewayAddress       = '10.2.134.254'            
            #JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },
        @{
            Role                        = 'CertificationServices'
            NodeName                    = 'adcss'
            IPV4Address                 = '10.2.134.4/24'
            DefaultGatewayAddress       = '10.2.134.254'
            #DomainName                  = 'lab.local'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },
        @{
            Role                        = 'CertificationServices'
            NodeName                    = 'adcsws'
            IPV4Address                 = '10.2.134.5/24'
            DefaultGatewayAddress       = '10.2.134.254'
            #DomainName                  = 'lab.local'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },
        # DHCP Server
        @{
            Role                        = 'DHCPServer'
            NodeName                    = 'dhcp01'
            IPV4Address                 = '10.2.134.6/24'
            DefaultGatewayAddress       = '10.2.134.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },
        # DHCP Server
        @{
            Role                        = 'DHCPServer'
            NodeName                    = 'dhcp02'
            IPV4Address                 = '10.2.134.7/24'
            DefaultGatewayAddress       = '10.2.134.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },
        # SQL Server
        @{
            DomainName             = 'lab.local'                      #FIXME: your domain FQDN
            DomainNetbiosName      = 'mot'                            #FIXME: your domain NetBIOS
            Role                   = 'SQLServer'
            NodeName               = 'sql01'
            IPV4Address            = '10.2.134.8/24'
            DefaultGatewayAddress  = '10.2.134.254'
            JoinOu                 = 'OU=Computers,DC=lab,DC=local'

            DataDriveSDiskId       = 1                                                   # SQL Data Disk
            DataDriveSLetter       = 'S'                                                 # SQL Data Disk Letter
            DataDriveSFSFormat     = 'NTFS'
            DataDriveSFSLabel      = 'sqlDB'
            DataDriveSPartitionStyle = 'GPT'

            SQLInstallSourcePath   = 'D:\'                          # SQL  -defaultInstance - SQL ISO is mounted here
            SQLDataDrive           = 'C:\'                          # TODO: change this to S:\ - drive designated for SQL db
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
            IPV4Address            = '10.2.134.9/24'
            DefaultGatewayAddress  = '10.2.134.254'
            JoinOu                 = 'OU=Computers,DC=lab,DC=local'
            DataDriveSDiskId       = 1                                                   # SQL Data Disk
            DataDriveSLetter       = 'S'                                                 # SQL Data Disk Letter
            DataDriveSFSFormat     = 'NTFS'
            DataDriveSFSLabel      = 'sqlDB'
            DataDriveSPartitionStyle = 'GPT'
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
        # File Server
        @{
            Role                        = 'FileServer'
            NodeName                    = 'fs01'
            IPV4Address                 = '10.2.134.11/24'
            DefaultGatewayAddress       = '10.2.134.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'

            DataDrivePDiskId            = 1    #Profile Disk
            DataDrivePLetter            = 'P'  #Profile Disk Letter
            DataDrivePFSFormat          = 'NTFS'
            DataDrivePFSLabel           = 'Profiles'
            DataDrivePPartitionStyle    = 'GPT'
        },
        @{
            Role                        = 'FileServer'
            NodeName                    = 'fs02'
            IPV4Address                 = '10.2.134.12/24'
            DefaultGatewayAddress       = '10.2.134.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'

            DataDrivePDiskId            = 1    #Profile Disk
            DataDrivePLetter            = 'P'  #Profile Disk Letter
            DataDrivePFSFormat          = 'NTFS'
            DataDrivePFSLabel           = 'Profiles'
            DataDrivePPartitionStyle    = 'GPT'
        },
        #ISCSI
        @{
            Role                        = 'IscsiServer'
            NodeName                    = 'iscsi'
            IPV4Address                 = '10.2.134.13/24'
            DefaultGatewayAddress       = '10.2.134.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'

            #storage - quorum drive
            QuorumDriveQDiskId          = 1                #order in which the drives are added to the target node ipacts Id
            QuorumDriveQLetter          = 'Q'
            QuorumDriveQFSFormat        = 'NTFS'
            QuorumDriveQFSLabel         = 'Quorum'
            QuorumDriveQPartitionStyle  = 'GPT'

            #storage - vhdx drive - for cluster setup
            VhdxDriveZDiskId            = 2
            VhdxDriveZLetter            = 'Z'
            VhdxDriveZFSFormat          = 'NTFS'
            VhdxDriveZFSLabel           = 'Storage_vhdx'
            VhdxDriveZPartitionStyle    = 'GPT'
        }
    )
}