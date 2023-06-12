# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
#requires -Version 7.2
#requires -Module InvokeBuild

<#

.SYNOPSIS

  Build script for the Documentarian projects using `Invoke-Build`

.DESCRIPTION

  This build script is a shim to the individual project build scripts. It does not have substantial
  logic of its own.

#>

[cmdletbinding()]
param(
  [ValidateSet(
    'Documentarian',
    'Documentarian.DevX',
    'Documentarian.MarkdownBuilder',
    'Documentarian.MarkdownLint',
    'Documentarian.MicrosoftDocs',
    'Documentarian.MicrosoftDocs.PSDocs',
    'Documentarian.ModuleAuthor',
    'Documentarian.Vale'
  )]
  [string[]]$Module
)

if (!$Module) {
  $Module = @(
    'Documentarian.DevX'
    'Documentarian'
    'Documentarian.MarkdownBuilder'
    # Can't enable this until there's code to build
    # 'Documentarian.MarkdownLint'
    'Documentarian.MicrosoftDocs'
    'Documentarian.ModuleAuthor'
    'Documentarian.Vale'
  )
}

$LoadedDevXModule = Get-Module -Name Documentarian.DevX -ErrorAction SilentlyContinue
$NonDevXModules = $Module | Where-Object -FilterScript { $_ -ne 'Documentarian.DevX' }
$DevXModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Documentarian.DevX'
$BuildScripts = @{}

if ($NonDevXModules.Count -gt 0 -and !$LoadedDevXModule) {
  $DevXModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Documentarian.DevX'
  if (!(Import-Module -Name $DevXModulePath -ErrorAction SilentlyContinue)) {
    $null = Invoke-Build -File (Join-Path -Path $DevXModulePath -ChildPath '.build.ps1')
    Import-Module -Name $DevXModulePath -ErrorAction Stop
  }
}

foreach ($Item in $Module) {
  $BuildScripts.$Item = Join-Path -Path $PSScriptRoot -ChildPath $Item -AdditionalChildPath '.build.ps1'
}

task Compose {
  foreach ($Item in $Module) {
    Invoke-Build -File $BuildScripts.$Item
  }
}

task TestUnit Compose, {
  foreach ($Item in $Module) {
    Invoke-Build -File $BuildScripts.$Item -Task TestUnit
  }
}

task . Compose
