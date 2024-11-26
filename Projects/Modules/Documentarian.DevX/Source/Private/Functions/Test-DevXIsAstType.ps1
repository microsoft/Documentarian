# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Function Test-DevXIsAstType {
  <#
    .SYNOPSIS
    Determines if a type is an AST type.
  #>

  [CmdletBinding()]
  [OutputType([bool])]
  Param(
    [Parameter()]
    [System.Type]
    $Type
  )

  begin {

  }

  process {
    $inNamespace = $Type.NameSpace -eq 'System.Management.Automation.Language'
    $endsInAst   = $Type.Name -match 'Ast$'

    return ($inNamespace -and $endsInAst)
  }

  end {

  }
}
