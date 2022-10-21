# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/SourceFile.psm1

function Resolve-SourceFolderPath {
  [CmdletBinding()]
  [OutputType([String])]
  param(
    [SourceFile[]]$SourceFile,
    [string[]]$Path
  )

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
}
