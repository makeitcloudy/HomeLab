[DscLocalConfigurationManager()]
Configuration ConfigureLCM {
    param (
        [Parameter(Mandatory = $true)]
        [string]$CertificateThumbprint
    )

    Node localhost {
        Settings {
            ActionAfterReboot  = 'ContinueConfiguration'
            CertificateID      = $CertificateThumbprint
            ConfigurationMode  = 'ApplyAndMonitor'
            RebootNodeIfNeeded = $true
            RefreshMode        = 'Push'
        }
    }
}