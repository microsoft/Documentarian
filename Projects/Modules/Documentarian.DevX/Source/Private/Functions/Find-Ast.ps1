# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/DevXAstInfo.psm1
using module ../Classes/DevXAstTypeTransformAttribute.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Private/Functions/Get-Ast.ps1"
  Resolve-Path -Path "$SourceFolder/Private/Functions/New-AstPredicate.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

Function Find-Ast {
  <#
    .SYNOPSIS
    Search an AST for nodes that match a predicate.

    .DESCRIPTION
    This function searches an AST for nodes that match a predicate. The predicate can be a script
    block or a type. If a type is specified, the predicate is created from the type, returning any
    matching AST objects. You can specify the AST to search by providing an `AstInfo` object, a
    file path, or a script block.

    The function can search a single AST node or recurse through all child nodes. The function
    returns all matching nodes.

    .PARAMETER DevXAstInfo
    The `AstInfo` object to search. This parameter is mandatory if the **Path** or **ScriptBlock**
    parameters are not specified.

    .PARAMETER Path
    The file path to the script file containing the AST to search. This parameter is mandatory if
    the **DevXAstInfo** or **ScriptBlock** parameters are not specified.

    .PARAMETER ScriptBlock
    The script block containing the AST to search. This parameter is mandatory if the
    **DevXAstInfo** or **Path** parameters are not specified.

    .PARAMETER Predicate
    The predicates to use when searching the AST. This parameter is mandatory if the **Type**
    parameter is not specified. Each predicate must be a script block that returns `$true` if the
    AST node should be returned and otherwise `$false`.

    .PARAMETER Type
    The AST types to search for. This parameter is mandatory if the **Predicate** parameter is not
    specified. Each type must be a type object or a string representing the type name. The type
    must be in the `System.Management.Automation.Language` namespace and must end in `Ast`.

    .PARAMETER Recurse
    Indicates that the function should search all child nodes of the AST. By default, the function
    only searches the top-level nodes.

    .OUTPUTS System.Management.Automation.Language.Ast
    The function returns every AST node that matches the predicates or is in the type list.
  #>

  [CmdletBinding(DefaultParameterSetName = 'FromtAstInfo')]
  [OutputType([System.Management.Automation.Language.Ast])]
  Param(
    [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithPredicate')]
    [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithType')]
    [DevXAstInfo]
    $DevXAstInfo,

    [Parameter(Mandatory, ParameterSetName = 'FromPathWithPredicate')]
    [Parameter(Mandatory, ParameterSetName = 'FromPathWithType')]
    [string]
    $Path,

    [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithPredicate')]
    [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithType')]
    [scriptblock]
    $ScriptBlock,

    [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithPredicate')]
    [Parameter(Mandatory, ParameterSetName = 'FromPathWithPredicate')]
    [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithPredicate')]
    [ScriptBlock[]]
    $Predicate,

    [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithType')]
    [Parameter(Mandatory, ParameterSetName = 'FromPathWithType')]
    [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithType')]
    [DevXAstTypeTransformAttribute()]
    [System.Type[]]
    $Type,

    [Parameter()]
    [switch]
    $Recurse
  )

  begin {

  }

  process {
    if (-not [string]::IsNullOrEmpty($Path)) {
      $DevXAstInfo = Get-Ast -Path $Path
    } elseif ($null -ne $ScriptBlock) {
      $DevXAstInfo = Get-Ast -ScriptBlock $ScriptBlock
    }

    if ($null -ne $Type) {
      $Predicate = New-AstPredicate -Type $Type
    }

    $Predicate | ForEach-Object -Process {
      $DevXAstInfo.Ast.FindAll($_, $Recurse)
    }
  }

  end {

  }
}
