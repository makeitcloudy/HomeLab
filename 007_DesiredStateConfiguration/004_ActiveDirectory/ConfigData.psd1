# Configuration data file (ConfigurationData.psd1).

@{
    AllNodes = 
    @(
        @{
            # NodeName "*" = apply this properties to all nodes that are members of AllNodes array.
            Nodename                    = "*"
            # Name of the remote domain. If no parent name is specified, this is the fully qualified domain name for the first domain in the forest.
            DomainName                  = "lab.local"
            # Maximum number of retries to check for the domain's existence.
            RetryCount                  = 20
            # Interval to check for the domain's existence.
            RetryIntervalSec            = 30
            # The path to the .cer file containing the public key of the Encryption Certificate used to encrypt credentials for this node.
            CertificateFile             = "$env:USERPROFILE\Documents\dscSelfSignedCertificate.cer"
            # The thumbprint of the Encryption Certificate used to decrypt the credentials on target node.
            Thumbprint                  = "E4DD714BB9D41FC57DBFD016EF037337D6DCB1BD"
        },

        @{
            Nodename = "10.2.134.201"
            Role = 'FirstDomainController'
            ComputerName = "dc01"
        },

        @{
            Nodename = "10.2.134.202"
            Role = 'SubsequentDomainController'
            ComputerName = 'dc02'
        }
    )
}