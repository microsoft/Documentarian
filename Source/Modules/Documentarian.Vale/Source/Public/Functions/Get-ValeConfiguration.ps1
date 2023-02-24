# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/Get-Vale.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Get-ValeConfiguration {
  [CmdletBinding()]
  param(
    [string]$Path
  )

  begin {
    $Vale = Get-Vale

    $ConfigParameters = @(
      'ls-config'
      '--output', 'JSON'
    )
  }
  process {
    if ($Path) {
      $ConfigParameters += '--config', $Path
    }
    $result = & $Vale @ConfigParameters 2>&1 | ConvertFrom-Json
    if ($null -eq $result.Code) {
      $result
    } else {
      throw 'Vale configuration not found.'
    }
  }
}
