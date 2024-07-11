## This code is not mine, it was updated, adapted and repurposed for this usecase
## it comes from: https://github.com/PlagueHO/LabBuilder/tree/main/source/dsclibrary

Configuration MEMBER_FILESERVER {
    Param (
        [Parameter(Position = 0, Mandatory = $true)]
        [PSCredential]$DomainCredential

    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration  -ModuleVersion '1.1'
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion '9.1.0'
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion '9.0.0'
    Import-DscResource -ModuleName StorageDsc -ModuleVersion '6.0.1'

    Node $AllNodes.Where{ $_.Role -eq 'FileServer' }.NodeName {
#    Node $AllNodes.NodeName {

        WindowsFeature FileServerInstall
        {
            Ensure = 'Present'
            Name   = 'FS-FileServer'
        }

        WindowsFeature DataDedupInstall
        {
            Ensure    = 'Present'
            Name      = 'FS-Data-Deduplication'
            DependsOn = '[WindowsFeature]FileServerInstall'
        }

        #WindowsFeature BranchCacheInstall
        #{
        #    Ensure    = 'Present'
        #    Name      = 'FS-BranchCache'
        #    DependsOn = '[WindowsFeature]DataDedupInstall'
        #}

        WindowsFeature DFSNameSpaceInstall
        {
            Ensure    = 'Present'
            Name      = 'FS-DFS-Namespace'
            DependsOn = '[WindowsFeature]DataDedupInstall'
            #DependsOn = '[WindowsFeature]BranchCacheInstall'
        }

        WindowsFeature DFSReplicationInstall
        {
            Ensure    = 'Present'
            Name      = 'FS-DFS-Replication'
            DependsOn = '[WindowsFeature]DFSNameSpaceInstall'
        }

        WindowsFeature FSResourceManagerInstall
        {
            Ensure    = 'Present'
            Name      = 'FS-Resource-Manager'
            DependsOn = '[WindowsFeature]DFSReplicationInstall'
        }

        WindowsFeature FSSyncShareInstall
        {
            Ensure    = 'Present'
            Name      = 'FS-SyncShareService'
            DependsOn = '[WindowsFeature]FSResourceManagerInstall'
        }

        WindowsFeature StorageServicesInstall
        {
            Ensure    = 'Present'
            Name      = 'Storage-Services'
            DependsOn = '[WindowsFeature]FSSyncShareInstall'
        }

        WindowsFeature ISCSITargetServerInstall
        {
            Ensure    = 'Present'
            Name      = 'FS-iSCSITarget-Server'
            DependsOn = '[WindowsFeature]StorageServicesInstall'
        }

        # Wait for the Domain to be available so we can join it.
        WaitForAll DC
        {
            ResourceName     = '[ADDomain]PrimaryDC'
            NodeName         = $Node.DCname
            RetryIntervalSec = 15
            RetryCount       = 60
        }

        # Join this Server to the Domain
        Computer JoinDomain
        {
            Name       = $Node.NodeName
            DomainName = $Node.DomainName
            Credential = $DomainAdminCredential
            DependsOn  = '[WaitForAll]DC'
        }

        # Enable FSRM FireWall rules so we can remote manage FSRM
        Firewall FSRMFirewall1
        {
            Name    = 'FSRM-WMI-ASYNC-In-TCP'
            Ensure  = 'Present'
            Enabled = 'True'
        }

        Firewall FSRMFirewall2
        {
            Name    = 'FSRM-WMI-WINMGMT-In-TCP'
            Ensure  = 'Present'
            Enabled = 'True'
        }

        Firewall FSRMFirewall3
        {
            Name    = 'FSRM-RemoteRegistry-In (RPC)'
            Ensure  = 'Present'
            Enabled = 'True'
        }

        Firewall FSRMFirewall4
        {
            Name    = 'FSRM-Task-Scheduler-In (RPC)'
            Ensure  = 'Present'
            Enabled = 'True'
        }

        Firewall FSRMFirewall5
        {
            Name    = 'FSRM-SrmReports-In (RPC)'
            Ensure  = 'Present'
            Enabled = 'True'
        }

        Firewall FSRMFirewall6
        {
            Name    = 'FSRM-RpcSs-In (RPC-EPMAP)'
            Ensure  = 'Present'
            Enabled = 'True'
        }

        Firewall FSRMFirewall7
        {
            Name    = 'FSRM-System-In (TCP-445)'
            Ensure  = 'Present'
            Enabled = 'True'
        }

        Firewall FSRMFirewall8
        {
            Name    = 'FSRM-SrmSvc-In (RPC)'
            Ensure  = 'Present'
            Enabled = 'True'
        }

        WaitforDisk Disk2
        {
            DiskId           = 1
            RetryIntervalSec = 60
            RetryCount       = 60
            DependsOn        = '[Computer]JoinDomain'
        }

        Disk DVolume
        {
            DiskId      = 1
            DriveLetter = 'D'
            DependsOn   = '[WaitforDisk]Disk2'
        }
    }
}