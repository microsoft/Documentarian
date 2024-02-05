# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
using module ./BaseHelpInfo.psm1
using module ./EnumValueHelpInfo.psm1
using module ./ExampleHelpInfo.psm1
using module ./HelpInfoFormatter.psm1

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

    EnumHelpInfo([OrderedDictionary]$metadata) : base($metadata) {
    }

    EnumHelpInfo([AstInfo]$astInfo) {
        $this.Initialize($astInfo, [DecoratingCommentsRegistry]::Get())
    }

    EnumHelpInfo([AstInfo]$astInfo, [DecoratingCommentsRegistry]$registry) {
        $this.Initialize($astInfo, $registry)
    }

    static EnumHelpInfo() {
        [EnumHelpInfo]::InitializeFormatters()
    }

    hidden [void] Initialize([AstInfo]$astInfo, [DecoratingCommentsRegistry]$registry) {
        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        $EnumAst = [EnumHelpInfo]::GetValidatedAst($astInfo)
        $Help    = $astInfo.DecoratingComment.ParsedValue

        $this.Name        = $EnumAst.Name
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

    hidden static [OrderedDictionary] AddYamlFormatting([OrderedDictionary]$metadata) {
        $metadata.Name        = $metadata.Name        | Yayaml\Add-YamlFormat -ScalarStyle Plain   -PassThru
        $metadata.Synopsis    = $metadata.Synopsis    | Yayaml\Add-YamlFormat -ScalarStyle Folded  -PassThru
        $metadata.Description = $metadata.Description | Yayaml\Add-YamlFormat -ScalarStyle Literal -PassThru
        $metadata.Notes       = $metadata.Notes       | Yayaml\Add-YamlFormat -ScalarStyle Literal -PassThru

        return $metadata
    }

    static [HelpInfoFormatterDictionary] $Formatters

    static InitializeFormatters() {
        [EnumHelpInfo]::InitializeFormatters($false, $false)
    }

    static [HelpInfoFormatterDictionary] InitializeFormatters([bool]$passThru, [bool]$force) {
        if ($force -or [EnumHelpInfo]::Formatters.Count -eq 0) {
            [EnumHelpInfo]::Formatters = [HelpInfoFormatterDictionary]::new(
                [ordered]@{
                    StandalonePage = [EnumHelpInfo]::GetDefaultFormatter()
                }
            )
        }

        if ($passThru) {
            return [EnumHelpInfo]::Formatters
        }

        return $null
    }

    hidden static [HelpInfoFormatter] GetDefaultFormatter() {
        return [HelpInfoFormatter]@{
            Parameters  = @{}
            ScriptBlock = {
                [CmdletBinding()]
                [OutputType([string])]
                param(
                    [Parameter(Mandatory)]
                    [EnumHelpInfo]
                    $HelpInfo,

                    [hashtable]
                    $FrontMatter,

                    [MarkdownBuilder]
                    $MarkdownBuilder
                )

                if ($null -eq $MarkdownBuilder) {
                    $options = @{
                        SpaceMungingOptions = 'CollapseEnd', 'TrimStart'
                    }
                    $MarkdownBuilder = Documentarian.MarkdownBuilder\New-Builder @options
                }

                if ($null -eq $FrontMatter -or $FrontMatter.Keys.Count -eq 0) {
                    $FrontMatter = @{
                        title = $HelpInfo.Name
                        date  = Get-Date -Format 'yyyy-MM-dd'
                        pwsh  = @{
                            name     = $HelpInfo.Name
                            kind     = 'enum'
                            synopsis = $HelpInfo.Synopsis
                        }
                    }
                }

                $definitionContent = "enum $($HelpInfo.Name)"
                if ($HelpInfo.IsFlagsEnum) {
                    $definitionContent = '[Flags()]', $definitionContent -join ' '
                }
                if ($HelpInfo.BaseTypes.Count -gt 0) {
                    $definitionContent += ' : ' + ($HelpInfo.BaseTypes -join ', ')
                }

                $MarkdownBuilder
                | Add-FrontMatter -FrontMatter $FrontMatter
                | Add-Heading -Level 1 -Content $HelpInfo.Name
                | Add-Heading -Level 2 -Content 'Synopsis'
                | Add-Line -Content $HelpInfo.Synopsis
                | Add-Line -Content ''
                | Add-Heading -Level 2 -Content 'Definition'
                | Start-CodeFence -Language 'powershell'
                | Add-Line -Content $definitionContent
                | Stop-CodeFence

                if (-not [string]::IsNullOrEmpty($HelpInfo.Description)) {
                    $MarkdownBuilder
                    | Add-Heading -Level 2 -Content 'Description'
                    $lines = $HelpInfo.Description -split '\r?\n'
                    foreach ($line in $lines) {
                        $MarkdownBuilder | Add-Line -Content $line
                    }
                }

                if ($HelpInfo.Examples.Count -gt 0) {
                    $MarkdownBuilder
                    | Add-Line -Content ''
                    | Add-Line -Content ([ExampleHelpInfo]::ToMarkdown($HelpInfo.Examples).TrimEnd())
                }

                $MarkdownBuilder
                | Add-Line -Content ''
                | Add-Line -Content ([EnumValueHelpInfo]::ToMarkdown($HelpInfo.Values))

                if (-not [string]::IsNullOrEmpty($HelpInfo.Notes)) {
                    $MarkdownBuilder
                    | Add-Line -Content ''
                    | Add-Heading -Level 2 -Content 'Notes'
                    $lines = $HelpInfo.Notes -split '\r?\n'
                    foreach ($line in $lines) {
                        $MarkdownBuilder | Add-Line -Content $line
                    }
                }

                return ($markdownBuilder.ToString() -replace '(\r?\n)+$','$1')
            }
        }
    }

    [string] ToMarkdown() {
        return $this.ToMarkdown([EnumHelpInfo]::Formatters.Default)
    }

    [string] ToMarkdown([HelpInfoFormatter]$formatter) {
        return $formatter.Format($this)
    }
}
