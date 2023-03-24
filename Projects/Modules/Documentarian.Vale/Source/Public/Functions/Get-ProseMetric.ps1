# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/ValeMetricsInfo.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/Invoke-Vale.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Get-ProseMetric {
  [CmdletBinding()]
  [OutputType([ValeMetricsInfo])]
  param(
    [SupportsWildcards()]
    [Parameter(Mandatory, Position = 0)]
    [string[]]$Path,

    [switch]$Recurse
  )

  begin {
    $MetricsParameters = @(
      'ls-metrics'
      '--output', 'JSON'
    )
  }

  process {
    Get-ChildItem -Path $Path -File -Recurse:$Recurse
    | ForEach-Object -Process {
      if ($_.Extension -ne '.md') {
        return
      }

      $Info = Invoke-Vale -ArgumentList ($MetricsParameters + $_.FullName)

      [ValeMetricsInfo]::new($Info, $_.FullName)
    }
  }
}
