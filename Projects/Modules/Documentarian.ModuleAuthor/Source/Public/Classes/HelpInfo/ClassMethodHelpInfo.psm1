# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
using module ./BaseHelpInfo.psm1
using module ./MethodOverloadHelpInfo.psm1

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

class ClassMethodHelpInfo : BaseHelpInfo {
    # The name of the method, shared by all overloads.
    [string] $Name
    # A short description of the method.
    [string] $Synopsis = ''
    # The list of overloads for this method with their documentation.
    [MethodOverloadHelpInfo[]] $Overloads = @()

    static ClassMethodHelpInfo() {
        [ClassMethodHelpInfo]::InitializeFormatters()
    }

    ClassMethodHelpInfo() {
        <#
            .SYNOPSIS
            Default constructor. Doesn't initialize or define the instance.
        #>
    }

    ClassMethodHelpInfo([OrderedDictionary]$metadata) : base($metadata) {
        <#
            .SYNOPSIS
            Initializes an instance from a dictionary, as read back from YAML or JSON.

            .PARAMETER metadata
            The value for this parameter should be an ordered dictionary that keys with the same
            name as this class's properties. The values for the `Name` and `Synopsis` keys should
            be strings. The value for the `Overloads` key should be an array of ordered dictionaries
            that can be used to initialize instances of the `MethodOverloadHelpInfo` class.

            .EXAMPLE Convert YAML to an instance of ClassMethodHelpInfo
            ```powershell
            $classInfo   = Get-Content -Path .\ExampleClass.yaml -Raw | YaYaml\ConvertFrom-Yaml
            $classMethod = [ClassMethodHelpInfo]::new($classInfo.Methods[0])
            ```

            .EXCEPTION System.Management.Automation.RuntimeException

            This constructor throws an `InvalidOperation` runtime exception if the metadata
            dictionary contains a key that doesn't match one of the class's properties.
        #>
    }

    ClassMethodHelpInfo(
        [string]$methodName,
        [AstInfo]$classAstInfo
    ) {
        $this.Initialize($methodName, $classAstInfo, [DecoratingCommentsRegistry]::Get())
    }

    ClassMethodHelpInfo(
        [string]$methodName,
        [AstInfo]$classAstInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        $this.Initialize($methodName, $classAstInfo, $registry)
    }

    ClassMethodHelpInfo(
        [string]$methodName,
        [TypeDefinitionAst]$classAst
    ) {
        $this.Initialize($methodName, $classAst, [DecoratingCommentsRegistry]::Get())
    }

    ClassMethodHelpInfo(
        [string]$methodName,
        [TypeDefinitionAst]$classAst,
        [DecoratingCommentsRegistry]$registry
    ) {
        $this.Initialize($methodName, $classAst, $registry)
    }

    hidden [void] Initialize(
        [string]$methodName,
        [TypeDefinitionAst]$classAst,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        $AstInfo = Get-AstInfo -TargetAst $classAst -Regisistry $registry -ParseDecoratingComment

        $this.Initialize($methodName, $AstInfo, $registry)
    }

    hidden [void] Initialize(
        [string]$methodName,
        [AstInfo]$classAstInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($classAstInfo.Ast -isnot [TypeDefinitionAst]) {
            $Message = @(
                'Invalid argument. [ClassMethodHelpInfo] expects an AstInfo object where'
                'the Ast property is a TypeDefinitionAst that defines a class,'
                "but the Ast property's type was $($classAstInfo.Ast.GetType().FullName)"
            ) -join ' '
            throw [System.ArgumentException]::new($Message, 'classAstInfo')
        }
        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        $ClassHelp = $classAstInfo.DecoratingComment.ParsedValue
        $this.Name = $methodName

        # Find the synopsis in the class's decorating comment block first
        if ($MethodSynopsis = $ClassHelp.GetKeywordEntry('Method', [regex]"$methodName(\(\))?")) {
            $this.Synopsis = $MethodSynopsis
        }

        $this.Overloads = [MethodOverloadHelpInfo]::Resolve($methodName, $classAstInfo, $registry)

        # If the synopsis is still empty, use the first overload's synopsis if posible
        if ([string]::IsNullOrEmpty($this.Synopsis)) {
            $OverloadSynopsis = $this.Overloads.Synopsis |
                Where-Object -FilterScript { -not [string]::IsNullOrEmpty($_) } |
                Select-Object -First 1
            if ($OverloadSynopsis) {
                $this.Synopsis = $OverloadSynopsis
            } else {
                $this.Synopsis = ''
            }
        }

        # Give every overload the method's synopsis if they don't define their own.
        foreach ($Overload in $this.Overloads) {
            if ([string]::IsNullOrEmpty($Overload.Synopsis)) {
                $Overload.Synopsis = $this.Synopsis
            }
        }
    }

    static [ClassMethodHelpInfo[]] Resolve(
        [AstInfo]$classAstInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($classAstInfo.Ast -isnot [TypeDefinitionAst]) {
            $Message = @(
                'Invalid argument. [ClassMethodHelpInfo]::Resolve()'
                'expects an AstInfo object where the Ast property is a TypeDefinitionAst'
                "that defines a class, but the Ast property's type was"
                $classAstInfo.Ast.GetType().FullName
            ) -join ' '
            throw [System.ArgumentException]::new($Message, 'astInfo')
        }

        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        [TypeDefinitionAst]$ClassAst = $classAstInfo.Ast

        return $ClassAst.Members |
            Where-Object -FilterScript {
                $_.GetType().Name -eq 'FunctionMemberAst' -and -not $_.IsConstructor
            } |
            Select-Object -ExpandProperty Name -Unique |
            ForEach-Object -Process {
                [ClassMethodHelpInfo]::new($_, $classAstInfo, $registry)
            }
    }

    hidden static [OrderedDictionary] AddYamlFormatting([OrderedDictionary]$metadata) {
        $metadata.Name     = $metadata.Name     | yayaml\Add-YamlFormat -ScalarStyle Plain  -PassThru
        $metadata.Synopsis = $metadata.Synopsis | yayaml\Add-YamlFormat -ScalarStyle Folded -PassThru

        return $metadata
    }

    static [HelpInfoFormatterDictionary] $Formatters

    static [Void] InitializeFormatters() {
        [ClassMethodHelpInfo]::InitializeFormatters($false, $false)
    }

    static [HelpInfoFormatterDictionary] InitializeFormatters([bool]$passThru, [bool]$force) {
        if ($force -or [ClassMethodHelpInfo]::Formatters.Count -eq 0) {
            [ClassMethodHelpInfo]::Formatters = [HelpInfoFormatterDictionary]::new(
                [ordered]@{
                    Block = [ClassMethodHelpInfo]::GetDefaultFormatter()
                },
                [ordered]@{
                    Block = [ClassMethodHelpInfo]::GetDefaultSectionFormatter()
                }
            )
        }

        if ($passThru) {
            return [ClassMethodHelpInfo]::Formatters
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
                    [ClassMethodHelpInfo]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [ValidateRange(1, 3)]
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
                | Add-Heading -Level $Level -Content $HelpInfo.Name
                | Add-Line -Content $HelpInfo.Synopsis
                | Add-Line -Content ''

                $formatter = [MethodOverloadHelpInfo]::Formatters.Section.Block
                $formatter.Parameters.Level = $Level + 1

                $MarkdownBuilder
                | Add-Line -Content (
                    [MethodOverloadHelpInfo]::ToMarkdown(
                        $HelpInfo.Overloads,
                        $formatter
                    ).TrimEnd()
                )

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
                    [ClassMethodHelpInfo[]]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [string]
                    $Prefix,

                    [ValidateRange(1, 4)]
                    [int]
                    $Level = 2,

                    [string]
                    $HeadingText = 'Methods'
                )

                if ($null -eq $MarkdownBuilder) {
                    $options = @{
                        SpaceMungingOptions = 'CollapseEnd', 'TrimStart'
                    }
                    $MarkdownBuilder = Documentarian.MarkdownBuilder\New-Builder @options
                }

                $MarkdownBuilder | Add-Heading -Level $Level -Content $HeadingText

                foreach ($method in $HelpInfo) {
                    $formatter = [ClassMethodHelpInfo]::Formatters.Block
                    $formatter.Parameters.Level = $Level + 1
                    $formatted = $method.ToMarkdown($formatter)

                    $MarkdownBuilder | Add-Line -Content $formatted
                }

                return ($MarkdownBuilder.ToString() -replace '(\r?\n)+$', '$1')
            }
        }
    }

    [string] ToMarkdown() {
        return $this.ToMarkdown([ClassMethodHelpInfo]::Formatters.Default)
    }

    [string] ToMarkdown([HelpInfoFormatter]$formatter) {
        return $formatter.Format($this)
    }

    static [string] ToMarkdown([ClassMethodHelpInfo[]]$values) {
        return [ClassMethodHelpInfo]::ToMarkdown($values, [ClassMethodHelpInfo]::Formatters.Section.Default)
    }

    static [string] ToMarkdown([ClassMethodHelpInfo[]]$values, [HelpInfoFormatter]$formatter) {
        return $formatter.FormatSection($values)
    }
}
