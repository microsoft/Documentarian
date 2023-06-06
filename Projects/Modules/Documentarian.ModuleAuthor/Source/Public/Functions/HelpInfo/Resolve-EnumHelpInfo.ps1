# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using module ../../Classes/HelpInfo/EnumHelpInfo.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
    $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
    Resolve-Path -Path "$SourceFolder/Private/Functions/Comments/Resolve-CommentDecoration.ps1"
    Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Resolve-EnumHelpValue.ps1"
    Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Resolve-ExampleFromHelp.ps1"
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

        $Info = [EnumHelpInfo]::new()

        $Comments = $AstInfo.Tokens.Where{ $_.Kind -eq 'Comment' }

        $EnumAst = if ($AstInfo.Ast -is [TypeDefinitionAst]) {
            $AstInfo.Ast
        } else {
            Find-Ast -AstInfo $AstInfo -Type 'TypeDefinitionAst'
        }

        $Help = if (($AstInfo.Ast | Get-Member).Name -contains 'GetHelpContent') {
            $AstInfo.Ast.GetHelpContent()
        } else {
            $null
        }

        $ResolvingValueParameters = @{
            Tokens = $Comments
        }

        if ($null -ne $Help) {
            $Resolving.Help = $Help

            if ($Help.Synopsis) {
                $Info.Synopsis = $Help.Synopsis.Trim()
            }
            if ($Help.Description) {
                $Info.Description = $Help.Description.Trim()
            }
            if ($Help.Examples.Count -gt 0) {
                $Info.Examples = Resolve-ExampleFromHelp -Help $Help
            }
            if ($Help.Notes) {
                $Info.Notes = $Help.Notes.Trim()
            }
        } else {
            $ResolvingSynopsisParameters = @{
                StatementFirstLine = $EnumAst.Extent.StartLineNumber
                Tokens             = $Comments
            }
            $Info.Synopsis = Resolve-CommentDecoration @ResolvingSynopsisParameters
        }

        $ValueAsts = Find-Ast -AstInfo $AstInfo -Type MemberAst -Recurse
        $Values = $ValueAsts | ForEach-Object -Process {
            Resolve-EnumHelpValue -EnumValueAst $_ @ResolvingValueParameters
        }

        $NextValue = if ($IsFlagsEnum) { 1 } else { 0 }
        foreach ($EnumValue in $Values) {
            if (!$EnumValue.HasExplicitValue) {
                $EnumValue.Value = $NextValue
                $NextValue = if ($IsFlagsEnum) { $NextValue * 2 } else { $NextValue + 1 }
            } else {
                $NextValue = if ($IsFlagsEnum) { $EnumValue.Value * 2 } else { $EnumValue.Value + 1 }
            }
        }

        $Info.Name = $EnumAst.Name
        $Info.IsFlagsEnum = $EnumAst.Attributes.TypeName.FullName -contains 'Flags'
        $Info.Values = $Values

        $Info
    }

    end {}
}
