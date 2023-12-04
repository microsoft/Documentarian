# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/AstInfo.psm1
using module ../../Classes/AstTypeTransformAttribute.psm1
using module ../../Classes/ValidatePowerShellScriptPathAttribute.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsRegistry.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
    $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
    Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Get-AstInfo.ps1"
    Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/New-AstPredicate.ps1"
    Resolve-Path -Path "$SourceFolder/Public/Functions/DecoratingComments/New-DecoratingCommentsRegistry.ps1"
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

    [CmdletBinding(DefaultParameterSetName = 'FromAstInfoWithType')]
    [OutputType([Ast[]], ParameterSetName=(
            'FromAstInfoWithPredicate',
            'FromPathWithPredicate',
            'FromScriptBlockWithPredicate',
            'FromTargetAstWithPredicate',
            'FromAstInfoWithType',
            'FromPathWithType',
            'FromScriptBlockWithType',
            'FromTargetAstWithType'
        ))]
    [OutputType([AstInfo[]], ParameterSetName=(
            'FromAstInfoWithPredicateAsAstInfo',
            'FromPathWithPredicateAsAstInfo',
            'FromScriptBlockWithPredicateAsAstInfo',
            'FromTargetAstWithPredicateAsAstInfo',
            'FromAstInfoWithTypeAsAstInfo',
            'FromPathWithTypeAsAstInfo',
            'FromScriptBlockWithTypeAsAstInfo',
            'FromTargetAstWithTypeAsAstInfo'
        ))]
    Param(
        [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithPredicate')]
        [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithPredicateAsAstInfo')]
        [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithType')]
        [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithTypeAsAstInfo')]
        [AstInfo]$AstInfo,

        [Parameter(Mandatory, ParameterSetName = 'FromPathWithPredicate')]
        [Parameter(Mandatory, ParameterSetName = 'FromPathWithPredicateAsAstInfo')]
        [Parameter(Mandatory, ParameterSetName = 'FromPathWithType')]
        [Parameter(Mandatory, ParameterSetName = 'FromPathWithTypeAsAstInfo')]
        [ValidatePowerShellScriptPathAttribute()]
        [string]$Path,

        [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithPredicate')]
        [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithPredicateAsAstInfo')]
        [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithType')]
        [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithTypeAsAstInfo')]
        [scriptblock]$ScriptBlock,

        [Parameter(Mandatory, ParameterSetName = 'FromTargetAstWithPredicate')]
        [Parameter(Mandatory, ParameterSetName = 'FromTargetAstWithPredicateAsAstInfo')]
        [Parameter(Mandatory, ParameterSetName = 'FromTargetAstWithType')]
        [Parameter(Mandatory, ParameterSetName = 'FromTargetAstWithTypeAsAstInfo')]
        [Ast]$TargetAst,

        [Parameter(ParameterSetName = 'FromTargetAstWithPredicate')]
        [Parameter(Mandatory, ParameterSetName = 'FromTargetAstWithPredicateAsAstInfo')]
        [Parameter(ParameterSetName = 'FromTargetAstWithType')]
        [Parameter(Mandatory, ParameterSetName = 'FromTargetAstWithTypeAsAstInfo')]
        [Token[]]$Token,

        [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithPredicate')]
        [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithPredicateAsAstInfo')]
        [Parameter(Mandatory, ParameterSetName = 'FromPathWithPredicate')]
        [Parameter(Mandatory, ParameterSetName = 'FromPathWithPredicateAsAstInfo')]
        [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithPredicate')]
        [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithPredicateAsAstInfo')]
        [Parameter(Mandatory, ParameterSetName = 'FromTargetAstWithPredicate')]
        [Parameter(Mandatory, ParameterSetName = 'FromTargetAstWithPredicateAsAstInfo')]
        [ScriptBlock]$Predicate,

        [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithType')]
        [Parameter(Mandatory, ParameterSetName = 'FromAstInfoWithTypeAsAstInfo')]
        [Parameter(Mandatory, ParameterSetName = 'FromPathWithType')]
        [Parameter(Mandatory, ParameterSetName = 'FromPathWithTypeAsAstInfo')]
        [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithType')]
        [Parameter(Mandatory, ParameterSetName = 'FromScriptBlockWithTypeAsAstInfo')]
        [Parameter(Mandatory, ParameterSetName = 'FromTargetAstWithType')]
        [Parameter(Mandatory, ParameterSetName = 'FromTargetAstWithTypeAsAstInfo')]
        [AstTypeTransformAttribute()]
        [System.Type]$Type,

        [Parameter(ParameterSetName = 'FromAstInfoWithPredicateAsAstInfo')]
        [Parameter(ParameterSetName = 'FromPathWithPredicateAsAstInfo')]
        [Parameter(ParameterSetName = 'FromScriptBlockWithPredicateAsAstInfo')]
        [Parameter(ParameterSetName = 'FromTargetAstWithPredicateAsAstInfo')]
        [Parameter(ParameterSetName = 'FromAstInfoWithTypeAsAstInfo')]
        [Parameter(ParameterSetName = 'FromPathWithTypeAsAstInfo')]
        [Parameter(ParameterSetName = 'FromScriptBlockWithTypeAsAstInfo')]
        [Parameter(ParameterSetName = 'FromTargetAstWithTypeAsAstInfo')]
        [DecoratingCommentsRegistry]$Registry = $Global:ModuleAuthorDecoratingCommentsRegistry,

        [switch]$Recurse,

        [Parameter(ParameterSetName = 'FromAstInfoWithPredicateAsAstInfo')]
        [Parameter(ParameterSetName = 'FromPathWithPredicateAsAstInfo')]
        [Parameter(ParameterSetName = 'FromScriptBlockWithPredicateAsAstInfo')]
        [Parameter(ParameterSetName = 'FromTargetAstWithPredicateAsAstInfo')]
        [Parameter(ParameterSetName = 'FromAstInfoWithTypeAsAstInfo')]
        [Parameter(ParameterSetName = 'FromPathWithTypeAsAstInfo')]
        [Parameter(ParameterSetName = 'FromScriptBlockWithTypeAsAstInfo')]
        [Parameter(ParameterSetName = 'FromTargetAstWithTypeAsAstInfo')]
        [switch]$AsAstInfo,

        [Parameter(ParameterSetName = 'FromAstInfoWithPredicateAsAstInfo')]
        [Parameter(ParameterSetName = 'FromPathWithPredicateAsAstInfo')]
        [Parameter(ParameterSetName = 'FromScriptBlockWithPredicateAsAstInfo')]
        [Parameter(ParameterSetName = 'FromTargetAstWithPredicateAsAstInfo')]
        [Parameter(ParameterSetName = 'FromAstInfoWithTypeAsAstInfo')]
        [Parameter(ParameterSetName = 'FromPathWithTypeAsAstInfo')]
        [Parameter(ParameterSetName = 'FromScriptBlockWithTypeAsAstInfo')]
        [Parameter(ParameterSetName = 'FromTargetAstWithTypeAsAstInfo')]
        [switch]$ParseDecoratingComment
    )

    begin {}

    process {
        if ($ParseDecoratingComment) {
            if ($null -eq $Registry) {
                $Message = @(
                    'Specified -ParseDecoratingComment without passing a value for the Registry'
                    'parameter and without the global registry initialized. Creating a default'
                    'DecoratingCommentsRegistry to use for this command.'
                ) -join ' '
                Write-Verbose $Message
                $Registry = New-DecoratingCommentsRegistry
            }
        }

        if ($null -ne $Type) {
            $Predicate = New-AstPredicate -Type $Type
        }

        if ($null -eq $AstInfo) {
            $GetParameters = @{
                ParseDecoratingComment = $ParseDecoratingComment
            }
            if (![string]::isNullOrEmpty($Path)) {
                $GetParameters.Path = $Path
            }
            if ($null -ne $ScriptBlock) {
                $GetParameters.ScriptBlock = $ScriptBlock
            }
            if ($null -ne $TargetAst) {
                $GetParameters.TargetAst = $TargetAst
                if ($Token.Count -gt 0) {
                    $GetParameters.Token = $Token
                }
            }
            if ($null -ne $Registry) {
                $GetParameters.Registry = $Registry
            }
            $AstInfo = Get-AstInfo @GetParameters
        }

        $Results = $AstInfo.Ast.FindAll($Predicate, $Recurse)

        if ($AsAstInfo) {
            $Results | ForEach-Object -Process {
                $GetResultParameters = @{
                    ParseDecoratingComment = $ParseDecoratingComment
                    TargetAst              = $_
                    Token                  = $AstInfo.Tokens
                }
                if ($null -ne $Registry) {
                    $GetResultParameters.Registry = $Registry
                }
                Get-AstInfo @GetResultParameters
            }
        } else {
            $Results
        }
    }

    end {}
}
