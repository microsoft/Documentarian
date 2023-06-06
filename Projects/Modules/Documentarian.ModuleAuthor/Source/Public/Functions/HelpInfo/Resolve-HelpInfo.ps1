# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
    $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
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
        [string]$Path,

        [Parameter(Mandatory, ParameterSetName = 'ByAstInfo')]
        [AstInfo]$AstInfo
    )

    begin {}

    process {
        if ($Path) {
            $AstInfo = Get-AstInfo -Path $Path
        }

        # Validate the AST isn't in bad shape
        if ($AstInfo.Ast.Extent.GetType().Name -eq 'EmptyScriptExtent') {
            throw "Ast empty; does '$Path' exist and have script content in it?"
        }

        $SharedParameters = @{
            AstInfo = $AstInfo
            Recurse = $true
        }

        [TypeDefinitionAst]$Definitions = Find-Ast @SharedParameters -Type 'TypeDefinitionAst'
        [FunctionDefinitionAst]$Functions = Find-Ast @SharedParameters -Type 'FunctionDefinitionAst'

        foreach ($Definition in $Definitions) {
            $DefinitionAstInfo = [AstInfo]::New($Definition, $AstInfo.Tokens, $AstInfo.Errors)

            if ($Definition.IsClass) {
                Resolve-ClassHelpInfo -AstInfo $DefinitionAstInfo
            } elseif ($Definition.IsEnum) {
                Resolve-EnumHelpInfo -AstInfo $DefinitionAstInfo
            }
        }

        foreach ($Function in $Functions) {
            # TODO: Resolve-FunctionHelpInfo
        }
    }

    end {}
}
