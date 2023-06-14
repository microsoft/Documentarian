# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
using module ./BaseHelpInfo.psm1
using module ./EnumValueHelpInfo.psm1
using module ./ExampleHelpInfo.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Find-Ast.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

class EnumHelpInfo : BaseHelpInfo {
    # The name of the enumeration.
    [string] $Name
    # A short description of the enumeration's purpose.
    [string] $Synopsis = ''
    # A full description of the enumeration's purpose, with details.
    [string] $Description = ''
    # The list of examples showing how you can use the enumeration.
    [ExampleHelpInfo[]] $Examples = @()
    # Additional notes about the enumeration.
    [string] $Notes = ''
    # Whether the enumeration represents bit flags.
    [boolean] $IsFlagsEnum = $false
    # The list of values defined by the enumeration with their documentation.
    [EnumValueHelpInfo[]] $Values = @()

    EnumHelpInfo() {}

    EnumHelpInfo([AstInfo]$astInfo) {
        $this.Initialize($astInfo, [DecoratingCommentsRegistry]::Get())
    }

    EnumHelpInfo([AstInfo]$astInfo, [DecoratingCommentsRegistry]$registry) {
        $this.Initialize($astInfo, $registry)
    }

    hidden [void] Initialize([AstInfo]$astInfo, [DecoratingCommentsRegistry]$registry) {
        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        $EnumAst = [EnumHelpInfo]::GetValidatedAst($astInfo)
        $Help = $astInfo.DecoratingComment.ParsedValue

        $this.Name = $EnumAst.Name
        $this.IsFlagsEnum = [EnumHelpInfo]::TestIsFlagsEnum($EnumAst)

        if ($Help.IsUsable()) {
            if ($HelpSynopsis = $Help.GetKeywordEntry('Synopsis')) {
                $this.Synopsis = $HelpSynopsis
            }
            if ($HelpDescription = $Help.GetKeywordEntry('Description')) {
                $this.Description = $HelpDescription
            }

            $this.Examples = [ExampleHelpInfo]::Resolve($Help)

            if ($HelpNotes = $Help.GetKeywordEntry('Notes')) {
                $this.Notes = $HelpNotes
            }
        } elseif ($SynopsisHelp = $astInfo.DecoratingComment.MungedValue) {
            $this.Synopsis = $SynopsisHelp.Trim()
        }

        $this.Values = [EnumHelpInfo]::GetValuesHelpInfo($astInfo, $registry)
    }

    hidden static [bool] TestIsFlagsEnum([TypeDefinitionAst]$enumAst) {
        return ($enumAst.Attributes.TypeName.FullName -contains 'Flags')
    }

    hidden static [EnumValueHelpInfo[]] GetValuesHelpInfo(
        [AstInfo]$enumAstInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        $ValuesAreFlags = [EnumHelpInfo]::TestIsFlagsEnum($enumAstInfo.Ast)

        $ValuesHelpInfo = [EnumValueHelpInfo]::Resolve($enumAstInfo, $registry)

        $NextValue = if ($ValuesAreFlags) { 1 } else { 0 }
        foreach ($EnumValue in $ValuesHelpInfo) {
            if (!$EnumValue.HasExplicitValue) {
                $EnumValue.Value = $NextValue
                $NextValue = if ($ValuesAreFlags) {
                    $NextValue * 2
                } else { $NextValue + 1 }
            } else {
                $NextValue = if ($ValuesAreFlags) {
                    $EnumValue.Value * 2
                } else { $EnumValue.Value + 1 }
            }
        }

        return $ValuesHelpInfo
    }

    hidden static [AstInfo[]] GetValuesAstInfo(
        [AstInfo]$enumAstInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        $FindValueParameters = @{
            AstInfo                = $enumAstInfo
            Type                   = 'MemberAst'
            AsAstInfo              = $true
            Registry               = $registry
            ParseDecoratingComment = $true
        }
        return (Find-Ast @FindValueParameters)
    }

    hidden static [TypeDefinitionAst] GetValidatedAst([AstInfo] $astInfo) {
        $TargetAst = $astInfo.Ast -as [TypeDefinitionAst]

        if ($null -eq $TargetAst) {
            $Message = @(
                'Invalid AstInfo for EnumHelpInfo.'
                'Expected the Ast property to be a TypeDefinitionAst for an enum,'
                "but the AST object's type was $($astInfo.Ast.GetType().FullName)."
            ) -join ' '
            throw $Message
        } elseif (-not $TargetAst.IsEnum) {
            $Message = @(
                'Invalid AstInfo for EnumHelpInfo.'
                'Expected the Ast property to be a TypeDefinitionAst for an enum,'
                "but the parent AST is the $($TargetAst.Name) class."
            ) -join ' '
            throw $Message
        }

        return $TargetAst
    }
}
