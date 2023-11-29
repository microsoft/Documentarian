# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsBlockParsed.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
using module ./BaseHelpInfo.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Get-AstInfo.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

class EnumValueHelpInfo : BaseHelpInfo {
    # The value's label.
    [string] $Label
    # The numerical value.
    [int] $Value = 0
    # The Markdown text explaining the value's purpose.
    [string] $Description = ''
    # Whether the value is explicitly defined in the enum.
    [bool] $HasExplicitValue = $false

    [string] ToString() {
        <#
            .SYNOPSIS
            Converts an instance of **EnumValueHelpInfo** into a string.

            .DESCRIPTION
            The `ToString()` method converts an instance of the
            **EnumValueHelpInfo** class into a string with the instance's
            **Label** and **Value** on the first line,followed by the
            instance's **Description on the next line.

            .EXAMPLE
            ```powershell
            $enumValue = [EnumValueHelpInfo]@{
                Label       = 'NoCache'
                Value       = 4
                Description = 'Indicates the service should ignore caching.'
            }
            $enumValue.ToString()
            ```

            ```output
            NoCache (4):
            Indicates the service should ignore caching.
            ```
        #>

        return "$($this.Label) ($($this.Value)):`n$($this.Description)"
    }

    EnumValueHelpInfo() {
        $this.Label = ''
        $this.Value = 0
        $this.Description = ''
        $this.HasExplicitValue = $false
    }
    EnumValueHelpInfo([OrderedDictionary]$metadata) : base($metadata) {
    }

    EnumValueHelpInfo([AstInfo]$astInfo) {
        $this.Initialize($astInfo, [DecoratingCommentsBlockParsed]::new())
    }

    EnumValueHelpInfo([AstInfo]$astInfo, [DecoratingCommentsBlockParsed]$enumHelp) {
        $this.Initialize($astInfo, $enumHelp)
    }

    hidden [void] Initialize([AstInfo]$astInfo, [DecoratingCommentsBlockParsed]$enumHelp) {
        [MemberAst]$EnumValueAst = [EnumValueHelpInfo]::GetValidatedAst($astInfo)
        $LabelName = $EnumValueAst.Name.Trim()
        $this.Label = $LabelName
        $this.Value = $EnumValueAst.InitialValue.Value
        $this.HasExplicitValue = $null -ne $EnumValueAst.InitialValue
        if ($null -ne $enumHelp -and $enumHelp.IsUsable()) {
            $LabelDescription = $enumHelp.GetKeywordEntry('Label', $LabelName)
            if (-not [string]::IsNullOrEmpty($LabelDescription)) {
                $this.Description = $LabelDescription
            }
        }
        if ([string]::IsNullOrEmpty($this.Description)) {
            if ($LabelHelp = $astInfo.DecoratingComment.MungedValue) {
                $this.Description = $LabelHelp
            } else {
                $this.Description = ''
            }
        }
    }

    hidden static [MemberAst] GetValidatedAst([AstInfo]$astInfo) {
        [MemberAst]$TargetAst = $astInfo.Ast -as [MemberAst]

        if ($null -eq $TargetAst) {
            $Message = @(
                'Invalid AstInfo for EnumValueHelpInfo.'
                'Expected the Ast property to be a MemberAst whose parent AST is an enum,'
                "but the AST object's type was $($astInfo.Ast.GetType().FullName)."
            ) -join ' '
            throw $Message
        } elseif (-not $TargetAst.Parent.IsEnum) {
            $Message = @(
                'Invalid AstInfo for EnumValueHelpInfo.'
                'Expected the Ast property to be a MemberAst whose parent AST is an enum,'
                "but the parent AST is the $($TargetAst.Parent.Name) class."
            ) -join ' '
            throw $Message
        }

        return $TargetAst
    }

    static [EnumValueHelpInfo[]] Resolve(
        [AstInfo]$enumAstInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($enumAstInfo.Ast -isnot [TypeDefinitionAst]) {
            $Message = @(
                'Invalid argument. [EnumValueHelpInfo]::Resolve()'
                "expects an AstInfo object where the Ast property is a TypeDefinitionAst"
                "that defines a enum, but the Ast property's type was"
                $enumAstInfo.Ast.GetType().FullName
            ) -join ' '
            throw [System.ArgumentException]::new($Message, 'enumAstInfo')
        }

        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        [TypeDefinitionAst]$EnumAst = $enumAstInfo.Ast
        $Help = $enumAstInfo.DecoratingComment.ParsedValue

        return $EnumAst.Members | Where-Object -FilterScript {
            $_ -is [MemberAst]
        } | ForEach-Object -Process {
            $GetParameters = @{
                TargetAst              = $_
                Token                  = $enumAstInfo.Tokens
                Registry               = $registry
                ParseDecoratingComment = $true
            }
            $ValueAstInfo = Get-AstInfo @GetParameters
            if ($Help.IsUsable()) {
                [EnumValueHelpInfo]::new($ValueAstInfo, $Help)
            } else {
                [EnumValueHelpInfo]::new($ValueAstInfo)
            }
        }
    }

    hidden static [OrderedDictionary] AddYamlFormatting([OrderedDictionary]$metadata) {
        $metadata.Label = $metadata.Label | yayaml\Add-YamlFormat -ScalarStyle Plain -PassThru
        $metadata.Description = $metadata.Description | yayaml\Add-YamlFormat -ScalarStyle Literal -PassThru

        return $metadata
    }
}
