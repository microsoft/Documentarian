# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
#requires -Version 7.2
#requires -Module InvokeBuild
using module ./Source/Private/Enums/UncommonLineEndingAction.psm1
using module ./Source/Public/Enums/SourceCategory.psm1
using module ./Source/Public/Enums/SourceScope.psm1
using module ./Source/Public/Classes/SourceFile.psm1
using module ./Source/Public/Classes/SourceFolder.psm1

<#
  .SYNOPSIS
  Build script for the Documentarian.DevX project using `Invoke-Build`
#>

[CmdletBinding()]
param(
  $Configuration = 'Test'
)

$Script:Manifest = @{
  RootModule           = 'Documentarian.DevX.psm1'
  ModuleVersion        = '0.0.1'
  CompatiblePSEditions = 'Core'
  GUID                 = '34628ac1-a222-4ae9-abb6-888ae5284410'
  Author               = 'PowerShell Docs Team'
  CompanyName          = 'Microsoft'
  Copyright            = '(c) Microsoft. All rights reserved.'
  PowerShellVersion    = '7.2'
  RequiredModules      = @(
    'PowerShell-Yaml'
  )
  ScriptsToProcess     = 'Init.ps1'
  VariablesToExport    = '*'
  Tags                 = @(
    'Development'
    'Maintenance'
  )
  ProjectUri           = 'https://github.com/PowerShell/Documentarian.DevX'
  LicenseUri           = 'https://github.com/PowerShell/Documentarian.DevX/blob/main/LICENSE'
}

$Script:SourceFolderPath = Join-Path -Path $PSScriptRoot -ChildPath 'Source'
$Script:PrivateFolderPath = Join-Path -Path $Script:SourceFolderPath -ChildPath 'Private'
$Script:PublicFolderPath = Join-Path -Path $Script:SourceFolderPath -ChildPath 'Public'

$FunctionFinderParams = @{
  Path    = $Script:SourceFolderPath
  Recurse = $true
  Include = '*.ps1'
  Exclude = '*.Tests.ps1'
}
$Functions = Get-ChildItem @FunctionFinderParams
| Where-Object -FilterScript {
  $_.FullName -notmatch [regex]::Escape((Join-Path -Path 'Source' -ChildPath 'Templates'))
}

foreach ($Function in $Functions) {
  Write-Verbose $Function.FullName
  . $Function.FullName
}

$Script:ModuleFolderPath = Join-Path -Path $PSScriptRoot -ChildPath $Script:Manifest.ModuleVersion
$Script:RootModule = Join-Path -Path $Script:ModuleFolderPath -ChildPath 'Documentarian.DevX.psm1'
$Script:ManifestPath = Join-Path -Path $Script:ModuleFolderPath -ChildPath 'Documentarian.DevX.psd1'

$Script:PublicFunctions = [string[]]@()
$Script:SourceFolders = [SourceFolder[]]@()

$Script:InitScriptContent = @"
<#
  .SYNOPSIS
    Initializes state for the module on load.
  .DESCRIPTION
    This script file initializes state for the Documentarian module to
    make it easier to work with the classes, configuration, and enums.

    It runs in the caller's session state when the module is loaded to
    obviate the need to remember to call the ``using`` statement on the
    module and ensures the public classes and enums are available.
#>

using module ./$(${Script:Manifest}.RootModule)
"@

task Clean {
  if (Test-Path -Path $Script:ModuleFolderPath) {
    Remove-Item -Path $Script:ModuleFolderPath -Recurse -Force
  }

  $null = New-Item -Path $Script:ModuleFolderPath -ItemType Directory -Force
}

task GetSourceFolders {
  $SourceFinderParameters = @{
    Preset        = 'All'
    PublicFolder  = $Script:PublicFolderPath
    PrivateFolder = $Script:PrivateFolderPath
  }
  $Script:SourceFolders = Get-SourceFolder @SourceFinderParameters

  [string[]]$Script:PublicFunctions = $Script:SourceFolders
  | Where-Object { $_.Scope -eq 'Public' -and $_.Category -eq 'Function' }
  | ForEach-Object { Split-Path -Path $_.SourceFiles.FileInfo.FullName -LeafBase }
}

# Compose the Documentarian.DevX.psm1 file from source.
task ComposeModule Clean, GetSourceFolders, {
  $PrivateModuleFolders = $Script:SourceFolders
  | Where-Object -FilterScript {
    ($_.Category -ne 'Function') -and
    ($_.Scope -eq 'Private') -and
    ($_.SourceFiles.Count -gt 0)
  }

  $PublicModuleFolders = $Script:SourceFolders
  | Where-Object -FilterScript {
    ($_.DirectoryInfo.FullName -notin $PrivateModuleFolders.DirectoryInfo.FullName) -and
    ($_.SourceFiles.Count -gt 0)
  }

  if ($PrivateModuleFolders) {
    $PrivateModulePath = $Script:RootModule -replace 'psm1$', 'Private.psm1'
    $UsingPrivateModuleStatement = "using module ./$(Split-Path -Leaf -Path $PrivateModulePath)"

    Set-Content -Path $Script:RootModule -Value $UsingPrivateModuleStatement

    $PrivateModuleFolders.SourceFiles.GetNonLocalUsingStatements()
    | Select-Object -Unique
    | Join-String -Separator ([System.Environment]::NewLine)
    | Set-Content -Path $PrivateModulePath

    $PrivateModuleFolders
    | ForEach-Object { $_.ComposeSourceFiles().trim() }
    | Join-String -Separator ([System.Environment]::NewLine * 2)
    | Add-Content -Path $PrivateModulePath
  }

  $PublicModuleFolders.SourceFiles.GetNonLocalUsingStatements()
  | Select-Object -Unique
  | Join-String -Separator ([System.Environment]::NewLine)
  | Add-Content -Path $Script:RootModule

  $PublicModuleFolders
  | ForEach-Object { $_.ComposeSourceFiles().trim() }
  | Join-String -Separator ([System.Environment]::NewLine * 2)
  | Add-Content -Path $Script:RootModule

  $ExportStatement = @(
    '$ExportableFunctions = @('
    $Script:PublicFunctions | ForEach-Object { "  '$_'" }
    ')'
    'Export-ModuleMember -Alias * -Function $ExportableFunctions'
  ) -join [System.Environment]::NewLine
  Add-Content -Path $Script:RootModule -Value ([System.Environment]::NewLine + $ExportStatement)
}

task WriteManifest Clean, {
  $Manifest = $Script:Manifest
  $Manifest.Path = $Script:ManifestPath
  $Manifest.FunctionsToExport = $Script:PublicFunctions
  New-ModuleManifest @Manifest
}

task WriteInitScript {
  $InitScriptPath = Join-Path -Path (Split-Path -Path $Script:ManifestPath) -ChildPath 'Init.ps1'
  Set-Content -Path $InitScriptPath -Value $Script:InitScriptContent
}

task CheckDependencies {
  Get-Module -ListAvailable
}

# Default task composes the module and writes the manifest
task . ComposeModule, WriteManifest, WriteInitScript
