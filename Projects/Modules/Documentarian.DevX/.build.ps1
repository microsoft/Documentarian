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
$TemplateFolder = Join-Path -Path 'Source' -ChildPath 'Templates'
$TasksFolder = Join-Path -Path 'Source' -ChildPath 'Public' -AdditionalChildPath 'Tasks'

$Functions = Get-ChildItem @FunctionFinderParams
| Where-Object -FilterScript {
  $_.FullName -notmatch [regex]::Escape($TemplateFolder) -and
  $_.FullName -notmatch [regex]::Escape($TasksFolder)
}

foreach ($Function in $Functions) {
  Write-Verbose "Loading function: $($Function.FullName)"
  . $Function.FullName
}

foreach ($TaskFile in (Get-ChildItem -Path $TasksFolder -Filter '*.ps1')) {
  Write-Verbose "Loading task: $($TaskFile.BaseName)"
  . $TaskFile
}

# Synopsis: Default task composes the module and writes the manifest
task . ComposeModule
