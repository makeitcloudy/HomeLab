# Configuration data file (ConfigurationData.psd1).

@{
    AllNodes = 
    @(
        @{
            # NodeName "*" = apply this properties to all nodes that are members of AllNodes array.
            Nodename                    = '*'
            # Name of the remote domain. If no parent name is specified, this is the fully qualified domain name for the first domain in the forest.
            DomainName                  = 'lab.local'
            # Maximum number of retries to check for the domain's existence.
            RetryCount                  = 20
            # Interval to check for the domain's existence.
            RetryIntervalSec            = 30
            # The path to the .cer file containing the public key of the Encryption Certificate used to encrypt credentials for this node.
            CertificateFile             = 'C:\dscConfig\__certificate\dscSelfSignedCertificate.cer'
            # The thumbprint of the Encryption Certificate used to decrypt the credentials on target node.
            # *******
            # it must be updated each time new self signed certificate is created
            # in this scenario - the refresh happen each time when new lab is reprovisioned more or less between 90 or 180 days
            Thumbprint                  = '768EF81910A596CB5A18E7AD9CA04EA5C03AB78A'
        },

        @{
            Nodename = '10.2.134.201'
            Role = 'FirstDomainController'
            ComputerName = "dc01"
        },

        @{
            Nodename = '10.2.134.202'
            Role = 'SubsequentDomainController'
            ComputerName = 'dc02'
        }
    )
}