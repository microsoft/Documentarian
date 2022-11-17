# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Public/Classes/SourceFolder.psm1

function New-SourceFolder {
  [CmdletBinding()]
  [OutputType([SourceFolder])]
  param(
    [string]$NameSpace,

    [Parameter(Mandatory)]
    [string]$Path
  )

  process {
    if ($NameSpace) {
      [SourceFolder]::new($NameSpace, $Path)
    } else {
      [SourceFolder]::new($Path)
    }
  }
}
