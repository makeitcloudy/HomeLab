@{
    AllNodes = @(
        @{
            Role                = 'newVM'
            #NodeName            = 'localhost'
            NodeName            = 'localhost'
            #ComputerName        = 'w10mgmt'
            InterfaceAlias      = 'Eth0'
            WorkgroupDnsServers = @('10.2.134.254')
            WorkgroupName       = 'Workgroup'
            DomainDnsServers    = @('10.2.134.201', '10.2.134.202')
            DomainName          = 'lab.local'
            JoinOu              = 'OU=Computers,DC=lab,DC=local'
            # Target Node IP addresses for winRM connectivity
            TrustedHosts        = 'localhost'
            #TrustedHosts        = 'localhost,10.2.134.201,10.2.134.202'
            # The path to the .cer file containing the public key of the Encryption Certificate used to encrypt credentials for this node.
            CertificateFile     = 'C:\dsc\certificate\dscSelfSignedCertificate.cer'
            # The thumbprint of the Encryption Certificate used to decrypt the credentials on target node.
            # The value of the thumbprint should be changed each time the Self Signed Certificate is generated
            #Thumbprint          = 'EF280FE58AC3E1B8BC211122866248282B44E7D8'
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
            Role                = 'SQLServer'
            NodeName            = 'sql01'
            JoinOu              = 'OU=Computers,DC=lab,DC=local'
            DataDrivePDiskId    = 1    #Profile Disk
            DataDrivePLetter    = 'S'  #Profile Disk Letter
        },
        @{
            Role                = 'SQLServer'
            NodeName            = 'sql02'
            JoinOu              = 'OU=Computers,DC=lab,DC=local'
            DataDrivePDiskId    = 1    #Profile Disk
            DataDrivePLetter    = 'S'  #Profile Disk Letter
        }        
    )
}