# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using module ../../Classes/AstInfo.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsRegistry.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Find-Ast.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Get-AstInfo.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/DecoratingComments/New-DecoratingCommentsRegistry.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/HelpInfo/Resolve-ClassHelpInfo.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/HelpInfo/Resolve-EnumHelpInfo.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Resolve-HelpInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ByPath')]
        [ValidatePowerShellScriptPath()]
        [string[]]$Path,

        [Parameter(Mandatory, ParameterSetName = 'ByAstInfo')]
        [AstInfo[]]$AstInfo,

        [DecoratingCommentsRegistry]$Registry = [DecoratingCommentsRegistry]::Get()
    )

    begin {
        if ($null -eq $Registry) {
            Write-Verbose 'Using default DecoratingCommentsRegistry to parse the AST for help.'
            $Registry = New-DecoratingCommentsRegistry
        }

        $FindDefinitionPredicate = {
            [CmdletBinding()]
            [OutputType([bool])]

            param(
                [Ast]$AstObject
            )

            $IsTypeDefinition = $AstObject -is [TypeDefinitionAst]
            $IsFuncDefinition = $AstObject -is [FunctionDefinitionAst]

            return ($IsTypeDefinition -or $IsFuncDefinition)
        }
    }

    process {
        if ($Path) {
            foreach ($P in $Path) {
                $GetParameters = @{
                    Path                   = $P
                    Registry               = $Registry
                    ParseDecoratingComment = $true
                    ErrorAction            = 'Stop'
                }
                $FileAstInfo = Get-AstInfo @GetParameters
                # Validate the AST isn't in bad shape
                if ($FileAstInfo.Ast.Extent.GetType().Name -eq 'EmptyScriptExtent') {
                    throw "Ast empty; does '$P' exist and have script content in it?"
                }
                $AstInfo += $FileAstInfo
            }
        }

        # Validate the AST isn't in bad shape
        if ($AstInfo.Ast.Extent.GetType().Name -eq 'EmptyScriptExtent') {
            throw "Ast empty; does '$Path' exist and have script content in it?"
        }

        $SharedParameters = @{
            AstInfo = $AstInfo
            AsAstInfo              = $true
            Registry               = $Registry
            ParseDecoratingComment = $true
        }
        $ResolvingList = @()
        for ($i = 0; $i -lt $AstInfo.Count; $i++) {
            if (
                ($AstInfo[$i].Ast -isnot [TypeDefinitionAst]) -and
                ($AstInfo[$i].Ast -isnot [FunctionDefinitionAst])
            ) {
                $FindAstParameters = @{
                    Predicate              = $FindDefinitionPredicate
                    AstInfo                = $AstInfo[$i]
                    AsAstInfo              = $true
                    Registry               = $Registry
                    ParseDecoratingComment = $true
                }
                $ResolvingList += Find-Ast @FindAstParameters
            }
        }

        $ResolvingList | ForEach-Object -Process {
            if ($_.Ast -is [TypeDefinitionAst] -and $_.Ast.IsClass) {
                Resolve-ClassHelpInfo -AstInfo $_ -Registry $Registry
            } elseif ($_.Ast -is [TypeDefinitionAst] -and $_.Ast.IsEnum) {
                Resolve-EnumHelpInfo -AstInfo $_ -Registry $Registry
            } elseif ($_.Ast -is [FunctionDefinitionAst]) {
                # Not yet implemented
            }
        }
    }

    end {}
}
