# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Synopsis: Load the DevX configuration file to use in other tasks
task InitializeDevXConfiguration {
  <#
    .SYNOPSIS
  #>

  $DevXConfigurationFile = Join-Path -Path $BuildRoot -ChildPath '.DevX.jsonc'

  if (Test-Path $DevXConfigurationFile) {
    $Script:DevX = Get-Content -Path $DevXConfigurationFile -Raw
    | ConvertFrom-Json -Depth 99
  }
}
