# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/General/Resolve-SourceFolderPath.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Get-ModuleRelativePath {
  [CmdletBinding()]
  param(
    [string]$Path,
    [string]$SourcePath = $MyInvocation.MyCommand.Module.ModuleBase,
    [switch]$Resolve
  )

  process {
    $SourceLocation = Get-Item -Path $SourcePath

    if ($SourceLocation -is [System.IO.FileInfo]) {
      $SourceLocation = $SourceLocation.Parent
    }

    try {
      Push-Location -Path $SourceLocation

      if (Resolve-Path -Path *.psd1 -Relative -ErrorAction SilentlyContinue) {
        $ResolvedPath = Join-Path -Path $SourceLocation -ChildPath $Path
      } else {
        $SourceFolderPath = Resolve-SourceFolderPath -Path $SourceLocation
        $ResolvedPath = Join-Path $SourceFolderPath -ChildPath $Path
      }

      if ($Resolve) {
        Resolve-Path -Path $ResolvedPath
      } else {
        $ResolvedPath
      }
    } finally {
      Pop-Location
    }
  }
}
