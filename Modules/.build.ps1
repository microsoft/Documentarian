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
    'Documentarian.Vale'
  )]
  [string[]]$Module
)

if (!$Module) {
  $Module = @(
    'Documentarian.DevX'
    'Documentarian'
    'Documentarian.Vale'
  )
}

$LoadedDevXModule = Get-Module -Name Documentarian.DevX -ErrorAction SilentlyContinue
$NonDevXModules = $Module | Where-Object -FilterScript { $_ -ne 'Documentarian.DevX' }

if ($NonDevXModules.Count -gt 0 -and !$LoadedDevXModule) {
  try {
    $DevXModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Documentarian.DevX'
    Import-Module -Name $DevXModulePath -ErrorAction Stop
  } catch {
    throw 'Could not import Documentarian.DevX module; Make sure it is composed first.'
  }
}

foreach ($Item in $Module) {
  $BuildScript = Join-Path -Path $PSScriptRoot -ChildPath $Item -AdditionalChildPath '.build.ps1'
  if ($Item -notmatch 'DevX') {
    if (!(Get-Module -Name Documentarian.DevX -ErrorAction SilentlyContinue)) {
      try {
        $DevXModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Documentarian.DevX'
        Import-Module -Name $DevXModulePath -ErrorAction Stop
      } catch {
        throw 'Could not import Documentarian.DevX module; Make sure it is composed first.'
      }
    }
  }
}

task Compose {
  foreach ($Item in $Module) {
    Invoke-Build -File $BuildScript
  }
}

task TestUnit Compose, {
  foreach ($Item in $Module) {
    Invoke-Build -File $BuildScript -Task TestUnit
  }
}

task . Compose
