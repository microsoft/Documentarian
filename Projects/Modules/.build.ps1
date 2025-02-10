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
    'Documentarian.HelpInfo',
    'Documentarian.MicrosoftDocs',
    'Documentarian.MicrosoftDocs.PSDocs',
    'Documentarian.ModuleAuthor',
    'Documentarian.Vale'
  )]
  [string[]]$Module,
  [string]$RepoName = 'Documentarian.Local',
  [string]$RepoPath = (Join-Path -Path $PSScriptRoot -ChildPath '.repository'),
  [switch]$Clean
)

$Script:DevXModules = @(
  'Documentarian',
  'Documentarian.DevX',
  'Documentarian.HelpInfo',
  'Documentarian.MarkdownBuilder',
  'Documentarian.MarkdownLint',
  'Documentarian.MicrosoftDocs',
  'Documentarian.MicrosoftDocs.PSDocs',
  'Documentarian.ModuleAuthor',
  'Documentarian.Vale'
)

if (!$Module) {
  $Module = @(
    'Documentarian.DevX'
    'Documentarian'
    'Documentarian.HelpInfo'
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

task Package {
  # Load the helper functions
  $RepoFunctionsDefinition = Join-Path $PSScriptRoot -ChildPath 'Tools/LocalRepoFunctions.ps1'
  . $RepoFunctionsDefinition

  # Make the other modules available to Get-Module to auto-register dependencies.
  $UpdatePSPathDefinition = Join-Path $PSScriptRoot -ChildPath 'Tools/Update-PSModulePath.ps1'
  . $UpdatePSPathDefinition
  $InitialPSModulePath = $env:PSModulePath
  Update-PSModulePath

  $null = Register-LocalRepository -RepoName $RepoName -RepoPath $RepoPath -Clean:$Clean
  foreach ($Item in $Module) {
    # Get the latest version of the composed module - might have others on system, so use path.
    # Need to silence messaging for the noisy Get-Module call, and reset after.
    $Preferences = $VerbosePreference, $DebugPreference
    $VerbosePreference = $DebugPreference = 'SilentlyContinue'
    $ComposedModuleInfo = Get-Module "$PSScriptRoot/$Item" -ListAvailable  |
      Sort-Object -Property Version -Descending |
      Select-Object -First 1
    $VerbosePreference, $DebugPreference = $Preferences

    # If the module isn't composed, error and continue to next module.
    if ($null -eq $ComposedModuleInfo) {
      Write-Error "Unable to find composed module for '$Item' in '$PSScriptRoot'."
      continue
    }

    # Publish the composed module.
    Publish-LocalModule -Module $ComposedModuleInfo -RepoName $RepoName -Force
  }

  Unregister-LocalRepository -RepoName $RepoName
  $env:PSModulePath = $InitialPSModulePath
}

task Format {
  $InitialVerbosePreference = $VerbosePreference
  $VerbosePreference = 'SilentlyContinue'
  $DefaultSettings = "$PSScriptRoot/.CodeFormatting.psd1"
  foreach ($Item in $Module) {
    $ModuleFolder   = Join-Path -Path $PSScriptRoot -ChildPath $Item
    $SourceFolder   = Join-Path -Path $ModuleFolder -ChildPath 'Source'
    $ModuleSettings = Join-Path -Path $ModuleFolder -ChildPath '.CodeFormatting.psd1'
    $Settings       = (Test-Path $ModuleSettings) ? $ModuleSettings : $DefaultSettings
    $SourceFiles    = Get-ChildItem -Path $SourceFolder -Recurse | Where-Object -FilterScript {
      $_.Extension -in @('.ps1', '.psm1', '.psd1')
    }

    foreach ($SourceFile in $SourceFiles) {
      $RelativePath = $SourceFile.FullName.Replace($SourceFolder, '').TrimStart('\', '/')
      $VerbosePreference = $InitialVerbosePreference
      Write-Verbose -Message "Checking formatting  : $RelativePath"
      $VerbosePreference = 'SilentlyContinue'
      $Content = Get-Content -Path $SourceFile.FullName -Raw
      $FormattedContent = Invoke-Formatter -ScriptDefinition $Content -Settings $Settings
      $FormattedContent = $FormattedContent -replace '(?m)(\r?\n){2,}$', '$1$1'
      if ($Content -ne $FormattedContent) {
        $VerbosePreference = $InitialVerbosePreference
        Write-Verbose -Message "Enforcing formatting : $RelativePath"
        $VerbosePreference = 'SilentlyContinue'
        Set-Content -Path $SourceFile.FullName -Value $FormattedContent
      }
    }
  }
}

task . Compose
