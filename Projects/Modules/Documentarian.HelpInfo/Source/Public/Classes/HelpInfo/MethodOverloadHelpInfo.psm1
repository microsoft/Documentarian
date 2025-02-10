# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
using module ./OverloadHelpInfo.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
    $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
    Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Get-AstInfo.ps1"
    Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Resolve-TypeName.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
    . $RequiredFunction
}

#endregion RequiredFunctions

class MethodOverloadHelpInfo : OverloadHelpInfo {
    <#
        The full type name of the overload's output. If the overload doesn't
        return any output, this value should be `System.Void`.
    #>
    [string] $ReturnType
    <#
        Indicates whether the overload is available on the class itself instead
        of an instance of the class.
    #>
    [bool] $IsStatic = $false

    MethodOverloadHelpInfo() : base() {}

    MethodOverloadHelpInfo([OrderedDictionary]$metadata) : base($metadata) {}

    MethodOverloadHelpInfo(
        [AstInfo]$astInfo
    ) : base($astInfo) {
        [FunctionMemberAst]$MethodAst = $astInfo.Ast
        $this.SetProperties($MethodAst)
    }

    MethodOverloadHelpInfo(
        [AstInfo]$astInfo,
        [DecoratingCommentsRegistry]$registry
    ) : base($astInfo, $registry) {
        [FunctionMemberAst]$MethodAst = $astInfo.Ast
        $this.SetProperties($MethodAst)
    }

    MethodOverloadHelpInfo(
        [FunctionMemberAst]$targetAst
    ) : base($targetAst) {
        $this.SetProperties($targetAst)
    }

    MethodOverloadHelpInfo(
        [FunctionMemberAst]$targetAst,
        $registry
    ) : base($targetAst, $registry) {
        $this.SetProperties($targetAst)
    }

    static MethodOverloadHelpInfo() {
        [MethodOverloadHelpInfo]::InitializeFormatters()
    }

    hidden [void] SetProperties([FunctionMemberAst]$methodAst) {
        $this.ReturnType = if ($ReturnTypeName = $methodAst.ReturnType.TypeName) {
            Resolve-TypeName -TypeName $ReturnTypeName
        } else {
            'System.Void'
        }

        $this.IsStatic   = $methodAst.IsStatic
    }

    static [MethodOverloadHelpInfo[]] Resolve(
        [string]$methodName,
        [AstInfo]$astInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($astInfo.Ast -isnot [TypeDefinitionAst]) {
            $Message = @(
                'Invalid argument. [MethodOverloadHelpInfo]::Resolve()'
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

        return $ClassAst.Members | Where-Object -FilterScript {
            ($_.GetType().Name -eq 'FunctionMemberAst') -and
            (-not $_.IsConstructor) -and
            ($_.Name -eq $methodName)
        } | ForEach-Object -Process {
            $GetParameters = @{
                TargetAst              = $_
                Token                  = $astInfo.Tokens
                Registry               = $registry
                ParseDecoratingComment = $true
            }
            $MethodAstInfo = Get-AstInfo @GetParameters
            [MethodOverloadHelpInfo]::new($MethodAstInfo)
        }
    }

    hidden static [OrderedDictionary] AddYamlFormatting([OrderedDictionary]$metadata) {
        $metadata = [OverloadHelpInfo]::AddYamlFormatting($metadata)

        $metadata.ReturnType = $metadata.Type | yayaml\Add-YamlFormat -ScalarStyle Plain -PassThru

        return $metadata
    }

    static [HelpInfoFormatterDictionary] $Formatters

    static InitializeFormatters() {
        [MethodOverloadHelpInfo]::InitializeFormatters($false, $false)
    }

    static [HelpInfoFormatterDictionary] InitializeFormatters([bool]$passThru, [bool]$force) {
        if ($force -or [MethodOverloadHelpInfo]::Formatters.Count -eq 0) {
            [MethodOverloadHelpInfo]::Formatters = [HelpInfoFormatterDictionary]::new(
                [ordered]@{
                    Block = [MethodOverloadHelpInfo]::GetDefaultFormatter()
                },
                [ordered]@{
                    Block = [MethodOverloadHelpInfo]::GetDefaultSectionFormatter()
                }
            )
        }

        if ($passThru) {
            return [MethodOverloadHelpInfo]::Formatters
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
                    [MethodOverloadHelpInfo]
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
                    if ($Level -lt 5) {
                        $formatter = [ExampleHelpInfo]::Formatters.Section.Default
                    } else {
                        $formatter = [ExampleHelpInfo]::Formatters.Section.List
                    }
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
                    if ($Level -lt 5) {
                        $formatter = [OverloadParameterHelpInfo]::Formatters.Section.Default
                    } else {
                        $formatter = [OverloadParameterHelpInfo]::Formatters.Section.List
                    }
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
                    if ($Level -lt 5) {
                        $formatter = [OverloadExceptionHelpInfo]::Formatters.Section.Default
                    } else {
                        $formatter = [OverloadExceptionHelpInfo]::Formatters.Section.List
                    }
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
                    [MethodOverloadHelpInfo[]]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [string]
                    $Prefix,

                    [ValidateRange(1, 4)]
                    [int]
                    $Level = 3,

                    [string]
                    $HeadingText = 'Overloads'
                )

                if ($null -eq $MarkdownBuilder) {
                    $options = @{
                        SpaceMungingOptions = 'CollapseEnd', 'TrimStart'
                    }
                    $MarkdownBuilder = Documentarian.MarkdownBuilder\New-Builder @options
                }

                $MarkdownBuilder | Add-Heading -Level $Level -Content $HeadingText

                foreach ($method in $HelpInfo) {
                    $formatter = [MethodOverloadHelpInfo]::Formatters.Block
                    $formatter.Parameters.Level = $Level + 1
                    $formatted = $method.ToMarkdown($formatter)

                    $MarkdownBuilder | Add-Line -Content $formatted
                }

                return ($MarkdownBuilder.ToString() -replace '(\r?\n)+$', '$1')
            }
        }
    }

    [string] ToMarkdown() {
        return $this.ToMarkdown([MethodOverloadHelpInfo]::Formatters.Default)
    }

    [string] ToMarkdown([HelpInfoFormatter]$formatter) {
        return $formatter.Format($this)
    }

    static [string] ToMarkdown([MethodOverloadHelpInfo[]]$values) {
        return [MethodOverloadHelpInfo]::ToMarkdown($values, [MethodOverloadHelpInfo]::Formatters.Section.Default)
    }

    static [string] ToMarkdown([MethodOverloadHelpInfo[]]$values, [HelpInfoFormatter]$formatter) {
        return $formatter.FormatSection($values)
    }
}
