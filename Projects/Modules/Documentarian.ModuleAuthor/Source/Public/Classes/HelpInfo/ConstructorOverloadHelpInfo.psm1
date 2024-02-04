# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
using module ./OverloadHelpInfo.psm1
using module ./OverloadSignature.psm1

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

class ConstructorOverloadHelpInfo : OverloadHelpInfo {
    static [ConstructorOverloadHelpInfo] GetDefaultConstructor([string]$ClassName) {
        return [ConstructorOverloadHelpInfo]@{
            Signature = [OverloadSignature]@{
                Full     = "$ClassName()"
                TypeOnly = "$ClassName()"
            }
            Synopsis  = 'Creates an instance of the class with default values for every property.'
        }
    }

    ConstructorOverloadHelpInfo() : base() {}

    ConstructorOverloadHelpInfo([OrderedDictionary]$metadata) : base($metadata) {}

    ConstructorOverloadHelpInfo(
        [AstInfo]$astInfo
    ) : base($astInfo) {}

    ConstructorOverloadHelpInfo(
        [AstInfo]$astInfo,
        [DecoratingCommentsRegistry]$registry
    ) : base($astInfo, $registry) {}

    ConstructorOverloadHelpInfo(
        [FunctionMemberAst]$targetAst
    ) : base($targetAst) {}

    ConstructorOverloadHelpInfo(
        [FunctionMemberAst]$targetAst,
        $registry
    ) : base($targetAst, $registry) {}

    static ConstructorOverloadHelpInfo() {
        [ConstructorOverloadHelpInfo]::InitializeFormatters()
    }

    static [ConstructorOverloadHelpInfo[]] Resolve(
        [AstInfo]$astInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($astInfo.Ast -isnot [TypeDefinitionAst]) {
            $Message = @(
                'Invalid argument. [ConstructorOverloadHelpInfo]::Resolve()'
                'expects an AstInfo object where the Ast property is a TypeDefinitionAst'
                "that defines a class, but the Ast property's type was"
                $astInfo.Ast.GetType().FullName
            ) -join ' '
            throw [System.ArgumentException]::new($Message, 'astInfo')
        }

        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        [TypeDefinitionAst]$ClassAst = $astInfo.Ast

        $Constuctors = $ClassAst.Members | Where-Object -FilterScript {
            $_.GetType().Name -eq 'FunctionMemberAst' -and $_.IsConstructor
        } | ForEach-Object -Process {
            $GetParameters = @{
                TargetAst              = $_
                Token                  = $astInfo.Tokens
                Registry               = $registry
                ParseDecoratingComment = $true
            }
            $ConstructorAstInfo = Get-AstInfo @GetParameters
            [ConstructorOverloadHelpInfo]::new($ConstructorAstInfo, $registry)
        }

        if ($null -eq $Constuctors) {
            $Constuctors = @(
                [ConstructorOverloadHelpInfo]::GetDefaultConstructor($ClassAst.Name.Trim())
            )
        }

        return $Constuctors
    }

    static [HelpInfoFormatterDictionary] $Formatters

    static [Void] InitializeFormatters() {
        [ConstructorOverloadHelpInfo]::InitializeFormatters($false, $false)
    }

    static [HelpInfoFormatterDictionary] InitializeFormatters([bool]$passThru, [bool]$force) {
        if ($force -or [ConstructorOverloadHelpInfo]::Formatters.Count -eq 0) {
            [ConstructorOverloadHelpInfo]::Formatters = [HelpInfoFormatterDictionary]::new(
                [ordered]@{
                    Block    = [ConstructorOverloadHelpInfo]::GetDefaultFormatter()
                    ListItem = [ConstructorOverloadHelpInfo]::GetListItemFormatter()
                },
                [ordered]@{
                    Block = [ConstructorOverloadHelpInfo]::GetDefaultSectionFormatter()
                    List  = [ConstructorOverloadHelpInfo]::GetListSectionFormatter()
                }
            )
        }

        if ($passThru) {
            return [ConstructorOverloadHelpInfo]::Formatters
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
                    [ConstructorOverloadHelpInfo]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [ValidateRange(1, 5)]
                    [int]
                    $Level = 3,

                    [switch]$IncludeHidden
                )

                if (-not $IncludeHidden -and $HelpInfo.IsHidden) {
                    return ''
                }

                if ($null -eq $MarkdownBuilder) {
                    $options = @{
                        SpaceMungingOptions = 'CollapseEnd', 'TrimStart'
                    }
                    $MarkdownBuilder = Documentarian.MarkdownBuilder\New-Builder @options
                }

                $MarkdownBuilder
                | Add-Heading -Level $Level -Content $HelpInfo.Signature.ToString()
                | Add-Line -Content $HelpInfo.Synopsis
                | Add-Line -Content ''

                if (-not [string]::IsNullOrEmpty($HelpInfo.Description)) {
                    $MarkdownBuilder
                    | Add-Heading -Level ($Level + 1) -Content 'Description'
                    $lines = $HelpInfo.Description -split '\r?\n'
                    foreach ($line in $lines) {
                        $MarkdownBuilder | Add-Line -Content $line
                    }
                }

                if ($HelpInfo.Examples.Count -gt 0) {
                    $formatter = [ExampleHelpInfo]::Formatters.Section.Default
                    $formatter.Parameters.Level = $Level + 1

                    $MarkdownBuilder
                    | Add-Line -Content ''
                    | Add-Line -Content (
                        [ExampleHelpInfo]::ToMarkdown(
                            $HelpInfo.Examples,
                            $formatter
                        ).TrimEnd()
                    )
                }

                if ($HelpInfo.Parameters.Count -gt 0) {
                    $formatter = [OverloadParameterHelpInfo]::Formatters.Section.Default
                    $formatter.Parameters.Level = $Level + 1

                    $MarkdownBuilder
                    | Add-Line -Content ''
                    | Add-Line -Content (
                        [OverloadParameterHelpInfo]::ToMarkdown(
                            $HelpInfo.Parameters,
                            $formatter
                        ).TrimEnd()
                    )
                }

                if ($HelpInfo.Exceptions.Count -gt 0) {
                    $formatter = [OverloadExceptionHelpInfo]::Formatters.Section.Default
                    $formatter.Parameters.Level = $Level + 1

                    $MarkdownBuilder
                    | Add-Line -Content ''
                    | Add-Line -Content (
                        [OverloadExceptionHelpInfo]::ToMarkdown(
                            $HelpInfo.Exceptions,
                            $formatter
                        ).TrimEnd()
                    )
                }

                return ($markdownBuilder.ToString() -replace '(\r?\n)+$', '$1')
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
                    [ConstructorOverloadHelpInfo[]]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [string]
                    $Prefix,

                    [ValidateRange(1, 4)]
                    [int]
                    $Level = 2,

                    [string]
                    $HeadingText = 'Constructors'
                )

                if ($null -eq $MarkdownBuilder) {
                    $options = @{
                        SpaceMungingOptions = 'CollapseEnd', 'TrimStart'
                    }
                    $MarkdownBuilder = Documentarian.MarkdownBuilder\New-Builder @options
                }

                $MarkdownBuilder | Add-Heading -Level $Level -Content $HeadingText

                foreach ($constructor in $HelpInfo) {
                    $formatter = [ConstructorOverloadHelpInfo]::Formatters.Block
                    $formatter.Parameters.Level = $Level + 1
                    $formatted = $constructor.ToMarkdown($formatter)

                    $MarkdownBuilder | Add-Line -Content $formatted
                }

                return ($MarkdownBuilder.ToString() -replace '(\r?\n)+$', '$1')
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
                    [ConstructorOverloadHelpInfo[]]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [string]
                    $Prefix,

                    [int]
                    $HeadingLevel = 2,

                    [string]
                    $HeadingText = 'Constructors'
                )

                if ($null -eq $MarkdownBuilder) {
                    $options = @{
                        SpaceMungingOptions = 'CollapseEnd', 'TrimStart'
                    }
                    $MarkdownBuilder = Documentarian.MarkdownBuilder\New-Builder @options
                }

                $MarkdownBuilder |
                    Add-Heading -Level $HeadingLevel -Content $HeadingText |
                    Start-List

                foreach ($constructor in $HelpInfo) {
                    $formatter = [ConstructorOverloadHelpInfo]::Formatters.ListItem
                    $formatted = $constructor.ToMarkdown($formatter)

                    $MarkdownBuilder | Add-ListItem -ListItem $formatted
                }

                $MarkdownBuilder.EndList().ToString()
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
                    [ConstructorOverloadHelpInfo]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [switch]
                    $IncludeHidden
                )

                if (-not $IncludeHidden -and $HelpInfo.IsHidden) {
                    return ''
                }

                if ($null -eq $MarkdownBuilder) {
                    $options = @{
                        SpaceMungingOptions = 'CollapseEnd', 'TrimStart'
                    }
                    $MarkdownBuilder = Documentarian.MarkdownBuilder\New-Builder @options
                }

                $MarkdownBuilder
                | Add-Line -Content "``$($HelpInfo.Signature)``"
                | Add-Line
                | Add-Line -Content $HelpInfo.Synopsis

                return ($markdownBuilder.ToString() -replace '(\r?\n)+$', '$1' )
            }
        }
    }

    [string] ToMarkdown() {
        return $this.ToMarkdown([ConstructorOverloadHelpInfo]::Formatters.Default)
    }

    [string] ToMarkdown([HelpInfoFormatter]$formatter) {
        return $formatter.Format($this)
    }

    static [string] ToMarkdown([ConstructorOverloadHelpInfo[]]$values) {
        return [ConstructorOverloadHelpInfo]::ToMarkdown($values, [ConstructorOverloadHelpInfo]::Formatters.Section.Default)
    }

    static [string] ToMarkdown([ConstructorOverloadHelpInfo[]]$values, [HelpInfoFormatter]$formatter) {
        return $formatter.FormatSection($values)
    }
}
