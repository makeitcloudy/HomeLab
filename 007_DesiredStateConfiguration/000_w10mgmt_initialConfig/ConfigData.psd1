@{
    AllNodes = @(
        @{
            NodeName            = 'localhost'
            ComputerName        = 'w10mgmt'
            EthernetIntName     = 'Ethernet 2'
            DnsServers          = @('10.2.134.201', '10.2.134.202')
            # Target Node IP addresses for winRM connectivity
            TrustedHosts        = '10.2.134.201,10.2.134.202'
            # The path to the .cer file containing the public key of the Encryption Certificate used to encrypt credentials for this node.
            CertificateFile     = 'C:\dscConfig\__certificate\dscSelfSignedCertificate.cer'
            # The thumbprint of the Encryption Certificate used to decrypt the credentials on target node.
            # The value of the thumbprint should be changed each time the Self Signed Certificate is generated
            Thumbprint          = '768EF81910A596CB5A18E7AD9CA04EA5C03AB78A'
        }
    )
}