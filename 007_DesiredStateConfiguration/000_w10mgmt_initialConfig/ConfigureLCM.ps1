[DscLocalConfigurationManager()]
Configuration ConfigureLCM {
    Node localhost {
        Settings {
            ActionAfterReboot  = 'ContinueConfiguration'
            CertificateID      = $Node.Thumbprint
            ConfigurationMode  = 'ApplyAndAutoCorrect'
            RebootNodeIfNeeded = $true
            RefreshMode        = 'Push'
        }
    }
}