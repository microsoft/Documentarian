# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Get-EnumRegex {
  <#
    .SYNOPSIS
    Function synopsis.
  #>

  [CmdletBinding()]
  [OutputType([String])]
  param(
    [Parameter(Mandatory)]
    [ValidateScript({ $_.IsEnum })]
    [Type]
    $EnumType
  )

  begin {

  }

  process {
    "(?<$($EnumType.Name)>($($EnumType.GetEnumNames() -join '|')))"
  }

  end {

  }
}
