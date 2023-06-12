# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
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

class EnumHelpInfo {
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

    [OrderedDictionary] ToMetadataDictionary() {
        <#
            .SYNOPSIS
            Converts an instance of the class into a dictionary.

            .DESCRIPTION
            The `ToMetadataDictionary()` method converts an instance of the
            class into an ordered dictionary so you can export the
            documentation metadata into YAML or JSON.

            This makes it easier for you to use the data-docs model, which
            separates the content of the reference documentation from its
            presentation.
        #>

        $Metadata = [OrderedDictionary]::new([System.StringComparer]::OrdinalIgnoreCase)

        $Metadata.Add('Name', $this.Name.Trim())
        $Metadata.Add('Synopsis', $this.Synopsis.Trim())
        $Metadata.Add('Description', $this.Description.Trim())
        if ($this.Examples.Count -gt 0) {
            $Metadata.Add('Examples', [OrderedDictionary[]]($this.Examples.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Examples', [OrderedDictionary[]]@())
        }
        $Metadata.Add('Notes', $this.Notes.Trim())
        $Metadata.Add('IsFlagsEnum', $this.IsFlagsEnum)
        $Metadata.Add('Values', [OrderedDictionary[]]($this.Values.ToMetadataDictionary()))

        return $Metadata
    }

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

        if ($null -ne $Help) {
            if ($Help.Synopsis) {
                $this.Synopsis = $Help.Synopsis.Trim()
            }
            if ($Help.Description) {
                $this.Description = $Help.Description.Trim()
            }

            $this.Examples = [ExampleHelpInfo]::Resolve($Help)

            if ($Help.Notes) {
                $this.Notes = $Help.Notes.Trim()
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

        $ValuesHelpInfo = [EnumHelpInfo]::GetValuesAstInfo($enumAstInfo, $registry) |
            ForEach-Object -Process {
                if ($null -ne $Help) {
                    [EnumValueHelpInfo]::new($_, $EnumHelp)
                } else {
                    [EnumValueHelpInfo]::new($_)
                }
            }

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
