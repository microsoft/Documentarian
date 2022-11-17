# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Public/Classes/SourceFile.psm1
using module ../../Public/Classes/SourceReference.psm1

function New-SourceReference {
  [CmdletBinding()]
  [OutputType([SourceReference])]
  param(
    [SourceFile]$SourceFile,
    [SourceFile[]]$Reference
  )

  process {
    if ($Reference) {
      [SourceReference]::new($SourceFile, $Reference)
    } else {
      [SourceReference]::new($SourceFile)
    }
  }
}
