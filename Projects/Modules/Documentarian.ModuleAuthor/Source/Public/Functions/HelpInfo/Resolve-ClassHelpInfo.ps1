# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using module ../../Classes/HelpInfo/ClassHelpInfo.psm1
using module ../../Classes/HelpInfo/ConstructorOverloadHelpInfo.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
    $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
    Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Resolve-AttributeHelpInfo.ps1"
    Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Resolve-ClassMethodHelpInfo.ps1"
    Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Resolve-ClassPropertyHelpInfo.ps1"
    Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Resolve-ConstructorOverloadHelpInfo.ps1"
    Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Resolve-ExampleFromHelp.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
    . $RequiredFunction
}

#endregion RequiredFunctions

function Resolve-ClassHelpInfo {
    [CmdletBinding(DefaultParameterSetName = 'ByPath')]
    [OutputType([ClassHelpInfo])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'ByPath')]
        [ValidatePowerShellScriptPath()]
        [string]$Path,
        [Parameter(Mandatory, ParameterSetName = 'ByAstInfo')]
        [AstInfo]$AstInfo
    )

    begin {
        $ConstructorFilter = {
            $_.GetType().Name -eq 'FunctionMemberAst' -and $_.IsConstructor
        }
        $MethodFilter = {
            $_.GetType().Name -eq 'FunctionMemberAst' -and -not $_.IsConstructor
        }
        $PropertyFilter = {
            $_.GetType().Name -eq 'PropertyMemberAst'
        }
    }

    process {
        if ($Path) {
            $AstInfo = Get-AstInfo -Path $Path
        }

        [TypeDefinitionAst]$ClassAst = if ($AstInfo.Ast -is [TypeDefinitionAst]) {
            $AstInfo.Ast
        } else {
            Find-Ast -AstInfo $AstInfo -Type 'TypeDefinitionAst'
        }

        $Info = [ClassHelpInfo]::new()
        $Info.Name = $ClassAst.Name
        $Info.BaseTypes = $ClassAst.BaseTypes.ForEach({ Resolve-TypeName -TypeName $_.TypeName })

        $Resolving = @{
            Class  = $ClassAst
            Tokens = $AstInfo.Tokens
        }

        $Help = if (($AstInfo.Ast | Get-Member).Name -contains 'GetHelpContent') {
            $AstInfo.Ast.GetHelpContent()
        } else {
            $null
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
        }

        if ($ClassAst.Attributes.Count -gt 0) {
            $Info.Attributes = Resolve-AttributeHelpInfo -Attribute $ClassAst.Attributes
        }

        if ($ClassAst.Members.Where($PropertyFilter).Count -gt 0) {
            $Info.Properties = Resolve-ClassPropertyHelpInfo       @Resolving
        }
        if ($ClassAst.Members.Where($MethodFilter).Count -gt 0) {
            $Info.Methods = Resolve-ClassMethodHelpInfo         @Resolving
        }
        if ($ClassAst.Members.Where($ConstructorFilter).Count -gt 0) {
            $Info.Constructors = Resolve-ConstructorOverloadHelpInfo @Resolving
        } else {
            $Info.Constructors += [ConstructorOverloadHelpInfo]::GetDefaultConstructor(
                $ClassAst.Name
            )
        }

        $Info
    }
}
