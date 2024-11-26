# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Public/Classes/SourceFile.psm1

function New-SourceFile {
  <#
    .SYNOPSIS
    Function synopsis.
  #>

  [CmdletBinding()]
  [OutputType([SourceFile])]
  param(
    [Parameter()]
    [string]
    $NameSpace,

    [Parameter()]
    [string]
    $Path
  )

  begin {

  }

  process {
    [SourceFile]::new($NameSpace, $Path)
  }

  end {

  }
}
