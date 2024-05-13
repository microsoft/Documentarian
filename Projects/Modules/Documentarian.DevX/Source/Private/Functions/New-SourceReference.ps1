# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Public/Classes/SourceFile.psm1
using module ../../Public/Classes/SourceReference.psm1

function New-SourceReference {
  <#
    .SYNOPSIS
    Function synopsis.
  #>

  [CmdletBinding()]
  [OutputType([SourceReference])]
  param(
    [Parameter()]
    [SourceFile]
    $SourceFile,

    [Parameter()]
    [SourceFile[]]
    $Reference
  )

  begin {

  }

  process {
    if ($Reference) {
      [SourceReference]::new($SourceFile, $Reference)
    } else {
      [SourceReference]::new($SourceFile)
    }
  }

  end {

  }
}
