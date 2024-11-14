#

It is part of the blog post series: [makeitcloudy.pl](https://makeitcloudy.pl/windows-DSC/)

## windows-preparation

Run_initialSetup.ps1 is used in:

* [windows-preparation](https://makeitcloudy.pl/windows-preparation/) - paragraph 2.0.2
* [windows-role-DSC](https://makeitcloudy.pl/windows-role-DSC/) - through deployments of Windows Roles

### run_initialSetup.ps1

Core here is a duplicate (anytime the source is updated, those changes should be reflected here in README.md) of:

```powershell
#Start-Process PowerShell_ISE -Verb RunAs
# run in elevated PowerShell session
#region initialize variables
$scriptName     = 'InitialConfig.ps1'
$uri            = 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode',$scriptName -join '/'
$path           = "$env:USERPROFILE\Documents"
$outFile        = Join-Path -Path $path -ChildPath $scriptName

#endregion

# set the execution policy
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force

#region download function Get-GitModule.ps1
Set-Location -Path $path
Invoke-WebRequest -Uri $uri -OutFile $outFile -Verbose
#psedit $outFile

# load function into memory
. $outFile
#psedit $outfile
Set-InitialConfiguration -Verbose
#endregion

Restart-Computer -Force

```

* [run_initialSetup.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/windows-preparation/run_initialSetup.ps1) - GitHub
* [run_initialSetup.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/_blogPost/windows-preparation/run_initialSetup.ps1) - GitHub raw
* [InitialConfig.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfig.ps1) - GitHub
* [InitialConfig.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfig.ps1) - GitHub raw

## windows-dsc

### run_adds-dev.ps1

Current code is a duplicate (anytime the source is updated, those changes should be reflected here in README.md) of:

```powershell
#Start-Process PowerShell_ISE -Verb RunAs
# run in elevated PowerShell session
Set-Location -Path "$env:USERPROFILE\Documents"

Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory-dev_demo.ps1' -OutFile "$env:USERPROFILE\Documents\ActiveDirectory-dev_demo.ps1" -Verbose
#psedit "$env:USERPROFILE\Documents\ActiveDirectory-dev_demo.ps1"

# at this stage the computername is already renamed and it's name is : b2-dc01
. "$env:USERPROFILE\Documents\ActiveDirectory-dev_demo.ps1" -ComputerName $env:Computername

```

* [run_adds-dev.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/windows-DSC/run_adds-dev.ps1) - GitHub
* [run_adds-dev.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/_blogPost/windows-DSC/run_adds-dev.ps1) - GitHub raw
* [ActiveDirectory-dev_demo.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/005_ActiveDirectory-dev_demo.ps1) - GitHub
* [ActiveDirectory-dev_demo.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory-dev_demo.ps1) - GitHub raw

### run_adds.ps1

Current code is a duplicate (anytime the source is updated, those changes should be reflected here in README.md) of:

```powershell
#Start-Process PowerShell_ISE -Verb RunAs
# run in elevated PowerShell session
Set-Location -Path "$env:USERPROFILE\Documents"

Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory_demo.ps1' -OutFile "$env:USERPROFILE\Documents\ActiveDirectory_demo.ps1" -Verbose
#psedit "$env:USERPROFILE\Documents\ActiveDirectory_demo.ps1"

# at this stage the computername is already renamed and it's name is : dc01
. "$env:USERPROFILE\Documents\ActiveDirectory_demo.ps1" -ComputerName $env:Computername

```

* [run_adds.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/windows-DSC/run_adds.ps1) - GitHub
* [run_adds.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/_blogPost/windows-DSC/run_adds.ps1) - GitHub raw
* [ActiveDirectory_demo.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/005_ActiveDirectory_demo.ps1) - GitHub
* [ActiveDirectory_demo.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory_demo.ps1) - GitHub raw

### run_initialConfigDSC_domain-dev.ps1

Current code is a duplicate (anytime the source is updated, those changes should be reflected here in README.md) of:

```powershell
$domainName = 'd.local'  #FIXME
Set-InitialConfigDevDsc -NewComputerName $env:computername -Option Domain -DomainName $domainName -Verbose

```

Refences used in the function above:

* [run_initialConfigDSC_domain-dev.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/windows-DSC/run_initialConfigDsc_domain-dev.ps1) - GitHub
* [run_initialConfigDSC_domain-dev.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/_blogPost/windows-DSC/run_initialConfigDsc_domain-dev.ps1) - GitHub raw
* [InitialConfigDsc.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc.ps1) - GitHub
* [InitialConfigDsc.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc.ps1) - GitHub raw
* [ConfigData-dev.psd1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigData-dev.psd1)
* [ConfigureLCM.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigureLCM.ps1)
* [ConfigureNode.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigureNode.ps1)

### run_initialConfigDSC_domain.ps1

Current code is a duplicate (anytime the source is updated, those changes should be reflected here in README.md) of:

```powershell
$domainName = 'lab.local'  #FIXME
Set-InitialConfigDsc -NewComputerName $env:computername -Option Domain -DomainName $domainName -Verbose

```

Refences used in the function above:

* [run_initialConfigDSC_domain.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/windows-DSC/run_initialConfigDsc_domain.ps1) - GitHub
* [run_initialConfigDSC_domain.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/_blogPost/windows-DSC/run_initialConfigDsc_domain.ps1) - GitHub raw
* [InitialConfigDsc.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc.ps1) - GitHub
* [InitialConfigDsc.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc.ps1) - GitHub raw
* [ConfigData.psd1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigData.psd1)
* [ConfigureLCM.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigureLCM.ps1)
* [ConfigureNode.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigureNode.ps1)

### run_initialConfigDSC_workgroup-dev.ps1

Current code is a duplicate (anytime the source is updated, those changes should be reflected here in README.md) of:

```powershell
Set-InitialConfigDevDsc -NewComputerName $env:computername -Option Workgroup -Verbose

```

Refences used in the function above:

* [run_initialConfigDSC_workgroup-dev.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/windows-DSC/run_initialConfigDsc_workgroup-dev.ps1) - GitHub
* [run_initialConfigDSC_workgroup-dev.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/_blogPost/windows-DSC/run_initialConfigDsc_workgroup-dev.ps1) - GitHub raw
* [InitialConfigDsc-dev.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc-dev.ps1) - GitHub
* [InitialConfigDsc-dev.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc-dev.ps1) - GitHub raw
* [ConfigData-dev.psd1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigData.psd1)
* [ConfigureLCM.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigureLCM.ps1)
* [ConfigureNode.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigureNode.ps1)

### run_initialConfigDSC_workgroup.ps1

Current code is a duplicate (anytime the source is updated, those changes should be reflected here in README.md) of:

```powershell
Set-InitialConfigDsc -NewComputerName $env:computername -Option Workgroup -Verbose

```

Refences used in the function above:

* [run_initialConfigDSC_workgroup.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/windows-DSC/run_initialConfigDsc_workgroup.ps1) - GitHub
* [run_initialConfigDSC_workgroup.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/_blogPost/windows-DSC/run_initialConfigDsc_workgroup.ps1) - GitHub raw
* [InitialConfigDsc.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc.ps1) - GitHub
* [InitialConfigDsc.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_targetNode/InitialConfigDsc.ps1) - GitHub raw
* [ConfigData.psd1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigData.psd1)
* [ConfigureLCM.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigureLCM.ps1)
* [ConfigureNode.ps1](https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/000_initialConfig/ConfigureNode.ps1)

## ADDS role

### run_adds_initialConfig.ps1

Current code is a duplicate (anytime the source is updated, those changes should be reflected here in README.md) of:

```powershell
#cmd
#powershell
#Start-Process PowerShell -Verb RunAs
# run in elevated PowerShell session
Set-Location -Path "$env:USERPROFILE\Documents"

Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory/ADDS_CarlWebster_initialConfig.ps1' -OutFile "$env:USERPROFILE\Documents\ADDS_CarlWebster_initialConfig.ps1" -Verbose

#psedit "$env:USERPROFILE\Documents\ADDS_CarlWebster_initialConfig.ps1"

# it launches the process of SQL installation
.\ADDS_CarlWebster_initialConfig.ps1

```

* [run_adds_initialConfig.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/windows-role-active-directory/run_adds_initialConfig.ps1) - GitHub

### run_adds_initialConfig-dev.ps1

Current code is a duplicate (anytime the source is updated, those changes should be reflected here in README.md) of:

```powershell
#cmd
#powershell
#Start-Process PowerShell -Verb RunAs
# run in elevated PowerShell session
Set-Location -Path "$env:USERPROFILE\Documents"

Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory/ADDS-dev_CarlWebster_initialConfig.ps1' -OutFile "$env:USERPROFILE\Documents\ADDS-dev_CarlWebster_initialConfig.ps1" -Verbose

#psedit "$env:USERPROFILE\Documents\ADDS-dev_CarlWebster_initialConfig.ps1"

# it launches the process of SQL installation
.\ADDS-dev_CarlWebster_initialConfig.ps1

```

* [run_adds-dev_initialConfig.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/windows-role-active-directory/run_adds-dev_initialConfig.ps1) - GitHub

### run_adds_structure.ps1

Current code is a duplicate (anytime the source is updated, those changes should be reflected here in README.md) of:

```powershell
#cmd
#powershell
#Start-Process PowerShell -Verb RunAs
# run in elevated PowerShell session
Set-Location -Path "$env:USERPROFILE\Documents"

Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory/ADDS_structure.ps1' -OutFile "$env:USERPROFILE\Documents\ADDS_structure.ps1" -Verbose

#psedit "$env:USERPROFILE\Documents\ADDS_structure.ps1"

# it launches the process of the Active Directory structure creation
.\ADDS_structure.ps1
```

* [run_adds_structure.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/windows-role-active-directory/run_adds_structure.ps1) - GitHub

### run_adds-dev_structure.ps1

Current code is a duplicate (anytime the source is updated, those changes should be reflected here in README.md) of:

```powershell
#cmd
#powershell
#Start-Process PowerShell -Verb RunAs
# run in elevated PowerShell session
Set-Location -Path "$env:USERPROFILE\Documents"

Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/makeitcloudy/HomeLab/feature/007_DesiredStateConfiguration/005_ActiveDirectory/ADDS-dev_structure.ps1' -OutFile "$env:USERPROFILE\Documents\ADDS-dev_structure.ps1" -Verbose

#psedit "$env:USERPROFILE\Documents\ADDS-dev_structure.ps1"

# it launches the process of the Active Directory structure creation
.\ADDS-dev_structure.ps1
```

* [run_adds-dev_structure.ps1](https://github.com/makeitcloudy/HomeLab/blob/feature/007_DesiredStateConfiguration/_blogPost/windows-role-active-directory/run_adds-dev_structure.ps1) - GitHub