# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/AstInfo.psm1
using module ../../Classes/AstTypeTransformAttribute.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/Ast/Get-Ast.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/Ast/New-AstPredicate.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

Function Find-Ast {
  [CmdletBinding(DefaultParameterSetName = 'FromtAstInfo')]
  [OutputType([System.Management.Automation.Language.Ast])]
  Param(
    [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithPredicate')]
    [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithType')]
    [AstInfo]$AstInfo,

    [Parameter(Mandatory, ParameterSetName = 'FromPathWithPredicate')]
    [Parameter(Mandatory, ParameterSetName = 'FromPathWithType')]
    [string]$Path,

    [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithPredicate')]
    [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithType')]
    [scriptblock]$ScriptBlock,

    [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithPredicate')]
    [Parameter(Mandatory, ParameterSetName = 'FromPathWithPredicate')]
    [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithPredicate')]
    [ScriptBlock[]]$Predicate,

    [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithType')]
    [Parameter(Mandatory, ParameterSetName = 'FromPathWithType')]
    [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithType')]
    [AstTypeTransformAttribute()]
    [System.Type[]]$Type,

    [switch]$Recurse
  )

  process {
    if (![string]::isNullOrEmpty($Path)) {
      $AstInfo = Get-Ast -Path $Path
    } elseif ($null -ne $ScriptBlock) {
      $AstInfo = Get-Ast -ScriptBlock $ScriptBlock
    }

    if ($null -ne $Type) {
      $Predicate = New-AstPredicate -Type $Type
    }

    $Predicate | ForEach-Object -Process {
      $AstInfo.Ast.FindAll($_, $Recurse)
    }
  }
}
