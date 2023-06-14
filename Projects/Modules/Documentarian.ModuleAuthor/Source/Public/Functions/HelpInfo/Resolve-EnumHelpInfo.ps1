# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using module ../../Classes/AstInfo.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsRegistry.psm1
using module ../../Classes/HelpInfo/EnumHelpInfo.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Find-Ast.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Get-AstInfo.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/DecoratingComments/New-DecoratingCommentsRegistry.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Resolve-EnumHelpInfo {
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

        $FindEnumPredicate = {
            [CmdletBinding()]
            [OutputType([bool])]

            param(
                [Ast]$AstObject
            )

            return ($AstObject -is [TypeDefinitionAst] -and $AstObject.IsEnum)
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

        for ($i = 0; $i -lt $AstInfo.Count; $i++) {
            if ($AstInfo[$i].Ast -isnot [TypeDefinitionAst]) {
                $FindAstParameters = @{
                    Predicate              = $FindEnumPredicate
                    AstInfo                = $AstInfo[$i]
                    AsAstInfo              = $true
                    Registry               = $Registry
                    ParseDecoratingComment = $true
                }
                $AstInfo[$i] = Find-Ast @FindAstParameters
            }
        }

        if ($AstInfo.Count -eq 0) {
            $Message = @(
                'Unable to resolve a type definition AST from input.'
                'Resolve-EnumHelpInfo expects files that define at least one enum'
                'or AstInfo objects defining an enum.'
            ) -join ' '
            throw $Message
        }

        foreach ($Definition in $AstInfo) {
            Write-Verbose "Parsing the AST for the $($Definition.Ast.Name) enum's help info..."
            [EnumHelpInfo]::new($Definition, $Registry)
        }
    }

    end {}
}
