# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

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

function Test-Prose {
  [CmdletBinding()]
  param(
    [string[]]$Path,
    [string]$ConfigurationPath
  )

  begin {
    $TestParameters = @(
      '--output', 'JSON'
    )

    if ($ConfigurationPath) {
      $TestParameters += '--config', $ConfigurationPath
    }
  }

  process {
    foreach ($TestPath in $Path) {
      $Result = Invoke-Vale -ArgumentList @($TestParameters + $TestPath)
      $Properties = $Result | Get-Member -MemberType Properties
      | Select-Object -ExpandProperty Name
      foreach ($Property in $Properties) {
        $Result.$Property | ForEach-Object -Process {
          [PSCustomObject]@{
            Action      = [pscustomobject]@{
              Name   = $_.Action.Name
              Params = $_.Action.Params
            }
            Span        = $_.Span
            Check       = $_.Check
            Description = $_.Description
            Link        = $_.Link
            Message     = $_.Message
            Severity    = $_.Severity
            Match       = $_.Match
            Line        = $_.Line
            FileInfo    = Get-Item $Property
          }
        }
      }
    }
  }
}
