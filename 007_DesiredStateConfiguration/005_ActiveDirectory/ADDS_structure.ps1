#region functions
function Create-Ou
{
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ADDomain
    .PARAMETER TLD
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
        
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $ADDomain,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $TLD
    )

    BEGIN {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Create Ou"
        $startDate = Get-Date
    }

    PROCESS {
        ##/lab.local/_Governed
        New-ADOrganizationalUnit -Name '_Governed' -Path "dc=$ADDomain,dc=$TLD" -Description 'Placeholder for lab objects' -ProtectedFromAccidentalDeletion $true
        
        ##/lab.local/_Governed/Accounts
        New-ADOrganizationalUnit -Name 'Accounts' -Path "ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Admin,Service and User accounts' -ProtectedFromAccidentalDeletion $true
        #/lab.local/_Governed/Accounts/Admin
        New-ADOrganizationalUnit -Name 'Admin' -Path "ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Admin accounts' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Accounts/Admin/CVAD
        New-ADOrganizationalUnit -Name 'CVAD' -Path "ou=Admin,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Admin accounts' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Accounts/Admin/MS
        New-ADOrganizationalUnit -Name 'MS' -Path "ou=Admin,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Admin accounts' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Accounts/Admin/Test
        New-ADOrganizationalUnit -Name 'TEST' -Path "ou=Admin,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Admin accounts' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Accounts/Service
        New-ADOrganizationalUnit -Name 'Service' -Path "ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Service accounts' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Accounts/User
        New-ADOrganizationalUnit -Name 'User' -Path "ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for User accounts' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Accounts/User/CVAD
        New-ADOrganizationalUnit -Name 'CVAD' -Path "ou=User,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Admin accounts' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Accounts/User/MS
        New-ADOrganizationalUnit -Name 'MS' -Path "ou=User,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Admin accounts' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Accounts/User/Test
        New-ADOrganizationalUnit -Name 'TEST' -Path "ou=User,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Admin accounts' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Accounts/Test
        New-ADOrganizationalUnit -Name 'Test' -Path "ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Test accounts' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Accounts/Test/CVAD
        New-ADOrganizationalUnit -Name 'CVAD' -Path "ou=Test,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Admin accounts' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Accounts/Test/MS
        New-ADOrganizationalUnit -Name 'MS' -Path "ou=TEst,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Admin accounts' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Accounts/Test/TEST
        New-ADOrganizationalUnit -Name 'TEST' -Path "ou=Test,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Admin accounts' -ProtectedFromAccidentalDeletion $false

        ##/lab.local/_Governed/Groups
        New-ADOrganizationalUnit -Name 'Groups' -Path "ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Application, Admin and User accounts' -ProtectedFromAccidentalDeletion $true
        #/lab.local/_Governed/Groups/Admin
        New-ADOrganizationalUnit -Name 'Admin' -Path "ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Admin groups' -ProtectedFromAccidentalDeletion $true
        #/lab.local/_Governed/Groups/Admin/Services
        New-ADOrganizationalUnit -Name 'Services' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Admin groups of Infrastructure Services' -ProtectedFromAccidentalDeletion $true
        
        #/lab.local/_Governed/Groups/Admin/Services/Hypervisor
        New-ADOrganizationalUnit -Name 'Hypervisor' -Path "ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Hypervisor related Admin groups' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Groups/Admin/Services/NetScaler
        New-ADOrganizationalUnit -Name 'NetScaler' -Path "ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for NetScaler related Admin groups' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Groups/Admin/Services/CVAD
        New-ADOrganizationalUnit -Name 'CVAD' -Path "ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD related Admin groups' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Groups/Admin/Services/CVAD/AppLayering
        New-ADOrganizationalUnit -Name 'AppLayering' -Path "ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for AppLayering related Admin groups' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Groups/Admin/Services/CVAD/Broker
        New-ADOrganizationalUnit -Name 'Broker' -Path "ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Broker related Admin groups' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Groups/Admin/Services/CVAD/Director
        New-ADOrganizationalUnit -Name 'Director' -Path "ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Director related Admin groups' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Groups/Admin/Services/CVAD/FAS
        New-ADOrganizationalUnit -Name 'FAS' -Path "ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Federated Authentication Services related Admin groups' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Groups/Admin/Services/CVAD/LIC
        New-ADOrganizationalUnit -Name 'LIC' -Path "ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for License Server related Admin groups' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Groups/Admin/Services/CVAD/PVS
        New-ADOrganizationalUnit -Name 'PVS' -Path "ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Citrix Provisioning Services related Admin groups' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Groups/Admin/Services/CVAD/StoreFront
        New-ADOrganizationalUnit -Name 'StoreFront' -Path "ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for StoreFront related Admin groups' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Groups/Admin/Services/CVAD/WEM
        New-ADOrganizationalUnit -Name 'WEM' -Path "ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Federated Authentication Services related Admin groups' -ProtectedFromAccidentalDeletion $false

        ##/lab.local/_Governed/Groups/Admin/Services/MS
        New-ADOrganizationalUnit -Name 'MS' -Path "ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Functional Services related Admin groups' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Groups/Admin/Services/MS/MGMT
        New-ADOrganizationalUnit -Name 'MGMT' -Path "ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Management Plane (jumphost,mgmtNode) Admin groups' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Groups/Admin/Services/MS/ADCS
        New-ADOrganizationalUnit -Name 'ADCS' -Path "ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for ADCS/PKI related Admin groups' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Groups/Admin/Services/MS/DHCP
        New-ADOrganizationalUnit -Name 'DHCP' -Path "ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for DHCP related Admin groups' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Groups/Admin/Services/MS/FileServer
        New-ADOrganizationalUnit -Name 'FileServer' -Path "ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for FileServer related Admin groups' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Groups/Admin/Services/MS/SQL
        New-ADOrganizationalUnit -Name 'SQL' -Path "ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for SQL related Admin groups' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Groups/Admin/Services/MS/AppV
        New-ADOrganizationalUnit -Name 'AppV' -Path "ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for APP-V related Admin groups' -ProtectedFromAccidentalDeletion $false
        
        ##/lab.local/_Governed/Groups/User
        New-ADOrganizationalUnit -Name 'User' -Path "ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for User groups' -ProtectedFromAccidentalDeletion $true
        #/lab.local/_Governed/Groups/Application
        New-ADOrganizationalUnit -Name 'Application' -Path "ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Application groups' -ProtectedFromAccidentalDeletion $true
        #/lab.local/_Governed/Groups/Policy
        New-ADOrganizationalUnit -Name 'Policy' -Path "ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for' -ProtectedFromAccidentalDeletion $true
        #/lab.local/_Governed/Groups/Security
        New-ADOrganizationalUnit -Name 'Security' -Path "ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for' -ProtectedFromAccidentalDeletion $true
        
        ##/lab.local/_Governed/Infra
        New-ADOrganizationalUnit -Name 'Infra' -Path "ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for infra objects' -ProtectedFromAccidentalDeletion $true
        
        ##/lab.local/_Governed/Infra/Citrix
        New-ADOrganizationalUnit -Name 'Citrix' -Path "ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Citrix infra objects' -ProtectedFromAccidentalDeletion $true
        #/lab.local/_Governed/Infra/Citrix/CVAD
        New-ADOrganizationalUnit -Name 'CVAD' -Path "ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD infra objects' -ProtectedFromAccidentalDeletion $true
        ## GPO: Citrix VDA Computer Settings -> User configuration settings disabled
        ## GPO: Citrix VDA Users All (including Admins) -> Computer configuration settings disabled
        ## GPO: Citrix VDA USers Non-Admins (lockdown) -> Computer configuration settings disabled
        
        #/lab.local/_Governed/Infra/Citrix/CVAD/AppLayering
        New-ADOrganizationalUnit -Name 'AppLayering' -Path "ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD AppLayering computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/Broker
        New-ADOrganizationalUnit -Name 'Broker' -Path "ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD Broker computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/Director
        New-ADOrganizationalUnit -Name 'Director' -Path "ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD Director computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/FAS
        New-ADOrganizationalUnit -Name 'FAS' -Path "ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD Fas computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/LicenseServer
        New-ADOrganizationalUnit -Name 'LicenseServer' -Path "ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD LicenseServer computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/StoreFront
        New-ADOrganizationalUnit -Name 'StoreFront' -Path "ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD StoreFront computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/WEM
        New-ADOrganizationalUnit -Name 'WEM' -Path "ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD StoreFront computer objects' -ProtectedFromAccidentalDeletion $false

        #/lab.local/_Governed/Infra/Citrix/CVAD/_TEMPLATE/
        New-ADOrganizationalUnit -Name '_TEMPLATE' -Path "ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD Template computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/_TEMPLATE/2008R2
        New-ADOrganizationalUnit -Name '2008R2' -Path "ou=_TEMPLATE,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/_TEMPLATE/2012R2
        New-ADOrganizationalUnit -Name '2012R2' -Path "ou=_TEMPLATE,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/_TEMPLATE/2016
        New-ADOrganizationalUnit -Name '2016' -Path "ou=_TEMPLATE,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/_TEMPLATE/2019
        New-ADOrganizationalUnit -Name '2019' -Path "ou=_TEMPLATE,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/_TEMPLATE/2022
        New-ADOrganizationalUnit -Name '2022' -Path "ou=_TEMPLATE,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/_TEMPLATE/2025
        New-ADOrganizationalUnit -Name '2025' -Path "ou=_TEMPLATE,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        
        #/lab.local/_Governed/Infra/Citrix/CVAD/_TEMPLATE/Win11
        New-ADOrganizationalUnit -Name 'Win11' -Path "ou=_TEMPLATE,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/_TEMPLATE/Win10
        New-ADOrganizationalUnit -Name 'Win10' -Path "ou=_TEMPLATE,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/_TEMPLATE/Win7
        New-ADOrganizationalUnit -Name 'Win7' -Path "ou=_TEMPLATE,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        
        
        #/lab.local/_Governed/Infra/Citrix/CVAD/_VDA/
        New-ADOrganizationalUnit -Name '_VDA' -Path "ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD VDA computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/_VDA/2008R2
        New-ADOrganizationalUnit -Name '2008R2' -Path "ou=_VDA,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/_VDA/2012R2
        New-ADOrganizationalUnit -Name '2012R2' -Path "ou=_VDA,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/_VDA/2016
        New-ADOrganizationalUnit -Name '2016' -Path "ou=_VDA,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/_VDA/2019
        New-ADOrganizationalUnit -Name '2019' -Path "ou=_VDA,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/_VDA/2022
        New-ADOrganizationalUnit -Name '2022' -Path "ou=_VDA,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/_VDA/2025
        New-ADOrganizationalUnit -Name '2025' -Path "ou=_VDA,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        
        #/lab.local/_Governed/Infra/Citrix/CVAD/_VDA/Win11
        New-ADOrganizationalUnit -Name 'Win11' -Path "ou=_VDA,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/_VDA/Win10
        New-ADOrganizationalUnit -Name 'Win10' -Path "ou=_VDA,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Citrix/CVAD/_VDA/Win7
        New-ADOrganizationalUnit -Name 'Win7' -Path "ou=_VDA,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for CVAD computer objects' -ProtectedFromAccidentalDeletion $false
        
        #/lab.local/_Governed/Infra/Microsoft
        New-ADOrganizationalUnit -Name 'Microsoft' -Path "ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Microsoft infra objects' -ProtectedFromAccidentalDeletion $true
        #/lab.local/_Governed/Infra/Microsoft/ADCS
        New-ADOrganizationalUnit -Name 'ADCS' -Path "ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Active Directory Certification Services infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/DHCP
        New-ADOrganizationalUnit -Name 'DHCP' -Path "ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for DHCP infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/FileServer
        New-ADOrganizationalUnit -Name 'FileServer' -Path "ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for File Server infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/SQL
        New-ADOrganizationalUnit -Name 'SQL' -Path "ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for SQL infra objects' -ProtectedFromAccidentalDeletion $false
        
        #/lab.local/_Governed/Infra/Microsoft/RDS
        New-ADOrganizationalUnit -Name 'RDS' -Path "ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Remote Desktop Services infra objects' -ProtectedFromAccidentalDeletion $true
        #/lab.local/_Governed/Infra/Microsoft/RDS/2012R2
        New-ADOrganizationalUnit -Name '2012R2' -Path "ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Remote Desktop Services 2012$2 infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2012R2/RDGW
        New-ADOrganizationalUnit -Name 'RDGW' -Path "ou=2012R2,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Gateway infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2012R2/RDCB
        New-ADOrganizationalUnit -Name 'RDCB' -Path "ou=2012R2,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Broker infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2012R2/RDWI
        New-ADOrganizationalUnit -Name 'RDWI' -Path "ou=2012R2,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Web Interface infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2012R2/RDSH
        New-ADOrganizationalUnit -Name 'RDSH' -Path "ou=2012R2,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Session Hosts infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2012R2/VDI
        New-ADOrganizationalUnit -Name 'VDI' -Path "ou=2012R2,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS VDI infra objects' -ProtectedFromAccidentalDeletion $false
        
        #/lab.local/_Governed/Infra/Microsoft/RDS/2016
        New-ADOrganizationalUnit -Name '2016' -Path "ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Remote Desktop Services 2016 infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2016/RDGW
        New-ADOrganizationalUnit -Name 'RDGW' -Path "ou=2016,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Gateway infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2016/RDCB
        New-ADOrganizationalUnit -Name 'RDCB' -Path "ou=2016,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Broker infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2016/RDWI
        New-ADOrganizationalUnit -Name 'RDWI' -Path "ou=2016,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Web Interface infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2016/RDSH
        New-ADOrganizationalUnit -Name 'RDSH' -Path "ou=2016,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Session Hosts infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2016/VDI
        New-ADOrganizationalUnit -Name 'VDI' -Path "ou=2016,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS VDI infra objects' -ProtectedFromAccidentalDeletion $false
        
        #/lab.local/_Governed/Infra/Microsoft/RDS/2019
        New-ADOrganizationalUnit -Name '2019' -Path "ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Remote Desktop Services 2019 infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2019/RDGW
        New-ADOrganizationalUnit -Name 'RDGW' -Path "ou=2019,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Gateway infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2019/RDCB
        New-ADOrganizationalUnit -Name 'RDCB' -Path "ou=2019,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Broker infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2019/RDWI
        New-ADOrganizationalUnit -Name 'RDWI' -Path "ou=2019,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Web Interface infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2019/RDSH
        New-ADOrganizationalUnit -Name 'RDSH' -Path "ou=2019,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Session Hosts infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2019/VDI
        New-ADOrganizationalUnit -Name 'VDI' -Path "ou=2019,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS VDI infra objects' -ProtectedFromAccidentalDeletion $false
        
        #/lab.local/_Governed/Infra/Microsoft/RDS/2022
        New-ADOrganizationalUnit -Name '2022' -Path "ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Remote Desktop Services 2022 infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2022/RDGW
        New-ADOrganizationalUnit -Name 'RDGW' -Path "ou=2022,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Gateway infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2022/RDCB
        New-ADOrganizationalUnit -Name 'RDCB' -Path "ou=2022,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Broker infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2022/RDWI
        New-ADOrganizationalUnit -Name 'RDWI' -Path "ou=2022,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Web Interface infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2022/RDSH
        New-ADOrganizationalUnit -Name 'RDSH' -Path "ou=2022,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Session Hosts infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2022/VDI
        New-ADOrganizationalUnit -Name 'VDI' -Path "ou=2022,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS VDI infra objects' -ProtectedFromAccidentalDeletion $false
        
        #/lab.local/_Governed/Infra/Microsoft/RDS/2025
        New-ADOrganizationalUnit -Name '2025' -Path "ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Remote Desktop Services 2025 infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2025/RDGW
        New-ADOrganizationalUnit -Name 'RDGW' -Path "ou=2025,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Gateway infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2025/RDCB
        New-ADOrganizationalUnit -Name 'RDCB' -Path "ou=2025,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Broker infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2025/RDWI
        New-ADOrganizationalUnit -Name 'RDWI' -Path "ou=2025,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Web Interface infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2025/RDSH
        New-ADOrganizationalUnit -Name 'RDSH' -Path "ou=2025,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS Session Hosts infra objects' -ProtectedFromAccidentalDeletion $false
        #/lab.local/_Governed/Infra/Microsoft/RDS/2025/VDI
        New-ADOrganizationalUnit -Name 'VDI' -Path "ou=2025,ou=RDS,ou=Microsoft,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for RDS VDI infra objects' -ProtectedFromAccidentalDeletion $false
        
        #/lab.local/_Governed/Infra/Parallels
        New-ADOrganizationalUnit -Name 'Parallels' -Path "ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for Parallels infra objects' -ProtectedFromAccidentalDeletion $true
    }

    END {
            $endDate = Get-Date
            Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }

    
}
      
function Create-DelegationGroup
{
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ADDomain
    .PARAMETER TLD
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
        
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $ADDomain,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $TLD
    )

    BEGIN {
        #TODO: Add AD group nesting, this way: Add-ADGroupMember -Identity 'Service-L-MS-SQL-Admin' -Members 'Service-G-MS-SQL-Admin'
        #TODO: Add AD group nesting, this way: Add-ADGroupMember -Identity 'Service-L-MS-SQL-Admin' -Members 'Service-G-MS-SQL-Admin'
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Create DelegationGroup"
        $startDate = Get-Date
    }

    PROCESS {
        #/lab.local/_Governed/Groups/Policy
        New-ADGroup -Name 'Policy-G-AllowRegedit' -SamAccountName 'Policy-G-AllowRegedit' -GroupCategory Security -GroupScope Global -DisplayName 'Policy-G-AllowRegedit' -Path "ou=Policy,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Scope - Global - Allow making use of regedit'
        New-ADGroup -Name 'Policy-L-AllowRegedit' -SamAccountName 'Policy-L-AllowRegedit' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Policy-L-AllowRegedit' -Path "ou=Policy,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Scope - Domain Local - Allow making use of regedit'

        #/lab.local/_Governed/Groups/Security
        New-AdGroup -Name 'Security-G-Administrators' -SamAccountName 'Sec-G-Administrators' -GroupCategory Security -GroupScope Global -DisplayName 'Sec-G-Administrators' -Path "ou=Security,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description ''
        New-AdGroup -Name 'Security-G-BackupOperators' -SamAccountName 'Sec-G-BackupOperators' -GroupCategory Security -GroupScope Global -DisplayName 'Sec-G-BackupOperators' -Path "ou=Security,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description ''
        New-AdGroup -Name 'Security-G-PowerUsers' -SamAccountName 'Sec-G-PowerUsers' -GroupCategory Security -GroupScope Global -DisplayName 'Sec-G-PowerUsers' -Path "ou=Security,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description ''
        New-AdGroup -Name 'Security-G-RemoteDesktopUsers' -SamAccountName 'Sec-G-RemoteDesktopUsers' -GroupCategory Security -GroupScope Global -DisplayName 'Sec-G-RemoteDesktopUsers' -Path "ou=Security,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description ''

        New-AdGroup -Name 'Security-L-Administrators' -SamAccountName 'Security-L-Administrators' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Security-L-Administrators' -Path "ou=Security,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Provides Local Admin Permissions'
        New-AdGroup -Name 'Security-L-BackupOperators' -SamAccountName 'Security-L-BackupOperators' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Security-L-BackupOperators' -Path "ou=Security,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Provides Backup Operator Permissions'
        New-AdGroup -Name 'Security-L-PowerUsers' -SamAccountName 'Security-L-PowerUsers' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Security-L-PowerUsers' -Path "ou=Security,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Provides Power User Permissions'
        New-AdGroup -Name 'Security-L-RemoteDesktopUser' -SamAccountName 'Secucity-L-RemoteDesktopUser' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Secucity-L-RemoteDesktopUser' -Path "ou=Security,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Provides Remote Desktop Logon Permissions'

        #/lab.local/_Governed/Groups/Admin/Services/XX
        #"ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"

        #"ou=MgmtLayer,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        New-ADGroup -Name 'Service-G-MS-MGMT-Admin' -SamAccountName 'Service-G-MS-MGMT-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-MS-MGMT-Admin' -Path "ou=MGMT,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'ADCS - DomainGlobal - Full Administrators'
        New-ADGroup -Name 'Service-G-MS-MGMT-CustomAdmin' -SamAccountName 'Service-G-MS-MGMT-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-MS-MGMT-CustomAdmin' -Path 'ou=MGMT,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'ADCS Service Restricted Administrators Delegated Domain Global Group'
        New-ADGroup -Name 'Service-L-MS-MGMT-Admin' -SamAccountName 'Service-L-MS-MGMT-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-MGMT-Admin' -Path 'ou=MGMT,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'ADCS Service Full Administrators Delegated Domain Local Group'
        New-ADGroup -Name 'Service-L-MS-MGMT-CustomAdmin' -SamAccountName 'Service-L-MS-MGMT-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-MGMT-CustomAdmin' -Path 'ou=MGMT,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'ADCS Service Restricted Administrators Delegated Domain Local Group'
        New-ADGroup -Name 'Service-L-MS-MGMT-OU' -SamAccountName 'Service-L-MS-MGMT-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-MGMT-OU' -Path 'ou=MGMT,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'Full Control Rights Delegation - ADCS OU and Policies'

        #"ou=ADCS,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        New-ADGroup -Name 'Service-G-MS-ADCS-Admin' -SamAccountName 'Service-G-MS-ADCS-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-MS-ADCS-Admin' -Path "ou=ADCS,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'ADCS - DomainGlobal - Full Administrators'
        New-ADGroup -Name 'Service-G-MS-ADCS-CustomAdmin' -SamAccountName 'Service-G-MS-ADCS-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-MS-ADCS-CustomAdmin' -Path 'ou=ADCS,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'ADCS Service Restricted Administrators Delegated Domain Global Group'
        New-ADGroup -Name 'Service-L-MS-ADCS-Admin' -SamAccountName 'Service-L-MS-ADCS-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-ADCS-Admin' -Path 'ou=ADCS,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'ADCS Service Full Administrators Delegated Domain Local Group'
        New-ADGroup -Name 'Service-L-MS-ADCS-CustomAdmin' -SamAccountName 'Service-L-MS-ADCS-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-ADCS-CustomAdmin' -Path 'ou=ADCS,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'ADCS Service Restricted Administrators Delegated Domain Local Group'
        New-ADGroup -Name 'Service-L-MS-ADCS-OU' -SamAccountName 'Service-L-MS-ADCS-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-ADCS-OU' -Path 'ou=ADCS,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'Full Control Rights Delegation - ADCS OU and Policies'

        #"ou=DHCP,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        New-ADGroup -Name 'Service-G-MS-DHCP-Admin' -SamAccountName 'Service-G-MS-DHCP-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-MS-DHCP-Admin' -Path "ou=DHCP,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'DHCP - DomainGlobal - Full Administrators'
        New-ADGroup -Name 'Service-G-MS-DHCP-CustomAdmin' -SamAccountName 'Service-G-MS-DHCP-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-MS-DHCP-CustomAdmin' -Path 'ou=DHCP,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'DHCP Service Restricted Administrators Delegated Domain Global Group'
        New-ADGroup -Name 'Service-L-MS-DHCP-Admin' -SamAccountName 'Service-L-MS-DHCP-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-DHCP-Admin' -Path 'ou=DHCP,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'DHCP Service Full Administrators Delegated Domain Local Group'
        New-ADGroup -Name 'Service-L-MS-DHCP-CustomAdmin' -SamAccountName 'Service-L-MS-DHCP-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-DHCP-CustomAdmin' -Path 'ou=DHCP,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'DHCP Service Restricted Administrators Delegated Domain Local Group'
        New-ADGroup -Name 'Service-L-MS-DHCP-OU' -SamAccountName 'Service-L-MS-DHCP-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-DHCP-OU' -Path 'ou=DHCP,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'Full Control Rights Delegation - DHCP OU and Policies'

        #"ou=FileServer,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        New-ADGroup -Name 'Service-G-MS-FileServer-Admin' -SamAccountName 'Service-G-MS-FileServer-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-MS-FileServer-Admin' -Path "ou=FileServer,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'FileServer - DomainGlobal - Full Administrators'
        New-ADGroup -Name 'Service-G-MS-FileServer-CustomAdmin' -SamAccountName 'Service-G-MS-FileServer-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-MS-FileServer-CustomAdmin' -Path 'ou=FileServer,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'FileServer Service Restricted Administrators Delegated Domain Global Group'
        New-ADGroup -Name 'Service-L-MS-FileServer-Admin' -SamAccountName 'Service-L-MS-FileServer-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-FileServer-Admin' -Path 'ou=FileServer,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'FileServer Service Full Administrators Delegated Domain Local Group'
        New-ADGroup -Name 'Service-L-MS-FileServer-CustomAdmin' -SamAccountName 'Service-L-MS-FileServer-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-FileServer-CustomAdmin' -Path 'ou=FileServer,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'FileServer Service Restricted Administrators Delegated Domain Local Group'
        New-ADGroup -Name 'Service-L-MS-FileServer-OU' -SamAccountName 'Service-L-MS-FileServer-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-FileServer-OU' -Path 'ou=FileServer,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'Full Control Rights Delegation - FileServer OU and Policies'

        ##"ou=SQL,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        New-ADGroup -Name 'Service-G-MS-SQL-Admin' -SamAccountName 'Service-G-MS-SQL-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-MS-SQL-Admin' -Path "ou=SQL,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Full Permissions - SQL Administrator'
        New-ADGroup -Name 'Service-L-MS-SQL-Admin' -SamAccountName 'Service-L-MS-SQL-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-SQL-Admin' -Path "ou=SQL,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Full Permissions - SQL Administrator'
        New-ADGroup -Name 'Service-G-MS-SQL-CustomAdmin' -SamAccountName 'Service-G-MS-SQL-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-MS-SQL-CustomAdmin' -Path "ou=SQL,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Constrained Permissions - SQL Administrators'
        New-ADGroup -Name 'Service-L-MS-SQL-CustomAdmin' -SamAccountName 'Service-L-MS-SQL-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-SQL-CustomAdmin' -Path "ou=SQL,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Constrained Permissions - SQL Administrators'
        New-ADGroup -Name 'Service-L-MS-SQL-OU' -SamAccountName 'Service-L-MS-SQL-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-SQL-OU' -Path "ou=SQL,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Full Control Rights Delegation - SQL OU and Policies'


        ##"ou=AppV,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"

        #TODO: RENAME DESCRIPTION OF THE GROUPS ######################################################################
        New-ADGroup -Name 'Service-G-MS-APPV-Admin' -SamAccountName 'Service-G-MS-APPV-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-MS-APPV-Admin' -Path "ou=AppV,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'App-V - DomainGlobal - Full Administrators'
        New-ADGroup -Name 'Service-G-MS-APPV-CustomAdmin' -SamAccountName 'Service-G-MS-APPV-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-MS-APPV-CustomAdmin' -Path 'ou=AppV,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'App-V Service Restricted Administrators Delegated Domain Global Group'
        New-ADGroup -Name 'Service-L-MS-APPV-Admin' -SamAccountName 'Service-L-MS-APPV-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-APPV-Admin' -Path 'ou=AppV,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'App-V Service Full Administrators Delegated Domain Local Group'
        New-ADGroup -Name 'Service-L-MS-APPV-CustomAdmin' -SamAccountName 'Service-L-MS-APPV-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-APPV-CustomAdmin' -Path 'ou=AppV,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'App-V Service Restricted Administrators Delegated Domain Local Group'
        New-ADGroup -Name 'Service-L-MS-APPV-OU' -SamAccountName 'Service-L-MS-APPV-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-MS-APPV-OU' -Path 'ou=AppV,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local' -Description 'Full Control Rights Delegation - APP-V OU and Policies'

        #"ou=Hypervisor,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        New-ADGroup -Name 'Service-G-Hypervisor-Admin' -SamAccountName 'Service-G-Hypervisor-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-Hypervisor-Admin' -Path "ou=Hypervisor,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Full Permissions - Hypervisor'
        New-ADGroup -Name 'Service-L-Hypervisor-Admin' -SamAccountName 'Service-L-Hypervisor-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-Hypervisor-Admin' -Path "ou=Hypervisor,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Full Permissions - Hypervisor'
        New-ADGroup -Name 'Service-G-Hypervisor-CustomAdmin' -SamAccountName 'Service-G-Hypervisor-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-Hypervisor-CustomAdmin' -Path "ou=Hypervisor,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Constrained Permissions - Hypervisor Administrators'
        New-ADGroup -Name 'Service-L-Hypervisor-CustomAdmin' -SamAccountName 'Service-L-Hypervisor-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-Hypervisor-CustomAdmin' -Path "ou=Hypervisor,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Constrained Permissions - Hypervisor Administrators'
        New-ADGroup -Name 'Service-L-Hypervisor-OU' -SamAccountName 'Service-L-Hypervisor-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-Hypervisor-OU' -Path "ou=Hypervisor,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Full Control Rights Delegation - Hypervisor OU and Policies'

        ##"ou=NetScaler,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        New-ADGroup -Name 'Service-G-NetScaler-Admin' -SamAccountName 'Service-G-NetScaler-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-NetScaler-Admin' -Path "ou=NetScaler,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Full Permissions - NetScaler'
        New-ADGroup -Name 'Service-L-NetScaler-Admin' -SamAccountName 'Service-L-NetScaler-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-NetScaler-Admin' -Path "ou=NetScaler,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Full Permissions - NetScaler'
        New-ADGroup -Name 'Service-G-NetScaler-CustomAdmin' -SamAccountName 'Service-G-NetScaler-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-NetScaler-CustomAdmin' -Path "ou=NetScaler,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Constrained Permissions - NetScaler Administrators'
        New-ADGroup -Name 'Service-L-NetScaler-CustomAdmin' -SamAccountName 'Service-L-NetScaler-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-NetScaler-CustomAdmin' -Path "ou=NetScaler,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Constrained Permissions - NetScaler Administrators'
        New-ADGroup -Name 'Service-L-NetScaler-OU' -SamAccountName 'Service-L-NetScaler-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-NetScaler-OU' -Path "ou=NetScaler,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Full Control Rights Delegation - NetScaler OU and Policies'

        #"ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        #CVAD-Admin - should have the a_ admins as members
        #CVAD-Admin - should be member of Service-G-CVAD-Admin and Service-L-CVAD-OU
        #CVAD OU Security should grant Service-L-CVAD-OU group

        New-ADGroup -Name 'Service-G-CVAD-Admin' -SamAccountName 'Service-G-CVAD-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-Admin' -Path "ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Full Permissions - Citrix AppLayering'
        New-ADGroup -Name 'Service-L-CVAD-Admin' -SamAccountName 'Service-L-CVAD-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-Admin' -Path "ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Full Permissions - Citrix AppLayering'
        New-ADGroup -Name 'Service-G-CVAD-CustomAdmin' -SamAccountName 'Service-G-CVAD-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-CustomAdmin' -Path "ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Constrained Permissions - Citrix AppLayering Administrators'
        New-ADGroup -Name 'Service-L-CVAD-CustomAdmin' -SamAccountName 'Service-L-CVAD-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-CustomAdmin' -Path "ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Constrained Permissions - Citrix AppLayering Administrators'
        New-ADGroup -Name 'Service-L-CVAD-OU' -SamAccountName 'Service-L-CVAD-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-OU' -Path "ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Full Control Rights Delegation - Citrix AppLayering OU and Policies'

        ## those two are not needed as there are: /lab.local/_Governed/Groups/Admin - CVAD-HelpDeskAdmin
        #New-ADGroup -Name 'Service-G-CVAD-HelpDeskAdmin' -SamAccountName 'Service-G-CVAD-HelpDeskAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-HelpDeskAdmin' -Path "ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - HelpDesk Administrators'
        #New-ADGroup -Name 'Service-L-CVAD-HelpDeskAdmin' -SamAccountName 'Service-L-CVAD-HelpDeskAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-HelpDeskAdmin' -Path "ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - HelpDesk Administrators'

        ##"ou=AppLayering,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        New-ADGroup -Name 'Service-G-CVAD-AppLayering-Admin' -SamAccountName 'Service-G-CVAD-AppLayering-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-AppLayering-Admin' -Path "ou=AppLayering,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Full Permissions - Citrix AppLayering'
        New-ADGroup -Name 'Service-L-CVAD-AppLayering-Admin' -SamAccountName 'Service-L-CVAD-AppLayering-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-AppLayering-Admin' -Path "ou=AppLayering,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Full Permissions - Citrix AppLayering'
        New-ADGroup -Name 'Service-G-CVAD-AppLayering-CustomAdmin' -SamAccountName 'Service-G-CVAD-AppLayering-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-AppLayering-CustomAdmin' -Path "ou=AppLayering,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Constrained Permissions - Citrix AppLayering Administrators'
        New-ADGroup -Name 'Service-L-CVAD-AppLayering-CustomAdmin' -SamAccountName 'Service-L-CVAD-AppLayering-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-AppLayering-CustomAdmin' -Path "ou=AppLayering,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Constrained Permissions - Citrix AppLayering Administrators'
        New-ADGroup -Name 'Service-L-CVAD-AppLayering-OU' -SamAccountName 'Service-L-CVAD-AppLayering-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-AppLayering-OU' -Path "ou=AppLayering,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Full Control Rights Delegation - Citrix AppLayering OU and Policies'

        ##"ou=Broker,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        New-ADGroup -Name 'Service-G-CVAD-Broker-Admin' -SamAccountName 'Service-G-CVAD-Broker-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-Broker-Admin' -Path "ou=Broker,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Full Permissions - Citrix Broker'
        New-ADGroup -Name 'Service-L-CVAD-Broker-Admin' -SamAccountName 'Service-L-CVAD-Broker-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-Broker-Admin' -Path "ou=Broker,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Full Permissions - Citrix Broker'
        New-ADGroup -Name 'Service-G-CVAD-Broker-CustomAdmin' -SamAccountName 'Service-G-CVAD-Broker-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-Broker-CustomAdmin' -Path "ou=Broker,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Constrained Permissions - Citrix Broker Administrators'
        New-ADGroup -Name 'Service-L-CVAD-Broker-CustomAdmin' -SamAccountName 'Service-L-CVAD-Broker-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-Broker-CustomAdmin' -Path "ou=Broker,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Constrained Permissions - Citrix Broker Administrators'
        New-ADGroup -Name 'Service-L-CVAD-Broker-OU' -SamAccountName 'Service-L-CVAD-Broker-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-Broker-OU' -Path "ou=Broker,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Full Control Rights Delegation - Citrix Broker OU and Policies'

        ##"ou=Director,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        New-ADGroup -Name 'Service-G-CVAD-Director-Admin' -SamAccountName 'Service-G-CVAD-Director-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-Director-Admin' -Path "ou=Director,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Full Permissions - Citrix Director'
        New-ADGroup -Name 'Service-L-CVAD-Director-Admin' -SamAccountName 'Service-L-CVAD-Director-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-Director-Admin' -Path "ou=Director,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Full Permissions - Citrix Director'
        New-ADGroup -Name 'Service-G-CVAD-Director-CustomAdmin' -SamAccountName 'Service-G-CVAD-Director-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-Director-CustomAdmin' -Path "ou=Director,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Constrained Permissions - Citrix Director Administrators'
        New-ADGroup -Name 'Service-L-CVAD-Director-CustomAdmin' -SamAccountName 'Service-L-CVAD-Director-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-Director-CustomAdmin' -Path "ou=Director,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Constrained Permissions - Citrix Director Administrators'
        New-ADGroup -Name 'Service-L-CVAD-Director-OU' -SamAccountName 'Service-L-CVAD-Director-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-Director-OU' -Path "ou=Director,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Full Control Rights Delegation - Citrix Director OU and Policies'

        #"ou=FAS,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        New-ADGroup -Name 'Service-G-CVAD-FAS-Admin' -SamAccountName 'Service-G-CVAD-FAS-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-FAS-Admin' -Path "ou=FAS,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Full Permissions - Citrix Federated Authentication Services'
        New-ADGroup -Name 'Service-L-CVAD-FAS-Admin' -SamAccountName 'Service-L-CVAD-FAS-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-FAS-Admin' -Path "ou=FAS,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Full Permissions - Citrix FAS'
        New-ADGroup -Name 'Service-G-CVAD-FAS-CustomAdmin' -SamAccountName 'Service-G-CVAD-FAS-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-FAS-CustomAdmin' -Path "ou=FAS,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Constrained Permissions - Citrix FAS Administrators'
        New-ADGroup -Name 'Service-L-CVAD-FAS-CustomAdmin' -SamAccountName 'Service-L-CVAD-FAS-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-FAS-CustomAdmin' -Path "ou=FAS,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Constrained Permissions - Citrix FAS Administrators'
        New-ADGroup -Name 'Service-L-CVAD-FAS-OU' -SamAccountName 'Service-L-CVAD-FAS-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-FAS-OU' -Path "ou=FAS,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Full Control Rights Delegation - Citrix FAS OU and Policies'

        ##"ou=LIC,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        New-ADGroup -Name 'Service-G-CVAD-LIC-Admin' -SamAccountName 'Service-G-CVAD-LIC-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-LIC-Admin' -Path "ou=LIC,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Full Permissions - Citrix License Server'
        New-ADGroup -Name 'Service-L-CVAD-LIC-Admin' -SamAccountName 'Service-L-CVAD-LIC-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-LIC-Admin' -Path "ou=LIC,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Full Permissions - Citrix License Server'
        New-ADGroup -Name 'Service-G-CVAD-LIC-CustomAdmin' -SamAccountName 'Service-G-CVAD-LIC-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-LIC-CustomAdmin' -Path "ou=LIC,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Constrained Permissions - Citrix License Server Administrators'
        New-ADGroup -Name 'Service-L-CVAD-LIC-CustomAdmin' -SamAccountName 'Service-L-CVAD-LIC-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-LIC-CustomAdmin' -Path "ou=LIC,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Constrained Permissions - Citrix License Server Administrators'
        New-ADGroup -Name 'Service-L-CVAD-LIC-OU' -SamAccountName 'Service-L-CVAD-LIC-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-LIC-OU' -Path "ou=LIC,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Full Control Rights Delegation - Citrix License Server OU and Policies'

        ##"ou=PVS,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        New-ADGroup -Name 'Service-G-CVAD-PVS-Admin' -SamAccountName 'Service-G-CVAD-PVS-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-PVS-Admin' -Path "ou=PVS,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Full Permissions - Citrix Provisioning'
        New-ADGroup -Name 'Service-L-CVAD-PVS-Admin' -SamAccountName 'Service-L-CVAD-PVS-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-PVS-Admin' -Path "ou=PVS,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Full Permissions - Citrix Provisioning'
        New-ADGroup -Name 'Service-G-CVAD-PVS-CustomAdmin' -SamAccountName 'Service-G-CVAD-PVS-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-PVS-CustomAdmin' -Path "ou=PVS,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Constrained Permissions - Citrix Provisioning Administrators'
        New-ADGroup -Name 'Service-L-CVAD-PVS-CustomAdmin' -SamAccountName 'Service-L-CVAD-PVS-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-PVS-CustomAdmin' -Path "ou=PVS,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Constrained Permissions - Citrix Provisioning Administrators'
        New-ADGroup -Name 'Service-L-CVAD-PVS-OU' -SamAccountName 'Service-L-CVAD-PVS-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-PVS-OU' -Path "ou=PVS,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Full Control Rights Delegation - Citrix Provisioning OU and Policies'

        ##"ou=StoreFront,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        New-ADGroup -Name 'Service-G-CVAD-StoreFront-Admin' -SamAccountName 'Service-G-CVAD-StoreFront-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-StoreFront-Admin' -Path "ou=StoreFront,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Full Permissions - Citrix StoreFront'
        New-ADGroup -Name 'Service-L-CVAD-StoreFront-Admin' -SamAccountName 'Service-L-CVAD-StoreFront-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-StoreFront-Admin' -Path "ou=StoreFront,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Full Permissions - Citrix StoreFront'
        New-ADGroup -Name 'Service-G-CVAD-StoreFront-CustomAdmin' -SamAccountName 'Service-G-CVAD-StoreFront-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-StoreFront-CustomAdmin' -Path "ou=StoreFront,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Constrained Permissions - Citrix StoreFront Administrators'
        New-ADGroup -Name 'Service-L-CVAD-StoreFront-CustomAdmin' -SamAccountName 'Service-L-CVAD-StoreFront-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-StoreFront-CustomAdmin' -Path "ou=StoreFront,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Constrained Permissions - Citrix StoreFront Administrators'
        New-ADGroup -Name 'Service-L-CVAD-StoreFront-OU' -SamAccountName 'Service-L-CVAD-StoreFront-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-StoreFront-OU' -Path "ou=StoreFront,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Full Control Rights Delegation - Citrix StoreFront OU and Policies'

        #"ou=WEM,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        New-ADGroup -Name 'Service-G-CVAD-WEM-Admin' -SamAccountName 'Service-G-CVAD-WEM-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-WEM-Admin' -Path "ou=WEM,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Full Permissions - Citrix Workspace Environment Management'
        New-ADGroup -Name 'Service-L-CVAD-WEM-Admin' -SamAccountName 'Service-L-CVAD-WEM-Admin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-WEM-Admin' -Path "ou=WEM,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Full Permissions - Citrix WEM'
        New-ADGroup -Name 'Service-G-CVAD-WEM-CustomAdmin' -SamAccountName 'Service-G-CVAD-WEM-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Service-G-CVAD-WEM-CustomAdmin' -Path "ou=WEM,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Global - Constrained Permissions - Citrix WEM Administrators'
        New-ADGroup -Name 'Service-L-CVAD-WEM-CustomAdmin' -SamAccountName 'Service-L-CVAD-WEM-CustomAdmin' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-WEM-CustomAdmin' -Path "ou=WEM,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Domain Local - Constrained Permissions - Citrix WEM Administrators'
        New-ADGroup -Name 'Service-L-CVAD-WEM-OU' -SamAccountName 'Service-L-CVAD-WEM-OU' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'Service-L-CVAD-WEM-OU' -Path "ou=WEM,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Full Control Rights Delegation - Citrix WEM OU and Policies'
    }

    END {
            $endDate = Get-Date
            Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}
    
function Create-RoleBasedGroupAdmin
{
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ADDomain
    .PARAMETER TLD
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
        
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $ADDomain,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $TLD
    )

    BEGIN {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Create RoleBasedGroupAdmin"
        $startDate = Get-Date
    }

    PROCESS {
    #/lab.local/_Governed/Groups/Admin
    # SOAP, stream service to run - those accounts should become admins on PVS servers
    # admins are member of those ROLE groups
    
    #CVAD-Admins - should have local admin rights on VM's
    #CVAD-Admin  - should be added to AccountOperators AD group - otherwise you will not be able to provision Machines via MCS
    # https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/understand-security-groups#account-operators

    #/lab.local/_Governed/Groups/Admin
    #MS-MGMT-Admin - role Group for Management Server Administrators with Full Permissions
    New-ADGroup -Name 'MS-MGMT-Admin' -SamAccountName 'MS-MGMT-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'MS-MGMT-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - MGMT Plane - grants Admin Permissions'
    
    #/lab.local/_Governed/Groups/Admin
    #MS-MgmtNode-CustomAdmin - Role Group for Management Server Administrators with Restricted set of privileges
    New-ADGroup -Name 'MS-MGMT-CustomAdmin' -SamAccountName 'MS-MGMT-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'MS-MGMT-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - MGMT Plane - grants Constrained Admin Permissions'
    
    New-ADGroup -Name 'MS-ADCS-Admin' -SamAccountName 'MS-ADCS-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'MS-ADCS-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - ADCS/PKI - grants Admin Permissions'
    New-ADGroup -Name 'MS-ADCS-CustomAdmin' -SamAccountName 'MS-ADCS-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'MS-ADCS-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - ADCS/PKI - grants Constrained Admin Permissions'
    
    New-ADGroup -Name 'MS-DHCP-Admin' -SamAccountName 'MS-DHCP-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'MS-DHCP-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - DHCP - grants Admin Permissions'
    New-ADGroup -Name 'MS-DHCP-CustomAdmin' -SamAccountName 'MS-DHCP-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'MS-DHCP-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - DHCP - grants Constrained Admin Permissions'
    
    New-ADGroup -Name 'MS-FileServer-Admin' -SamAccountName 'MS-FileServer-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'MS-FileServer-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - File Server - grants Admin Permissions'
    New-ADGroup -Name 'MS-FileServer-CustomAdmin' -SamAccountName 'MS-FileServer-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'MS-FileServer-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - File Server - grants Constrained Admin Permissions'
    
    New-ADGroup -Name 'MS-SQL-Admin' -SamAccountName 'MS-SQL-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'MS-SQL-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - SQL - grants Admin Permissions'
    New-ADGroup -Name 'MS-SQL-CustomAdmin' -SamAccountName 'MS-SQL-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'MS-SQL-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - SQL - grants Constrained Admin Permissions'
    
    New-ADGroup -Name 'MS-APPV-Admin' -SamAccountName 'MS-APPV-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'MS-APPV-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - APP-V - grants Admin Permissions'
    New-ADGroup -Name 'MS-APPV-CustomAdmin' -SamAccountName 'MS-APPV-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'MS-APPV-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - APP-V - grants Constrained Admin Permissions'
    
    New-ADGroup -Name 'Hypervisor-Admin' -SamAccountName 'Hypervisor-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'Hypervisor-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - Hypervisor - grants Admin Permissions'
    New-ADGroup -Name 'Hypervisor-CustomAdmin' -SamAccountName 'Hypervisor-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'Hypervisor-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - Hypervisor - grants Constrained Admin Permissions'

    New-ADGroup -Name 'NetScaler-Admin' -SamAccountName 'NetScaler-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'NetScaler-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - NetScaler - grants Admin Permissions'
    New-ADGroup -Name 'NetScaler-CustomAdmin' -SamAccountName 'NetScaler-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'NetScaler-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - NetScaler - grants Constrained Admin Permissions'
    
       
    New-ADGroup -Name 'CVAD-CloudAdmin' -SamAccountName 'CVAD-CloudAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-CloudAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD DaaS - grants Cloud Admin Permissions'
    New-ADGroup -Name 'CVAD-Admin' -SamAccountName 'CVAD-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD - grants Full Admin Permissions'
    New-ADGroup -Name 'CVAD-ReadOnlyAdmin' -SamAccountName 'CVAD-ReadOnlyAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-ReadOnlyAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD - grants ReadOnly Permissions'
    New-ADGroup -Name 'CVAD-HelpDeskAdmin' -SamAccountName 'CVAD-HelpDeskAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-HelpDeskAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD - grants HelpDeskAdmin Permissions'
    New-ADGroup -Name 'CVAD-MachineCatalogAdmin' -SamAccountName 'CVAD-MachineCatalogAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-MachineCatalogAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD - grants Machine Catalog Admin Permissions'
    New-ADGroup -Name 'CVAD-DeliveryGroupAdmin' -SamAccountName 'CVAD-DeliveryGroupAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-DeliveryGroupAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD - grants Delivery Group Admin Permissions'
    New-ADGroup -Name 'CVAD-HostAdmin' -SamAccountName 'CVAD-HostAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-HostAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD - grants Host Admin Permissions'
    New-ADGroup -Name 'CVAD-SessionAdmin' -SamAccountName 'CVAD-SessionAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-SessionAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD - grants Session Admin Permissions'
    New-ADGroup -Name 'CVAD-MonitorAdmin' -SamAccountName 'CVAD-MonitorAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-MonitorAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD - grants Full Monitor Admin Permissions'
    New-ADGroup -Name 'CVAD-ProbeAgentAdmin' -SamAccountName 'CVAD-ProbeAgentAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-ProbeAgentAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD - grants Probe Agent Admin Permissions'

    New-ADGroup -Name 'CVAD-CustomAdmin' -SamAccountName 'CVAD-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD - grants Constrained Admin Permissions'
    
    New-ADGroup -Name 'CVAD-AppLayering-Admin' -SamAccountName 'CVAD-AppLayering-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-AppLayering-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD AppLayering - grants Admin Permissions'
    New-ADGroup -Name 'CVAD-AppLayering-CustomAdmin' -SamAccountName 'CVAD-AppLayering-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-Layering-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD AppLayering - grants Constrained Admin Permissions'

    New-ADGroup -Name 'CVAD-Broker-Admin' -SamAccountName 'CVAD-Broker-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-Broker-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD Broker - grants Admin Permissions'
    New-ADGroup -Name 'CVAD-Broker-CustomAdmin' -SamAccountName 'CVAD-Broker-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-Broker-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD Broker - grants Constrained Admin Permissions'

    New-ADGroup -Name 'CVAD-Director-Admin' -SamAccountName 'CVAD-Director-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-Director-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD Director - grants Admin Permissions'
    New-ADGroup -Name 'CVAD-Director-CustomAdmin' -SamAccountName 'CVAD-Director-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-Director-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD Director - grants Constrained Admin Permissions'

    New-ADGroup -Name 'CVAD-FAS-Admin' -SamAccountName 'CVAD-FAS-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-FAS-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD FAS - grants Admin Permissions'
    New-ADGroup -Name 'CVAD-FAS-CustomAdmin' -SamAccountName 'CVAD-FAS-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-FAS-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD FAS - grants Constrained Admin Permissions'

    New-ADGroup -Name 'CVAD-LIC-Admin' -SamAccountName 'CVAD-LIC-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-LIC-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD License Server - grants Admin Permissions'
    New-ADGroup -Name 'CVAD-LIC-CustomAdmin' -SamAccountName 'CVAD-LIC-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-LIC-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD License Server - grants Constrained Admin Permissions'

    New-ADGroup -Name 'CVAD-PVS-Admin' -SamAccountName 'CVAD-PVS-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-PVS-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD PVS - grants Admin Permissions'
    New-AdGroup -Name 'CVAD-PVS-CustomAdmin' -SamAccountName 'CVAD-PVS-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-PVS-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD PVS - grants Constrained Admin Permissions'

    New-ADGroup -Name 'CVAD-StoreFront-Admin' -SamAccountName 'CVAD-StoreFront-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-StoreFront-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD StoreFront - grants Admin Permissions'
    New-ADGroup -Name 'CVAD-StoreFront-CustomAdmin' -SamAccountName 'CVAD-StoreFront-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-StoreFront-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD StoreFront - grants Constrained Admin Permissions'

    New-ADGroup -Name 'CVAD-WEM-Admin' -SamAccountName 'CVAD-WEM-Admin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-WEM-Admin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD WEM - grants Admin Permissions'
    New-ADGroup -Name 'CVAD-WEM-CustomAdmin' -SamAccountName 'CVAD-WEM-CustomAdmin' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-WEM-CustomAdmin' -Path "ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - CVAD WEM - grants Constrained Admin Permissions'
    }

    END {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

function Create-RoleBasedGroupUser
{
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ADDomain
    .PARAMETER TLD
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
        
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $ADDomain,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $TLD
    )

    BEGIN {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Create RoleBasedGroupUser"
        $startDate = Get-Date
    }

    PROCESS {
        #/lab.local/_Governed/Groups/User
        New-ADGroup -Name 'MS-RDS-User' -SamAccountName 'MS-RDS-User' -GroupCategory Security -GroupScope Global -DisplayName 'MS-RDS-User' -Path "ou=User,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users making use of Remote Desktop Services'
        New-ADGroup -Name 'MS-FSLogix-User' -SamAccountName 'MS-FSLogix-User' -GroupCategory Security -GroupScope Global -DisplayName 'MS-FSLogix-User' -Path "ou=User,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users making use of MS FSLogix'

        New-ADGroup -Name 'CVAD-User' -SamAccountName 'CVAD-User' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-User' -Path "ou=User,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users making use of CVAD'
        New-ADGroup -Name 'CVAD-UPM-User' -SamAccountName 'CVAD-UPM-User' -GroupCategory Security -GroupScope Global -DisplayName 'CVAD-CPM-User' -Path "ou=User,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users making use of CVAD - Citrix Profile Manager'
    }

    END {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

function Create-ApplicationGroup
{
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ADDomain
    .PARAMETER TLD
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
        
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $ADDomain,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $TLD
    )

    BEGIN {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Create Application Group"
        $startDate = Get-Date
    }

    PROCESS {
        #/lab.local/_Governed/Groups/Application
        New-ADGroup -Name 'App-G-AcrobatReader' -SamAccountName 'App-G-AcrobatReader' -GroupCategory Security -GroupScope Global -DisplayName 'App-G-AcrobatReader' -Path "ou=Application,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - Members of this group can make use of Acrobat Reader App'
        New-ADGroup -Name 'App-L-AcrobatReader' -SamAccountName 'App-L-AcrobatReader' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'App-L-AcrobatReader' -Path "ou=Application,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Members of this group can make use of Acrobat Reader App'

        New-ADGroup -Name 'App-G-NotepadPlusPlus' -SamAccountName 'App-G-NotepadPlusPlus' -GroupCategory Security -GroupScope Global -DisplayName 'App-G-NotepadPlusPlus' -Path "ou=Application,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Placeholder for users - Members of this group can make use of Notepad++ App'
        New-ADGroup -Name 'App-L-NotePadPlusPlus' -SamAccountName 'App-L-NotePadPlusPlus' -GroupCategory Security -GroupScope DomainLocal -DisplayName 'App-L-NotePadPlusPlus' -Path "ou=Application,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD" -Description 'Members of this group can make use of Notepad++ App'
    }

    END {
            $endDate = Get-Date
            Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }

}
    
function Create-ComputerObject
{
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ADDomain
    .PARAMETER TLD
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>

    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $ADDomain,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $TLD
    )

    BEGIN {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Create Computer Object"
        $startDate = Get-Date
    }

    PROCESS {
    #ADCS Root is outside of the domain  - adcsr
        #ADCS Sub is domain joined           - adcss
        
        #/lab.local/_Governed/Infra/Citrix/CVAD/Broker
        1..2 | Foreach-Object {
            $temp = $_.ToString("$('ddc')00")
            $tempName = $_.ToString("CVAD - Broker Server 00")
            Write-Verbose "Computer object created: $temp - $tempName"
            #New-ADComputer -Name $temp -SAMAccountName $temp -Description $tempName -Path "ou=Broker,ou=CVAD,ou=Citrix,ou=Infra,ou=_Governed,dc=$ADDomain,dc=$TLD" -Enabled $True
        }
    }

    END {
            $endDate = Get-Date
            Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

function Create-AdminUserObject
{
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ADDomain
    .PARAMETER TLD
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
        
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $ADDomain,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $TLD
    )
    BEGIN {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Create Admin User Object"
        $startDate = Get-Date
    }

    PROCESS {
        #/lab.local/_Governed/Accounts/Admin
        #EUC Admin and User Accounts
        
        #admin account
        #/lab.local/_Governed/Accounts/Admin
        New-ADUser -Name 'a_test' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'Admin' `
        -Surname 'Labber' `
        -Description 'tireless sculptor - Admin' `
        -DisplayName 'a_test' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=TEST,ou=Admin,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" `
        -SamAccountName 'a_test' `
        -UserPrincipalName "a_test@$ADDomain.$TLD"

        New-ADUser -Name 'a_andrzej' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'Admin' `
        -Surname 'Andrzej' `
        -Description 'Andrzej ShadowIT - Admin' `
        -DisplayName 'a_andrzej' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=Admin,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 'a_andrzej' `
        -UserPrincipalName "a_andrzej@$ADDomain.$TLD"

        New-ADUser -Name 'a_piotrek' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'Admin' `
        -Surname 'Piotrek' `
        -Description 'The wanderer - Admin' `
        -DisplayName 'a_piotrek' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=Admin,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 'a_piotrek' `
        -UserPrincipalName "a_piotrek@$ADDomain.$TLD"

        New-ADUser -Name 'a_temp' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'Admin' `
        -Surname 'Temporarily Elevated Roles' `
        -Description 'Admin with temporarily given permissions' `
        -DisplayName 'a_temp' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=TEST,ou=Admin,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 'a_temp' `
        -UserPrincipalName "a_temp@$ADDomain.$TLD"

        New-ADUser -Name 'a_cvad' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'Admin' `
        -Surname 'CVAD' `
        -Description 'CVAD Administrator' `
        -DisplayName 'a_cvad' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=CVAD,ou=Admin,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 'a_cvad' `
        -UserPrincipalName "a_cvad@$ADDomain.$TLD"

        New-ADUser -Name 'a_cvad-cpm' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'Admin' `
        -Surname 'CVAD CPM' `
        -Description 'CVAD Citrix Profile Management' `
        -DisplayName 'a_cvad-cpm' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=CVAD,ou=Admin,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 'a_cvad-cpm' `
        -UserPrincipalName "a_cvad-cpm@$ADDomain.$TLD"

        New-ADUser -Name 'a_rds' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'User' `
        -Surname 'RDS' `
        -Description 'Remote Desktop Services Admin' `
        -DisplayName 'a_rds' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=MS,ou=Admin,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 'a_rds' `
        -UserPrincipalName "a_rds@$ADDomain.$TLD"

        New-ADUser -Name 'a_fslogix' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'User' `
        -Surname 'FSLogix Admin' `
        -Description '' `
        -DisplayName 'a_fslogix' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=MS,ou=Admin,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 'a_fslogix' `
        -UserPrincipalName "a_fslogix@$ADDomain.$TLD"
    }

    END {
            $endDate = Get-Date
            Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

function Create-TestUserObject {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ADDomain
    .PARAMETER TLD
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
        
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $ADDomain,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $TLD
    )
    BEGIN {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Create Test User Object"
        $startDate = Get-Date
    }

    PROCESS {
        #/lab.local/_Governed/Accounts/User
        #test account
        New-ADUser -Name 't_test' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'Tester' `
        -Surname 'Labber' `
        -Description 'tireless sculptor - Tester' `
        -DisplayName 't_test' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=TEST,ou=Test,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" `
        -SamAccountName 't_test' `
        -UserPrincipalName "t_test@$ADDomain.$TLD"

        New-ADUser -Name 't_andrzej' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'Tester' `
        -Surname 'Andrzej' `
        -Description 'Andrzej ShadowIT - Tester' `
        -DisplayName 't_andrzej' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=Test,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 't_andrzej' `
        -UserPrincipalName "t_andrzej@$ADDomain.$TLD"

        New-ADUser -Name 't_piotrek' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'Tester' `
        -Surname 'Piotrek' `
        -Description 'The wanderer - Tester' `
        -DisplayName 't_piotrek' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=Test,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 't_piotrek' `
        -UserPrincipalName "t_piotrek@$ADDomain.$TLD"

        New-ADUser -Name 't_temp' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'Tester' `
        -Surname 'Temporarily Elevated Roles' `
        -Description 'Tester with temporarily given permissions' `
        -DisplayName 't_temp' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=TEST,ou=Test,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 't_temp' `
        -UserPrincipalName "t_temp@$ADDomain.$TLD"

        New-ADUser -Name 't_cvad' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'Tester' `
        -Surname 'CVAD' `
        -Description 'CVAD - Tester' `
        -DisplayName 't_cvad' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=CVAD,ou=Test,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 't_cvad' `
        -UserPrincipalName "t_cvad@$ADDomain.$TLD"

        New-ADUser -Name 't_cvad-cpm' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'Tester' `
        -Surname 'CVAD CPM' `
        -Description 'CVAD Citrix Profile Management - Tester' `
        -DisplayName 't_cvad-cpm' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=CVAD,ou=Test,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 't_cvad-cpm' `
        -UserPrincipalName "t_cvad-cpm@$ADDomain.$TLD"

        New-ADUser -Name 't_rds' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'Tester' `
        -Surname 'RDS' `
        -Description 'Remote Desktop Services - Tester' `
        -DisplayName 't_rds' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=MS,ou=Test,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 't_rds' `
        -UserPrincipalName "t_rds@$ADDomain.$TLD"

        New-ADUser -Name 't_fslogix' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'Tester' `
        -Surname 'FSLogix - Tester' `
        -Description '' `
        -DisplayName 't_fslogix' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=MS,ou=Test,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 't_fslogix' `
        -UserPrincipalName "t_fslogix@$ADDomain.$TLD"
    }

    END {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

function Create-UserObject {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ADDomain
    .PARAMETER TLD
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
        
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $ADDomain,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $TLD
    )
    BEGIN {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Create User Object"
        $startDate = Get-Date
    }

    PROCESS {
        #/lab.local/_Governed/Accounts/User
        #user account
        New-ADUser -Name 'u_test' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'User' `
        -Surname 'Labber' `
        -Description 'tireless sculptor - User' `
        -DisplayName 't_test' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=TEST,ou=User,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" `
        -SamAccountName 'u_test' `
        -UserPrincipalName "u_test@$ADDomain.$TLD"

        New-ADUser -Name 'u_andrzej' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'User' `
        -Surname 'Andrzej' `
        -Description 'Andrzej ShadowIT - User' `
        -DisplayName 't_andrzej' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=User,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 'u_andrzej' `
        -UserPrincipalName "u_andrzej@$ADDomain.$TLD"

        New-ADUser -Name 'u_piotrek' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'User' `
        -Surname 'Piotrek' `
        -Description 'The wanderer - User' `
        -DisplayName 'u_piotrek' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=User,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 'u_piotrek' `
        -UserPrincipalName "u_piotrek@$ADDomain.$TLD"

        New-ADUser -Name 'u_temp' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'User' `
        -Surname 'Temporarily Elevated Roles' `
        -Description 'User with temporarily given permissions' `
        -DisplayName 'u_temp' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=TEST,ou=User,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 'u_temp' `
        -UserPrincipalName "u_temp@$ADDomain.$TLD"

        New-ADUser -Name 'u_cvad' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'User' `
        -Surname 'CVAD' `
        -Description 'CVAD - User' `
        -DisplayName 'u_cvad' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=CVAD,ou=User,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 'u_cvad' `
        -UserPrincipalName "u_cvad@$ADDomain.$TLD"

        New-ADUser -Name 'u_cvad-cpm' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'User' `
        -Surname 'CVAD CPM' `
        -Description 'CVAD Citrix Profile Management - User' `
        -DisplayName 'u_cvad-cpm' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=CVAD,ou=User,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 'u_cvad-cpm' `
        -UserPrincipalName "u_cvad-cpm@$ADDomain.$TLD"

        New-ADUser -Name 'u_rds' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'User' `
        -Surname 'RDS' `
        -Description 'Remote Desktop Services - User' `
        -DisplayName 'u_rds' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=MS,ou=User,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 'u_rds' `
        -UserPrincipalName "u_rds@$ADDomain.$TLD"

        New-ADUser -Name 'u_fslogix' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -GivenName 'User' `
        -Surname 'FSLogix - User' `
        -Description '' `
        -DisplayName 'u_fslogix' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=MS,ou=User,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"  `
        -SamAccountName 'u_fslogix' `
        -UserPrincipalName "u_fslogix@$ADDomain.$TLD"
    }

    END {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}
    
function Create-ServiceAccount
{
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ADDomain
    .PARAMETER TLD
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
        
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $ADDomain,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $TLD
    )

    BEGIN {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Create Service Account"
        $startDate = Get-Date
    }

    PROCESS {
        #/lab.local/_Governed/Accounts/Service
        New-ADUser -Name 'svc-Hypervisor' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -Description 'Service Account - Hypervisor' `
        -DisplayName 'svc-Hypervisor' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=Service,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" `
        -SamAccountName 'svc-Hypervisor' `
        -UserPrincipalName "svc-Hypervisor@$ADDomain.$TLD"

        New-ADUser -Name 'svc-MS-SQL' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -Description 'Service Account - SQL' `
        -DisplayName 'svc-MS-SQL' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=Service,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" `
        -SamAccountName 'svc-MS-SQL' `
        -UserPrincipalName "svc-MS-SQL@$ADDomain.$TLD"

        New-ADUser -Name 'svc-MS-AppV' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -Description 'Service Account - AppV' `
        -DisplayName 'svc-MS-AppV' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=Service,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" `
        -SamAccountName 'svc-MS-AppV' `
        -UserPrincipalName "svc-MS-AppV@$ADDomain.$TLD"

        New-ADUser -Name 'svc-CVAD-PVS' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -Description 'Service Account - CVAD PVS' `
        -DisplayName 'svc-CVAD-PVS' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=Service,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" `
        -SamAccountName 'svc-CVAD-PVS' `
        -UserPrincipalName "svc-CVAD-PVS@$ADDomain.$TLD"

        New-ADUser -Name 'svc-CVAD-Director' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -Description 'Service Account - Citrix Director' `
        -DisplayName 'svc-CVAD-Director' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=Service,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" `
        -SamAccountName 'svc-CVAD-Director' `
        -UserPrincipalName "svc-CVAD-Director@$ADDomain.$TLD"

        #ADCS / PKI
        New-ADUser -Name 'svc-MS-ADCS' `
        -AccountPassword $CryptoPwd `
        -CannotChangePassword $True `
        -ChangePasswordAtLogon $False `
        -Description 'Service Account - Active Directory Certification Services' `
        -DisplayName 'svc-MS-ADCS' `
        -Enabled $True `
        -PasswordNeverExpires $True `
        -Path "ou=Service,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" `
        -SamAccountName 'svc-MS-ADCS' `
        -UserPrincipalName "$svc-MS-ADCS@$ADDomain.$TLD"
    }

    END {
            $endDate = Get-Date
            Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

function Configure-GroupMemberShipServiceAccount {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ADDomain
    .PARAMETER TLD
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
        
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $ADDomain,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $TLD
    )

    BEGIN {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Configure Group Membership - service account"
        $startDate = Get-Date

        #/lab.local/_Governed/Accounts/Service
        $serviceAccount = get-aduser -searchbase "ou=Service,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -filter *
    }

    PROCESS {

    }

    END {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

function Configure-GroupMembershipAdminAccount {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ADDomain
    .PARAMETER TLD
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
        
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $ADDomain,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $TLD
    )

    BEGIN {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Configure Group Membership - Admin account"
        $startDate = Get-Date

        #/lab.local/_Governed/Accounts/Admin
        $adminAccount = get-aduser -searchbase "ou=Admin,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -filter *
    }

    PROCESS {
        # add all users from "ou=Admin,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD"
        # to MS-APPV-Admin Group and all other admin a groups
        #admin accounts

        #MS-MGMT-Admin
        Add-ADGroupMember -Identity 'MS-MGMT-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-MS-MGMT-Admin' -Members 'MS-MGMT-Admin'
        Add-ADGroupMember -Identity 'Service-G-MS-MGMT-CustomAdmin' -Members 'MS-MGMT-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-MS-MGMT-Admin' -Members 'Service-G-MS-MGMT-Admin'
        Add-ADGroupMember -Identity 'Service-L-MS-MGMT-OU' -Members 'MS-MGMT-Admin'

        # repeat the step above for all other admin groups like CVAD-Admin, CVAD-PVS-Admin, etc

        #MS-ADCS-Admin
        Add-ADGroupMember -Identity 'MS-ADCS-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-MS-ADCS-Admin' -Members 'MS-ADCS-Admin'
        Add-ADGroupMember -Identity 'Service-G-MS-ADCS-CustomAdmin' -Members 'MS-ADCS-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-MS-ADCS-Admin' -Members 'Service-G-MS-ADCS-Admin'
        Add-ADGroupMember -Identity 'Service-L-MS-ADCS-OU' -Members 'MS-ADCS-Admin'

        #MS-DHCP-Admin
        Add-ADGroupMember -Identity 'MS-DHCP-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-MS-DHCP-Admin' -Members 'MS-DHCP-Admin'
        Add-ADGroupMember -Identity 'Service-G-MS-DHCP-CustomAdmin' -Members 'MS-DHCP-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-MS-DHCP-Admin' -Members 'Service-G-MS-DHCP-Admin'
        Add-ADGroupMember -Identity 'Service-L-MS-DHCP-OU' -Members 'MS-DHCP-Admin'

        #MS-FileServer-Admin
        Add-ADGroupMember -Identity 'MS-FileServer-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-MS-FileServer-Admin' -Members 'MS-FileServer-Admin'
        Add-ADGroupMember -Identity 'Service-G-MS-FileServer-CustomAdmin' -Members 'MS-FileServer-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-MS-FileServer-Admin' -Members 'Service-G-MS-FileServer-Admin'
        Add-ADGroupMember -Identity 'Service-L-MS-FileServer-OU' -Members 'MS-FileServer-Admin'

        #MS-SQL-Admin
        Add-ADGroupMember -Identity 'MS-SQL-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-MS-SQL-Admin' -Members 'MS-SQL-Admin'
        Add-ADGroupMember -Identity 'Service-G-MS-SQL-CustomAdmin' -Members 'MS-SQL-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-MS-SQL-Admin' -Members 'Service-G-MS-SQL-Admin'
        Add-ADGroupMember -Identity 'Service-L-MS-SQL-OU' -Members 'MS-SQL-Admin'

        #MS-APPV-Admin
        Add-ADGroupMember -Identity 'MS-APPV-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-MS-APPV-Admin' -Members 'MS-APPV-Admin'
        Add-ADGroupMember -Identity 'Service-G-MS-APPV-CustomAdmin' -Members 'MS-APPV-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-MS-APPV-Admin' -Members 'Service-G-MS-APPV-Admin'
        Add-ADGroupMember -Identity 'Service-L-MS-APPV-OU' -Members 'MS-APPV-Admin'

        #Hypervisor-Admin
        Add-ADGroupMember -Identity 'Hypervisor-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-Hypervisor-Admin' -Members 'Hypervisor-Admin'
        Add-ADGroupMember -Identity 'Service-G-Hypervisor-CustomAdmin' -Members 'Hypervisor-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-Hypervisor-Admin' -Members 'Service-G-Hypervisor-Admin'
        Add-ADGroupMember -Identity 'Service-L-Hypervisor-OU' -Members 'Hypervisor-Admin'

        #NetScaler-Admin
        Add-ADGroupMember -Identity 'NetScaler-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-NetScaler-Admin' -Members 'NetScaler-Admin'
        Add-ADGroupMember -Identity 'Service-G-NetScaler-CustomAdmin' -Members 'NetScaler-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-NetScaler-Admin' -Members 'Service-G-NetScaler-Admin'
        Add-ADGroupMember -Identity 'Service-L-NetScaler-OU' -Members 'NetScaler-Admin'

        #CVAD-Admin
        Add-ADGroupMember -Identity 'CVAD-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-CVAD-Admin' -Members 'CVAD-Admin'
        Add-ADGroupMember -Identity 'Service-G-CVAD-CustomAdmin' -Members 'CVAD-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-Admin' -Members 'Service-G-CVAD-Admin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-OU' -Members 'CVAD-Admin'

        #CVAD-HelpDeskAdmin
        #Add-ADGroupMember -Identity 'CVAD-HelpDeskAdmin' -Members $adminAccount

        #Add-ADGroupMember -Identity 'Service-G-CVAD-Helpdesk-Admin' -Members 'CVAD-Admin'
        #Add-ADGroupMember -Identity 'Service-G-CVAD-CustomAdmin' -Members 'CVAD-CustomAdmin'
        #Add-ADGroupMember -Identity 'Service-L-CVAD-Admin' -Members 'Service-G-CVAD-Admin'
        #Add-ADGroupMember -Identity 'Service-L-CVAD-OU' -Members 'CVAD-Admin'

        #CVAD-AppLayering-Admin
        Add-ADGroupMember -Identity 'CVAD-AppLayering-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-CVAD-AppLayering-Admin' -Members 'CVAD-AppLayering-Admin'
        Add-ADGroupMember -Identity 'Service-G-CVAD-AppLayering-CustomAdmin' -Members 'CVAD-AppLayering-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-AppLayering-Admin' -Members 'Service-G-CVAD-AppLayering-Admin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-AppLayering-OU' -Members 'CVAD-AppLayering-Admin'

        #CVAD-Broker-Admin
        Add-ADGroupMember -Identity 'CVAD-Broker-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-CVAD-Broker-Admin' -Members 'CVAD-Broker-Admin'
        Add-ADGroupMember -Identity 'Service-G-CVAD-Broker-CustomAdmin' -Members 'CVAD-Broker-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-Broker-Admin' -Members 'Service-G-CVAD-Broker-Admin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-Broker-OU' -Members 'CVAD-Broker-Admin'
        
        #CVAD-Director-Admin
        Add-ADGroupMember -Identity 'CVAD-Director-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-CVAD-Director-Admin' -Members 'CVAD-Director-Admin'
        Add-ADGroupMember -Identity 'Service-G-CVAD-Director-CustomAdmin' -Members 'CVAD-Director-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-Director-Admin' -Members 'Service-G-CVAD-Director-Admin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-Director-OU' -Members 'CVAD-Director-Admin'

        #CVAD-FAS-Admin
        Add-ADGroupMember -Identity 'CVAD-FAS-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-CVAD-FAS-Admin' -Members 'CVAD-FAS-Admin'
        Add-ADGroupMember -Identity 'Service-G-CVAD-FAS-CustomAdmin' -Members 'CVAD-FAS-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-FAS-Admin' -Members 'Service-G-CVAD-FAS-Admin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-FAS-OU' -Members 'CVAD-FAS-Admin'

        #CVAD-LIC-Admin
        Add-ADGroupMember -Identity 'CVAD-LIC-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-CVAD-LIC-Admin' -Members 'CVAD-LIC-Admin'
        Add-ADGroupMember -Identity 'Service-G-CVAD-LIC-CustomAdmin' -Members 'CVAD-LIC-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-LIC-Admin' -Members 'Service-G-CVAD-LIC-Admin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-LIC-OU' -Members 'CVAD-LIC-Admin'

        #CVAD-PVS-Admin
        Add-ADGroupMember -Identity 'CVAD-PVS-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-CVAD-PVS-Admin' -Members 'CVAD-PVS-Admin'
        Add-ADGroupMember -Identity 'Service-G-CVAD-PVS-CustomAdmin' -Members 'CVAD-PVS-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-PVS-Admin' -Members 'Service-G-CVAD-PVS-Admin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-PVS-OU' -Members 'CVAD-PVS-Admin'

        #CVAD-StoreFront-Admin
        Add-ADGroupMember -Identity 'CVAD-StoreFront-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-CVAD-StoreFront-Admin' -Members 'CVAD-StoreFront-Admin'
        Add-ADGroupMember -Identity 'Service-G-CVAD-StoreFront-CustomAdmin' -Members 'CVAD-StoreFront-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-StoreFront-Admin' -Members 'Service-G-CVAD-StoreFront-Admin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-StoreFront-OU' -Members 'CVAD-StoreFront-Admin'

        #CVAD-WEM-Admin
        Add-ADGroupMember -Identity 'CVAD-WEM-Admin' -Members $adminAccount

        Add-ADGroupMember -Identity 'Service-G-CVAD-WEM-Admin' -Members 'CVAD-WEM-Admin'
        Add-ADGroupMember -Identity 'Service-G-CVAD-WEM-CustomAdmin' -Members 'CVAD-WEM-CustomAdmin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-WEM-Admin' -Members 'Service-G-WEM-Admin'
        Add-ADGroupMember -Identity 'Service-L-CVAD-WEM-OU' -Members 'CVAD-WEM-Admin'
    }

    END {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }    
}

function Configure-GroupMembershipUserAccount {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ADDomain
    .PARAMETER TLD
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
        
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $ADDomain,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $TLD
    )

    BEGIN {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Configure Group Membership - User Account"
        $startDate = Get-Date

        #/lab.local/_Governed/Accounts/User
        $userAccount = get-aduser -SearchBase "ou=User,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -filter *
    }

    PROCESS {
    
    }

    END {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

function Configure-GroupMembershipTestAccount {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ADDomain
    .PARAMETER TLD
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>
        
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $ADDomain,

        [Parameter(Mandatory=$true,Position=1,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        $TLD
    )

    BEGIN {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Configure Group Membership - Test Account"
        $startDate = Get-Date

        #/lab.local/_Governed/Accounts/User
        $testAccount = get-aduser -SearchBase "ou=Test,ou=Accounts,ou=_Governed,dc=$ADDomain,dc=$TLD" -filter *
    }

    PROCESS {
    
    }

    END {
        $endDate = Get-Date
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

function Set-ADDelegation {
    <#
    .SYNOPSIS

    .DESCRIPTION
    written by AI  

    .PARAMETER OuPath

    .PARAMETER GroupName

    .EXAMPLE

    .EXAMPLE

    .LINK
    https://sysjam.wordpress.com/2015/04/08/modifying-permissions-on-an-active-directory-with-powershell/

    .LINK
    https://blogs.technet.microsoft.com/joec/2013/04/25/active-directory-delegation-via-powershell/

    .LINK
    https://social.technet.microsoft.com/Forums/Lync/en-US/df3bfd33-c070-4a9c-be98-c4da6e591a0a/forum-faq-using-powershell-to-assign-permissions-on-active-directory-objects?forum=winserverpowershell

    .LINK
    http://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectoryrights(v=vs.110).aspx
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$OUPath,

        [Parameter(Mandatory=$true)]
        [string]$GroupName
    )

    BEGIN {
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Set AD delegation - $($OUPath) - $($GroupName)"
        $startDate = Get-Date
    }

    PROCESS {
        # Navigate to the AD drive
        cd ad:

        # Get a reference to the RootDSE of the current domain
        $rootdse = Get-ADRootDSE

        # Create a hashtable to store the GUID value of each schema class and attribute
        $guidmap = @{}
        Get-ADObject -SearchBase $rootdse.SchemaNamingContext -LDAPFilter "(schemaidguid=*)" -Properties lDAPDisplayName,schemaIDGUID | ForEach-Object {
            $guidmap[$_.lDAPDisplayName] = [System.GUID]$_.schemaIDGUID
        }

        # Create a hashtable to store the GUID value of each extended right in the forest
        $extendedrightsmap = @{}
        Get-ADObject -SearchBase $rootdse.ConfigurationNamingContext -LDAPFilter "(&(objectclass=controlAccessRight)(rightsguid=*))" -Properties displayName,rightsGuid | ForEach-Object {
            $extendedrightsmap[$_.displayName] = [System.GUID]$_.rightsGuid
        }

        # Get a reference to the OU we want to delegate
        $ou = Get-ADOrganizationalUnit -Identity $OUPath

        # Get the SID of the group we wish to delegate access to
        $groupSID = (Get-ADGroup $GroupName).SID

        # Get a copy of the current DACL on the OU
        $acl = Get-Acl -Path ("AD:\" + $ou.DistinguishedName)

        # Create an Access Control Entry for new permission we wish to add
        # Allow the group to write all properties of descendent user objects
        $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule (
            $groupSID,                              # Identity
            "GenericAll",                           # AccessMask
            "Allow",                                # InheritanceType
            "Descendents",                          # ObjectTypeGuid
            $guidmap["user"]                        # SchemaIDGUID for the user class
        )
        
        # Add the Access Control Entry to the ACL
        $acl.AddAccessRule($ace)

        # Apply the modified ACL back to the OU
        Set-Acl -AclObject $acl -Path ("AD:\" + $ou.DistinguishedName) -Verbose
    }

    END {
            $endDate = Get-Date
            Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }
}

function Configure-ADDelegation {
    <#
    .SYNOPSIS
    .DESCRIPTION
    .PARAMETER ADDomain
    .PARAMETER TLD
    .EXAMPLE
    .EXAMPLE
    .LINK
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$OUPath,

        [Parameter(Mandatory=$true)]
        [string]$GroupName
    )

    BEGIN {
        # Each time there is an OU added into the structure
        # it needs to be reflected with a Service ad group
        # when Service group arise then it should be added into the AD Delegation towards it's OU
        Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Configure AD Delegation"
        $startDate = Get-Date
    }

    PROCESS {
        Set-ADDelegation -GroupName 'Service-L-MS-APPV-OU' -OUPath "ou=APPV,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        Set-ADDelegation -GroupName 'Service-L-MS-MGMT-OU' -OUPath "ou=MGMT,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        Set-ADDelegation -GroupName 'Service-L-MS-ADCS-OU' -OUPath "ou=ADCS,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        Set-ADDelegation -GroupName 'Service-L-MS-DHCP-OU' -OUPath "ou=DHCP,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        Set-ADDelegation -GroupName 'Service-L-MS-FileServer-OU' -OUPath "ou=FileServer,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        Set-ADDelegation -GroupName 'Service-L-MS-SQL-OU' -OUPath "ou=SQL,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        Set-ADDelegation -GroupName 'Service-L-MS-APPV-OU' -OUPath "ou=AppV,ou=MS,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=lab,dc=local"

        Set-ADDelegation -GroupName 'Service-L-Hypervisor-OU' -OUPath "ou=Hypervisor,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        Set-ADDelegation -GroupName 'Service-L-NetScaler-OU' -OUPath "ou=NetScaler,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"

        # TODO: apply this logic to RDS OU
        Set-ADDelegation -GroupName 'Service-L-CVAD-OU' -OUPath "ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"

        Set-ADDelegation -GroupName 'Service-L-CVAD-AppLayering-OU' -OUPath "ou=AppLayering,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        Set-ADDelegation -GroupName 'Service-L-CVAD-Broker-OU' -OUPath "ou=Broker,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        Set-ADDelegation -GroupName 'Service-L-CVAD-Director-OU' -OUPath "ou=Director,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        Set-ADDelegation -GroupName 'Service-L-CVAD-FAS-OU' -OUPath "ou=FAS,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        Set-ADDelegation -GroupName 'Service-L-CVAD-LIC-OU' -OUPath "ou=LIC,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        Set-ADDelegation -GroupName 'Service-L-CVAD-PVS-OU' -OUPath "ou=PVS,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        Set-ADDelegation -GroupName 'Service-L-CVAD-StoreFront-OU' -OUPath "ou=StoreFront,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
        Set-ADDelegation -GroupName 'Service-L-CVAD-WEM-OU' -OUPath "ou=WEM,ou=CVAD,ou=Services,ou=Admin,ou=Groups,ou=_Governed,dc=$ADDomain,dc=$TLD"
    }

    END {
            $endDate = Get-Date
            Write-Verbose "$env:COMPUTERNAME - $($MyInvocation.MyCommand) - Time taken: $("{0:%d}d:{0:%h}h:{0:%m}m:{0:%s}s" -f ((New-TimeSpan -Start $startDate -End $endDate)))"
    }

}

#endregion

$ADDomain = 'lab'
$TLD = 'local'

$password = 'Password1!'
$CryptoPwd = (ConvertTo-SecureString -AsPlainText $password -Force)

Create-Ou -ADDomain $ADDomain -TLD $TLD -Verbose
Create-DelegationGroup -ADDomain $ADDomain -TLD $TLD -Verbose

Create-RoleBasedGroupAdmin -ADDomain $ADDomain -TLD $TLD -Verbose
Create-RoleBasedGroupUser -ADDomain $ADDomain -TLD $TLD -Verbose

Create-ApplicationGroup -ADDomain $ADDomain -TLD $TLD -Verbose
Create-ComputerObject -ADDomain $ADDomain -TLD $TLD -Verbose

Create-AdminUserObject -ADDomain $ADDomain -TLD $TLD -Verbose
Create-TestUserObject -ADDomain $ADDomain -TLD $TLD -Verbose
Create-UserObject -ADDomain $ADDomain -TLD $TLD -Verbose

Create-ServiceAccount -ADDomain $ADDomain -TLD $TLD -Verbose
Configure-GroupMemberShipServiceAccount -ADDomain $ADDomain -TLD $TLD -Verbose
Configure-GroupMembershipAdminAccount -ADDomain $ADDomain -TLD $TLD -Verbose
Configure-GroupMembershipUserAccount -ADDomain $ADDomain -TLD $TLD -Verbose
Configure-GroupMembershipTestAccount -ADDomain $ADDomain -TLD $TLD -Verbose

Configure-ADDelegation