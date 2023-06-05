# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/AstInfo.psm1
using module ../Classes/AstTypeTransformAttribute.psm1
using module ../Classes/ValidatePowerShellScriptPathAttribute.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/Get-AstInfo.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/New-AstPredicate.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

Function Find-Ast {
    <#
        .SYNOPSIS
        Finds ASTs by type or predicate in a script block, file, or AST.
    #>

    [CmdletBinding(DefaultParameterSetName = 'FromtAstInfo')]
    [OutputType([Ast[]])]
    Param(
        [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithPredicate')]
        [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithType')]
        [AstInfo]$AstInfo,

        [Parameter(Mandatory, ParameterSetName = 'FromPathWithPredicate')]
        [Parameter(Mandatory, ParameterSetName = 'FromPathWithType')]
        [ValidatePowerShellScriptPathAttribute()]
        [string]$Path,

        [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithPredicate')]
        [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithType')]
        [scriptblock]$ScriptBlock,

        [Parameter(Mandatory, ParameterSetName = 'FromTargetAstWithPredicate')]
        [Parameter(Mandatory, ParameterSetName = 'FromTargetAstWithType')]
        [Ast]$TargetAst,

        [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithPredicate')]
        [Parameter(Mandatory, ParameterSetName = 'FromPathWithPredicate')]
        [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithPredicate')]
        [Parameter(Mandatory, ParameterSetName = 'FromTargetAstWithPredicate')]
        [ScriptBlock]$Predicate,

        [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithType')]
        [Parameter(Mandatory, ParameterSetName = 'FromPathWithType')]
        [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithType')]
        [Parameter(Mandatory, ParameterSetName = 'FromTargetAstWithType')]
        [AstTypeTransformAttribute()]
        [System.Type]$Type,

        [switch]$Recurse
    )

    begin {}

    process {
        if ($null -ne $Type) {
            $Predicate = New-AstPredicate -Type $Type
        }

        if (![string]::isNullOrEmpty($Path)) {
            $TargetAst = Get-AstInfo -Path $Path | Select-Object -ExpandProperty Ast
        } elseif ($null -ne $ScriptBlock) {
            $TargetAst = Get-AstInfo -ScriptBlock $ScriptBlock | Select-Object -ExpandProperty Ast
        } elseif ($null -ne $AstInfo) {
            $TargetAst = $AstInfo.Ast
        }

        $TargetAst.FindAll($Predicate, $Recurse)
    }

    end {}
}
