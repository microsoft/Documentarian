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
  <#
    .SYNOPSIS
  #>

  [CmdletBinding()]
  param(
    [Parameter()]
    [string]
    $Path,

    [Parameter()]
    [string]
    $SourcePath = $MyInvocation.MyCommand.Module.ModuleBase,

    [Parameter()]
    [switch]
    $Resolve
  )

  process {
    $sourceLocation = Get-Item -Path $SourcePath

    if ($sourceLocation -is [System.IO.FileInfo]) {
      $sourceLocation = $SourceLocation.Parent
    }

    try {
      Push-Location -Path $sourceLocation

      if (Resolve-Path -Path *.psd1 -Relative -ErrorAction SilentlyContinue) {
        $resolvedPath = Join-Path -Path $sourceLocation -ChildPath $Path
      } else {
        $sourceFolderPath = Resolve-SourceFolderPath -Path $sourceLocation
        $resolvedPath = Join-Path $sourceFolderPath -ChildPath $Path
      }

      if ($Resolve) {
        Resolve-Path -Path $resolvedPath
      } else {
        $resolvedPath
      }
    } finally {
      Pop-Location
    }
  }

  end {

  }
}
