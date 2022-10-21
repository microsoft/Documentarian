# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/AstTypeTransformAttribute.psm1

Function New-AstPredicate {
  [CmdletBinding()]
  [OutputType([ScriptBlock])]
  Param (
    [AstTypeTransformAttribute()]
    [System.Type[]]$Type
  )

  foreach ($Item in $Type) {
    {
      param([System.Management.Automation.Language.Ast]$AstObject)
      return ($AstObject -is $Item)
    }.GetNewClosure()
  }
}
