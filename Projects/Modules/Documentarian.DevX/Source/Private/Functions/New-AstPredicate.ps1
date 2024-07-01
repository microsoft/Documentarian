# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/DevXAstTypeTransformAttribute.psm1

Function New-AstPredicate {
  <#
    .SYNOPSIS
    Function synopsis.
  #>

  [CmdletBinding()]
  [OutputType([ScriptBlock])]
  Param (
    [Parameter()]
    [DevXAstTypeTransformAttribute()]
    [System.Type[]]
    $Type
  )

  begin {

  }

  process {
    foreach ($item in $Type) {
      {
        param([System.Management.Automation.Language.Ast]$AstObject)
        return ($AstObject -is $item)
      }.GetNewClosure()
    }
  }

  end {

  }
}
