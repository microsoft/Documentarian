# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Public/Classes/SourceFolder.psm1

function New-SourceFolder {
  <#
    .SYNOPSIS
    Function synopsis.
  #>

  [CmdletBinding()]
  [OutputType([SourceFolder])]
  param(
    [Parameter()]
    [string]
    $NameSpace,

    [Parameter(Mandatory)]
    [string]
    $Path
  )

  begin {

  }

  process {
    if ($NameSpace) {
      [SourceFolder]::new($NameSpace, $Path)
    } else {
      [SourceFolder]::new($Path)
    }
  }

  end {

  }
}
