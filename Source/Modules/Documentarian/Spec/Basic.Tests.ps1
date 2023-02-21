# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

BeforeAll {
  $ModuleName = 'Documentarian'
  $SourceModuleRoot = Split-Path -Parent $PSScriptRoot | Split-Path -Parent
  $Module = Get-Module -ListAvailable -Name $ModuleName -ErrorAction SilentlyContinue

  # If the module isn't available, update the PSModulePath and check again
  if ($null -eq $Module) {
    . $SourceModuleRoot/Tools/Update-PSModulePath
    Update-PSModulePath
    $Module = Get-Module -ListAvailable -Name $ModuleName -ErrorAction SilentlyContinue
  }

  # If it still isn't available, build it
  if ($null -eq $Module) {
    Push-Location -Path $SourceModuleRoot
    Invoke-Build -ErrorAction Stop
    Pop-Location
  }

  Import-Module Documentarian
}

Describe 'Inspecting a Markdown file' -Tag Acceptance {
  Context 'Without front matter' {
    BeforeAll {
      $Document = Get-Document -Path $PSScriptRoot/Fixtures/Simple.md
    }

    It 'Has the same RawContent and Body' {
      $Document.RawContent | Should -BeExactly $Document.Body
    }
  }
}
