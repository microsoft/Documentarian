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

$Script:SourceFolderPath = Join-Path -Path $PSScriptRoot -ChildPath 'Source'

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

# Compose the Documentarian.DevX.psm1 file from source.
task ComposeModule {
  Build-ComposedModule -ProjectRootFolderPath $PSScriptRoot
}

task CheckDependencies {
  Get-Module -ListAvailable
}

# Default task composes the module and writes the manifest
task . ComposeModule
