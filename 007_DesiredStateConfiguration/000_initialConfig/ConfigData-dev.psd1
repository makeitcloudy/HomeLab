@{
    AllNodes = @(
    @{
            Role                 = 'newVM'                                            # targetNode
            #NodeName            = 'localhost'
            NodeName             = '*'
            #ComputerName        = 'w10mgmt'
            InterfaceAlias       = 'Eth0'
            WorkgroupDnsServers  = @('10.2.154.254')
            WorkgroupName        = 'Workgroup'
            DomainDnsServers     = @('10.2.154.1', '10.2.154.2')
            DomainName           = 'd.local'
            JoinOu               = 'OU=Computers,DC=d,DC=local'
            TrustedHosts         = 'localhost'
            #TrustedHosts        = 'localhost,10.2.134.201,10.2.134.202'               # Target Node IP addresses for winRM connectivity
            CertificateFile      = 'C:\dsc\certificate\dscSelfSignedCertificate.cer'   # The path to the .cer file containing the public key of the Encryption Certificate used to encrypt credentials for this node.
            #Thumbprint          = 'EF280FE58AC3E1B8BC211122866248282B44E7D8'          # The thumbprint of the Encryption Certificate used to decrypt the credentials on target node. The value of the thumbprint changes each time the Self Signed Certificate is generated

        },
        #region - Role = 'MgmtNode' - MGMT Node
        @{
            Role                        = 'MgmtNode'
            NodeName                    = 'b2-w10mgmt'
            IPV4Address                 = '10.2.154.249/24'                            # IP address should go hand in hand with Firewall rules for the remote management, otherwise it wont work
            DefaultGatewayAddress       = '10.2.154.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },
        #endregion

        #region - 'Role = CertificationServices'
        # Active Directory Certification Services
        # ADCS Root - not added to the domain
        # ADCS Sub - domain joined
        @{
            Role                        = 'CertificationServices'
            NodeName                    = 'b2-adcsr'
            IPV4Address                 = '10.2.154.3/24'
            DefaultGatewayAddress       = '10.2.154.254'            
            #JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },
        @{
            Role                        = 'CertificationServices'
            NodeName                    = 'b2-adcss'
            IPV4Address                 = '10.2.154.4/24'
            DefaultGatewayAddress       = '10.2.154.254'
            #DomainName                  = 'lab.local'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },
        @{
            Role                        = 'CertificationServices'
            NodeName                    = 'b2-adcsws'
            IPV4Address                 = '10.2.154.5/24'
            DefaultGatewayAddress       = '10.2.154.254'
            #DomainName                  = 'lab.local'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },
        #endregion

        #region - 'Role = DHCPServer'
        @{
            Role                        = 'DHCPServer'
            NodeName                    = 'b2-dhcp01'
            IPV4Address                 = '10.2.154.6/24'
            DefaultGatewayAddress       = '10.2.154.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },
        # DHCP Server
        @{
            Role                        = 'DHCPServer'
            NodeName                    = 'b2-dhcp02'
            IPV4Address                 = '10.2.154.7/24'
            DefaultGatewayAddress       = '10.2.154.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },
        #endregion

        #region - 'Role = SQLServer'
        @{
            DomainName             = 'd.local'                      #FIXME: your domain FQDN
            DomainNetbiosName      = 'd'                            #FIXME: your domain NetBIOS
            Role                   = 'SQLServer'
            NodeName               = 'b2-sql01'
            IPV4Address            = '10.2.154.18/24'
            DefaultGatewayAddress  = '10.2.154.254'
            JoinOu                 = 'OU=Computers,DC=lab,DC=local'

            DataDriveSDiskId       = 1                                                   # SQL Data Disk
            DataDriveSLetter       = 'S'                                                 # SQL Data Disk Letter
            DataDriveSFSFormat     = 'NTFS'
            DataDriveSFSLabel      = 'sqlDB'
            DataDriveSPartitionStyle = 'GPT'

            SQLInstallSourcePath   = 'D:\'                          # SQL  -defaultInstance - SQL ISO is mounted here
            SQLDataDrive           = 'S:\'                          # TODO: change this to S:\ - drive designated for SQL db - dependency on the drive to be added to the VM first during the provisiong process
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
        #endregion

        #region - 'Role = SQLServer'
        @{
            DomainName             = 'd.local'                      #FIXME: your domain FQDN
            DomainNetbiosName      = 'd'                            #FIXME: your domain NetBIOS
            Role                   = 'SQLServer'
            NodeName               = 'b2-sql02'
            IPV4Address            = '10.2.154.19/24'
            DefaultGatewayAddress  = '10.2.154.254'
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
        },
        #endregion

        #region - 'Role = File Server'
        @{
            Role                        = 'FileServer'
            NodeName                    = 'b2-fs01'
            IPV4Address                 = '10.2.154.11/24'
            DefaultGatewayAddress       = '10.2.154.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'

            DataDrivePDiskId            = 1    #Profile Disk
            DataDrivePLetter            = 'P'  #Profile Disk Letter
            DataDrivePFSFormat          = 'NTFS'
            DataDrivePFSLabel           = 'Profiles'
            DataDrivePPartitionStyle    = 'GPT'
        },
        @{
            Role                        = 'FileServer'
            NodeName                    = 'b2-fs02'
            IPV4Address                 = '10.2.154.12/24'
            DefaultGatewayAddress       = '10.2.154.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'

            DataDrivePDiskId            = 1    #Profile Disk
            DataDrivePLetter            = 'P'  #Profile Disk Letter
            DataDrivePFSFormat          = 'NTFS'
            DataDrivePFSLabel           = 'Profiles'
            DataDrivePPartitionStyle    = 'GPT'
        },
        #endregion

        #region - 'Role = IscsiServer'
        #ISCSI
        @{
            Role                        = 'IscsiServer'
            NodeName                    = 'b2-iscsi'
            IPV4Address                 = '10.2.154.13/24'
            DefaultGatewayAddress       = '10.2.154.254'
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
        },
        #endregion

        #region - 'Role = ctxLicenseServer' Director
        @{
            Role                        = 'ctxLicenseDirector'
            NodeName                    = 'b2-ctx01LD'
            IPV4Address                 = '10.2.154.31/24'
            DefaultGatewayAddress       = '10.2.154.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },

        @{
            Role                        = 'ctxLicenseDirector'
            NodeName                    = 'b2-ctx02LD'
            IPV4Address                 = '10.2.154.32/24'
            DefaultGatewayAddress       = '10.2.154.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },
        #endregion

        #region - 'Role = ctxBroker'
        @{
            Role                        = 'ctxBroker'
            NodeName                    = 'b2-ctx01B'
            IPV4Address                 = '10.2.154.33/24'
            DefaultGatewayAddress       = '10.2.154.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },

        @{
            Role                        = 'ctxBroker'
            NodeName                    = 'b2-ctx02B'
            IPV4Address                 = '10.2.154.34/24'
            DefaultGatewayAddress       = '10.2.154.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },
        #endregion

        #region - 'Role = ctxStoreFront'
        @{
            Role                        = 'ctxStoreFront'
            NodeName                    = 'b2-ctx01S'
            IPV4Address                 = '10.2.154.35/24'
            DefaultGatewayAddress       = '10.2.154.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },

        @{
            Role                        = 'ctxStoreFront'
            NodeName                    = 'b2-ctx02S'
            IPV4Address                 = '10.2.154.36/24'
            DefaultGatewayAddress       = '10.2.154.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },
        #endregion

        #region - 'Role = ctxFas'
        @{
            Role                        = 'ctxFas'
            NodeName                    = 'b2-ctx01F'
            IPV4Address                 = '10.2.154.37/24'
            DefaultGatewayAddress       = '10.2.154.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },

        @{
            Role                        = 'ctxFas'
            NodeName                    = 'b2-ctx02F'
            IPV4Address                 = '10.2.154.38/24'
            DefaultGatewayAddress       = '10.2.154.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'
        },
        #endregion

        #region - 'Role = ctxProvisioningServer'
        @{
            Role                        = 'ctxProvisioningServer'
            NodeName                    = 'b2-ctx01P'
            IPV4Address                 = '10.2.154.41/24'
            DefaultGatewayAddress       = '10.2.154.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'

            DataDriveSDiskId            = 1    #PVS Store Disk
            DataDriveSLetter            = 'S'  #PVS Store Disk Letter
            DataDriveSFSFormat          = 'NTFS'
            DataDriveSFSLabel           = 'Store-PVS'
            DataDriveSPartitionStyle    = 'GPT'
        },

        @{
            Role                        = 'ctxProvisioningServer'
            NodeName                    = 'b2-ctx02P'
            IPV4Address                 = '10.2.154.42/24'
            DefaultGatewayAddress       = '10.2.154.254'
            JoinOu                      = 'OU=Computers,DC=lab,DC=local'

            DataDriveSDiskId            = 1    #PVS Store Disk
            DataDriveSLetter            = 'S'  #PVS Store Disk Letter
            DataDriveSFSFormat          = 'NTFS'
            DataDriveSFSLabel           = 'Store-PVS'
            DataDriveSPartitionStyle    = 'GPT'
        }
        #endregion

        )
}