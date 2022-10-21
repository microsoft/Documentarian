# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
#requires -Version 7.2

<#
.SYNOPSIS
  Sync project dependencies.
.DESCRIPTION
  The script syncs the project's dependencies. By default, it verifies that the minimum dependencies
  are available for the project and, if they are not met, installs in them.

  It can also be used to test the availability of the project dependencies, enumerate available and
  valid updates for the dependencies, and update your system to the latest valid version of any
  dependencies.
.LINK
  Specify a URI to a help page, this will show when Get-Help -Online is used.
.EXAMPLE
  ./.sync.ps1

  Executes the script for first-time dependency validation and installation. If any dependencies are
  missing, the script prompts to address the missing dependencies by installing them.
#>

[cmdletbinding()]
param(

)

begin {
  $OriginalVerbosePreference = $VerbosePreference
  $VerbosePreference = 'SilentlyContinue'
  if (!(Get-Module -Name PowerShellGet)) {
    Import-Module -Name PowerShellGet
  }
  . $PSScriptRoot/Tools/Test-Dependency.ps1
  $VerbosePreference = $OriginalVerbosePreference

  $Executables = @(
    @{
      Name = 'git'
    }
    @{
      Name = 'vale'
    }
    @{
      Name        = 'code'
      DisplayName = 'VS Code'
    }
  )

  $Modules = @(
    @{ Name = 'powershell-yaml' }

    @{
      Name           = 'InvokeBuild'
      MinimumVersion = [version]'5.0'
      MaximumVersion = [version]'5.99'
    }

    @{
      Name               = 'Pester'
      MinimumVersion     = [version]'5.0'
      MaximumVersion     = [version]'5.99'
      Force              = $true
      SkipPublisherCheck = $true
    }
  )
}

process {
  foreach ($Module in $Modules) {
    if (!(Test-Dependency -Module $Module -Detailed)) {
      Install-Module @Module
    }
  }
  foreach ($Executable in $Executables) {
    if (!(Test-Dependency -Executable $Executable -Detailed)) {
      $Name = $Executable.DisplayName ? $Executable.DisplayName : $Executable.Name
      Write-Warning "Install not implemented yet. Install $Name manually."
    }
  }
}
