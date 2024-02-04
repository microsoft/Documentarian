# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsBlockParsed.psm1
using module ./BaseHelpInfo.psm1

class OverloadExceptionHelpInfo : BaseHelpInfo {
    # The full type name of the exception an overload may raise.
    [string] $Type
    # Information about when and why the overload might raise this exception.
    [string] $Description = ''

    OverloadExceptionHelpInfo() {}
    OverloadExceptionHelpInfo([OrderedDictionary]$metadata) : base($metadata) {
    }

    OverloadExceptionHelpInfo([string]$type) {
        $this.Initialize($type, '')
    }

    OverloadExceptionHelpInfo([string]$type, $description) {
        $this.Initialize($type, $description)
    }

    static OverloadExceptionHelpInfo () {
        [OverloadExceptionHelpInfo]::InitializeFormatters()
    }

    hidden [void] Initialize([string]$type, [string]$description) {
        $this.Type = $type
        $this.Description = $description
    }

    static [OverloadExceptionHelpInfo[]] Resolve([AstInfo]$overloadAstInfo) {
        if ($overloadAstInfo.ast -isnot [FunctionMemberAst]) {
            $Message = @(
                "Invalid AstInfo object. Expected the object's Ast property"
                'to have the type FunctionMemberAst, but it was'
                $overloadAstInfo.Ast.GetType().FullName
            ) -join ' '
            throw [System.ArgumentException]::new($Message)
        }

        $overloadHelp = $overloadAstInfo.DecoratingComment.ParsedValue

        return [OverloadExceptionHelpInfo]::Resolve($overloadHelp)
    }

    static [OverloadExceptionHelpInfo[]] Resolve([DecoratingCommentsBlockParsed]$overloadHelp) {
        $Exceptions = $overloadHelp.Exception

        if ($null -eq $Exceptions) {
            return @()
        }

        return $Exceptions | ForEach-Object -Process {
            [OverloadExceptionHelpInfo]::new($_.Value, $_.Content)
        }
    }

    hidden static [OrderedDictionary] AddYamlFormatting([OrderedDictionary]$metadata) {
        $metadata.Type = $metadata.Type | yayaml\Add-YamlFormat -ScalarStyle Plain -PassThru
        $metadata.Description = $metadata.Description | yayaml\Add-YamlFormat -ScalarStyle Literal -PassThru

        return $metadata
    }

    static [HelpInfoFormatterDictionary] $Formatters

    static InitializeFormatters() {
        [OverloadExceptionHelpInfo]::InitializeFormatters($false, $false)
    }

    static [HelpInfoFormatterDictionary] InitializeFormatters([bool]$passThru, [bool]$force) {
        if ($force -or [OverloadExceptionHelpInfo]::Formatters.Count -eq 0) {
            [OverloadExceptionHelpInfo]::Formatters = [HelpInfoFormatterDictionary]::new(
                [ordered]@{
                    Block    = [OverloadExceptionHelpInfo]::GetDefaultFormatter()
                    ListItem = [OverloadExceptionHelpInfo]::GetListItemFormatter()
                },
                [ordered]@{
                    Block = [OverloadExceptionHelpInfo]::GetDefaultSectionFormatter()
                    List  = [OverloadExceptionHelpInfo]::GetListSectionFormatter()
                }
            )
        }

        if ($passThru) {
            return [OverloadExceptionHelpInfo]::Formatters
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
                    [OverloadExceptionHelpInfo]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [ValidateRange(1, 6)]
                    [int]
                    $Level = 4
                )

                if ($null -eq $MarkdownBuilder) {
                    $options = @{
                        SpaceMungingOptions = 'CollapseEnd', 'TrimStart'
                    }
                    $MarkdownBuilder = Documentarian.MarkdownBuilder\New-Builder @options
                }

                $MarkdownBuilder
                | Add-Heading -Level $Level -Content $HelpInfo.Type

                $Description = $HelpInfo.Description
                if ([string]::IsNullOrEmpty($Description)) {
                    $Description = '<!-- TODO: Add a description. -->'
                }

                if (-not [string]::IsNullOrEmpty($HelpInfo.Description)) {
                    $lines = $Description -split '\r?\n'
                    foreach ($line in $lines) {
                        $MarkdownBuilder | Add-Line -Content $line
                    }
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
                    [OverloadExceptionHelpInfo]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [ValidateRange(1, 6)]
                    [int]
                    $Level = 4
                )

                if ($null -eq $MarkdownBuilder) {
                    $options = @{
                        SpaceMungingOptions = 'CollapseEnd', 'TrimStart'
                    }
                    $MarkdownBuilder = Documentarian.MarkdownBuilder\New-Builder @options
                }

                $Title = '**{0}**' -f $HelpInfo.Type

                $Description = $HelpInfo.Description
                if ([string]::IsNullOrEmpty($Description)) {
                    $Description = '<!-- TODO: Add a description. -->'
                }

                $MarkdownBuilder |
                    Add-Line -Content $Title |
                    Add-Line |
                    Add-Line -Content $Description

                return $MarkdownBuilder.ToString()
            }
        }
    }

    hidden static [HelpInfoFormatter] GetDefaultSectionFormatter() {
        return [HelpInfoFormatter]@{
            Parameters  = @{}
            ScriptBlock = {
                [CmdletBinding()]
                [OutputType([string])]
                param(
                    [Parameter(Mandatory)]
                    [OverloadExceptionHelpInfo[]]
                    $HelpInfo,

                    [string]
                    $Prefix,

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

                $MarkdownBuilder
                | Add-Heading -Level $Level -Content 'Exceptions'

                foreach ($Exception in $HelpInfo) {
                    $formatter = [OverloadExceptionHelpInfo]::Formatters.Default
                    $formatter.Parameters.Level = $Level + 1

                    $markdownBuilder | Add-Line -Content $Exception.ToMarkdown($formatter)
                }

                return ($markdownBuilder.ToString() -replace '(\r?\n)+$', '$1')
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
                    [OverloadExceptionHelpInfo[]]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [string]
                    $Prefix,

                    [ValidateRange(1, 6)]
                    [int]
                    $Level = 5,

                    [string]
                    $HeadingText = 'Exceptions'
                )

                if ($null -eq $MarkdownBuilder) {
                    $options = @{
                        SpaceMungingOptions = 'CollapseEnd', 'TrimStart'
                    }
                    $MarkdownBuilder = Documentarian.MarkdownBuilder\New-Builder @options
                }

                $MarkdownBuilder |
                    Add-Heading -Level $Level -Content $HeadingText |
                    Start-List

                foreach ($param in $HelpInfo) {
                    $formatter = [OverloadExceptionHelpInfo]::Formatters.ListItem
                    $formatted = $param.ToMarkdown($formatter)

                    $MarkdownBuilder | Add-ListItem -ListItem $formatted
                }

                $MarkdownBuilder.EndList().ToString()
            }
        }
    }

    [string] ToMarkdown() {
        return $this.ToMarkdown([OverloadExceptionHelpInfo]::Formatters.Default)
    }

    [string] ToMarkdown([HelpInfoFormatter]$formatter) {
        return $formatter.Format($this)
    }

    static [string] ToMarkdown([OverloadExceptionHelpInfo[]]$values) {
        return [OverloadExceptionHelpInfo]::ToMarkdown($values, [OverloadExceptionHelpInfo]::Formatters.Section.Default)
    }

    static [string] ToMarkdown([OverloadExceptionHelpInfo[]]$values, [HelpInfoFormatter]$formatter) {
        return $formatter.FormatSection($values)
    }
}
