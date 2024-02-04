# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsBlockParsed.psm1
using module ./BaseHelpInfo.psm1
using module ./HelpInfoFormatter.psm1

class ExampleHelpInfo : BaseHelpInfo {
    # The title for the example.
    [string] $Title = ''
    # The body text for the example.
    [string] $Body

    ExampleHelpInfo() {}

    ExampleHelpInfo([OrderedDictionary]$metadata) : base($metadata) {
    }

    static ExampleHelpInfo() {
        [ExampleHelpInfo]::InitializeFormatters()
    }

    static [ExampleHelpInfo[]] Resolve ([DecoratingCommentsBlockParsed]$help) {
        if ((-not $help.IsUsable()) -or ($help.Example.Count -eq 0)) {
            return @()
        }

        return $help.Example | ForEach-Object -Process {
            [ExampleHelpInfo]@{
                Title = $_.Value
                Body  = $_.Content.Trim()
            }
        }
    }

    static [ExampleHelpInfo[]] Resolve ([AstInfo]$astInfo) {
        $help = $astInfo.DecoratingComment.ParsedValue

        if ((-not $help.IsUsable()) -or ($help.Example.Count -eq 0)) {
            return @()
        }

        return $help.Example | ForEach-Object -Process {
            [ExampleHelpInfo]@{
                Title = $_.Value
                Body  = $_.Content.Trim()
            }
        }
    }

    hidden static [OrderedDictionary] AddYamlFormatting([OrderedDictionary]$metadata) {
        $metadata.Title = $metadata.Title | yayaml\Add-YamlFormat -ScalarStyle Plain   -PassThru
        $metadata.Body  = $metadata.Body  | yayaml\Add-YamlFormat -ScalarStyle Literal -PassThru

        return $metadata
    }


    static [HelpInfoFormatterDictionary] $Formatters

    static InitializeFormatters() {
        [ExampleHelpInfo]::InitializeFormatters($false, $false)
    }

    static [HelpInfoFormatterDictionary] InitializeFormatters([bool]$passThru, [bool]$force) {
        if ($force -or [ExampleHelpInfo]::Formatters.Count -eq 0) {
            [ExampleHelpInfo]::Formatters = [HelpInfoFormatterDictionary]::new(
                [ordered]@{
                    Block    = [ExampleHelpInfo]::GetDefaultFormatter()
                    ListItem = [ExampleHelpInfo]::GetListItemFormatter()
                },
                [ordered]@{
                    Block = [ExampleHelpInfo]::GetDefaultSectionFormatter()
                    List  = [ExampleHelpInfo]::GetListSectionFormatter()
                }
            )
        }

        if ($passThru) {
            return [ExampleHelpInfo]::Formatters
        }

        return $null
    }

    hidden static [HelpInfoFormatter] GetDefaultFormatter() {
        return [HelpInfoFormatter]@{
            Parameters  = @{}
            ScriptBlock = {
                [cmdletbinding()]
                [OutputType([string])]
                param(
                    [Parameter(Mandatory)]
                    [ExampleHelpInfo]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [string]
                    $Prefix,

                    [ValidateRange(1, 6)]
                    [int]
                    $Level = 3
                )

                if ($null -eq $MarkdownBuilder) {
                    $options = @{
                        SpaceMungingOptions = 'CollapseEnd', 'TrimStart'
                    }
                    $MarkdownBuilder = Documentarian.MarkdownBuilder\New-Builder @options
                }

                $MarkdownBuilder | Add-Heading -Level $Level -Content (
                    ($Prefix, $HelpInfo.Title -join ' ').Trim()
                )

                $splitLines = $HelpInfo.Body.Trim() -split '\r?\n'
                foreach ($line in $splitLines) {
                    $MarkdownBuilder | Add-Line -Content $Line
                }

                return $MarkdownBuilder.ToString()
            }
        }
    }

    hidden static [HelpInfoFormatter] GetListItemFormatter() {
        return [HelpInfoFormatter]@{
            Parameters  = @{}
            ScriptBlock = {
                [CmdletBinding()]
                [OutputType([string])]
                param(
                    [Parameter(Mandatory)]
                    [ExampleHelpInfo]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [ValidateRange(1, 6)]
                    [int]
                    $Level = 3
                )

                if ($null -eq $MarkdownBuilder) {
                    $options = @{
                        SpaceMungingOptions = 'CollapseEnd', 'TrimStart'
                    }
                    $MarkdownBuilder = Documentarian.MarkdownBuilder\New-Builder @options
                }

                $title = ($Prefix, $HelpInfo.Title -join ' ').Trim()

                if (![string]::IsNullOrEmpty($title)) {
                    $MarkdownBuilder | Add-Line -Content $title | Add-Line
                }

                $MarkdownBuilder | Add-Line -Content $HelpInfo.Body

                return $MarkdownBuilder.ToString()
            }
        }
    }

    hidden static [HelpInfoFormatter] GetDefaultSectionFormatter() {
        return [HelpInfoFormatter]@{
            Parameters  = @{ }
            ScriptBlock = {
                [cmdletbinding()]
                [OutputType([string])]
                param(
                    [Parameter(Mandatory)]
                    [ExampleHelpInfo[]]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [string]
                    $Prefix,

                    [ValidateRange(1, 5)]
                    [int]
                    $Level = 2
                )

                if ($null -eq $MarkdownBuilder) {
                    $options = @{
                        SpaceMungingOptions = 'CollapseEnd', 'TrimStart'
                    }
                    $MarkdownBuilder = Documentarian.MarkdownBuilder\New-Builder @options
                }

                $markdownBuilder | Add-Heading -Level $Level -Content 'Examples'

                $Count = 1
                foreach ($Example in $HelpInfo) {
                    $formatter = [ExampleHelpInfo]::Formatters.Default

                    $formatter.Parameters.Prefix = if ([string]::IsNullOrEmpty($Example.Title)) {
                        "Example ${Count}"
                    } else {
                        "Example ${Count}:"
                    }
                    $formatter.Parameters.Level  = $Level + 1

                    $markdownBuilder | Add-Line -Content $Example.ToMarkdown($formatter)

                    $Count++
                }

                return $markdownBuilder.ToString()
            }
        }
    }

    hidden static [HelpInfoFormatter] GetListSectionFormatter() {
        return [HelpInfoFormatter]@{
            Parameters  = @{}
            ScriptBlock = {
                [CmdletBinding()]
                [OutputType([string])]
                param(
                    [Parameter(Mandatory)]
                    [ExampleHelpInfo[]]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [string]
                    $Prefix,

                    [ValidateRange(1, 6)]
                    [int]
                    $Level = 2,

                    [string]
                    $HeadingText = 'Examples'
                )

                if ($null -eq $MarkdownBuilder) {
                    $options = @{
                        SpaceMungingOptions = 'CollapseEnd', 'TrimStart'
                    }
                    $MarkdownBuilder = Documentarian.MarkdownBuilder\New-Builder @options
                }

                $MarkdownBuilder |
                    Add-Heading -Level $Level -Content $HeadingText |
                    Start-List -AsNumberedList

                foreach ($param in $HelpInfo) {
                    $formatter = [ExampleHelpInfo]::Formatters.ListItem
                    $formatted = $param.ToMarkdown($formatter)

                    $MarkdownBuilder | Add-ListItem -ListItem $formatted
                }

                $MarkdownBuilder.EndList().ToString()
            }
        }
    }

    [string] ToMarkdown() {
        return $this.ToMarkdown([ExampleHelpInfo]::Formatters.Default)
    }

    [string] ToMarkdown([HelpInfoFormatter]$formatter) {
        return $formatter.Format($this)
    }

    static [string] ToMarkdown([ExampleHelpInfo[]]$examples) {
        return [ExampleHelpInfo]::ToMarkdown($examples, [ExampleHelpInfo]::Formatters.Section.Default)
    }

    static [string] ToMarkdown([ExampleHelpInfo[]]$examples, [HelpInfoFormatter]$formatter) {
        return $formatter.FormatSection($examples)
    }
}
