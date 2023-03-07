# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/ValeViolation.psm1

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
  [OutputType([ValeViolation])]
  param(
    [string[]]$Path,
    [string]$ConfigurationPath,
    [ValeAlertLevel]$MinimumAlertLevel
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
      foreach ($FilePath in $Result.Keys) {
        $FileInfo = Get-Item -Path $FilePath
        $Result.$FilePath | ForEach-Object {
          [ValeViolation]::new($_, $FileInfo)
        }
      }
    }
  }
}
