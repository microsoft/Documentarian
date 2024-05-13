# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/SourceFile.psm1

function Resolve-SourceFolderPath {
  <#
    .SYNOPSIS
  #>

  [CmdletBinding()]
  [OutputType([String])]
  param(
    [Parameter()]
    [SourceFile[]]
    $SourceFile,

    [Parameter()]
    [string[]]
    $Path
  )

  begin {

  }

  process {
    if ($SourceFile) {
      $Path = $SourceFile.FileInfo.FullName
    }

    foreach ($Path in $Path) {
      $Path = Resolve-Path $Path -ErrorAction Stop

      $SourceFolderPath = $Path
      while ((Split-Path -Leaf -Path $SourceFolderPath) -ne 'Source') {
        $SourceFolderPath = Split-Path -Parent -Path $SourceFolderPath
      }

      $SourceFolderPath
    }
  }

  end {

  }
}
