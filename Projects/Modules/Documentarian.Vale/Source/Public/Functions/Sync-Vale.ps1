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

function Sync-Vale {
  [CmdletBinding()]
  param()

  begin {
    $SyncParameters = @(
      'sync'
    )
  }
  process {
    Invoke-Vale -ArgumentList $SyncParameters
  }
}
