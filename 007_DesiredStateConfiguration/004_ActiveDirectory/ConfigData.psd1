# Configuration data file (ConfigurationData.psd1).

@{
    AllNodes = 
    @(
        @{
            # NodeName "*" = apply this properties to all nodes that are members of AllNodes array.
            Nodename                    = '*'
            InterfaceAlias              = 'Ethernet 2'
            managementNodeIPv4Address   = '10.2.134.239'

            # Name of the remote domain. If no parent name is specified, this is the fully qualified domain name for the first domain in the forest.
            DomainName                  = 'lab.local'
            DomainNetbiosName           = 'LAB'
            DomainMode                  = 'WinThreshold'
            ForestMode                  = 'WinThreshold'
            
            DatabasePath                = 'C:\Windows\NTDS'
            LogPath                     = 'C:\Windows\Logs'
            SysvolPath                  = 'C:\Windows\SYSVOL'

            # Maximum number of retries to check for the domain's existence.
            #RetryCount                  = 12
            # Interval to check for the domain's existence.
            WaitTimeout                 = 60

            # The path to the .cer file containing the public key of the Encryption Certificate used to encrypt credentials for this node.
            CertificateFile             = 'C:\dscConfig\__certificate\dscSelfSignedCertificate.cer'
            # The thumbprint of the Encryption Certificate used to decrypt the credentials on target node.
            # *******
            # it must be updated each time new self signed certificate is created
            # in this scenario - the refresh happen each time when new lab is reprovisioned more or less between 90 or 180 days
            Thumbprint                  = 'EF280FE58AC3E1B8BC211122866248282B44E7D8'
        },

        @{
            Nodename              = '10.2.134.201'
            Role                  = 'FirstDomainController'
            ComputerName          = 'dc01'
            IPV4Address           = '10.2.134.201/24'
            DefaultGatewayAddress = '10.2.134.254'
            DNSServers            = @('127.0.0.1')

            #DNSServers  = '127.0.0.1','1.1.1.1'
            
        },

        @{
            Nodename              = '10.2.134.202'
            Role                  = 'SubsequentDomainController'
            ComputerName          = 'dc02'
            IPV4Address           = '10.2.134.202/24'
            DefaultGatewayAddress = '10.2.134.254'
            DNSServers            = @('10.2.134.201')
            
        }
    )
}