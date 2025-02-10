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
    Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Find-Ast.ps1"
    Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Resolve-TypeName.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
    . $RequiredFunction
}

#endregion RequiredFunctions

class OverloadParameterHelpInfo : BaseHelpInfo {
    # The name of the parameter.
    [string] $Name
    # The full type name of the parameter.
    [string] $Type
    # A description of the parameter's purpose and usage.
    [string] $Description = ''

    static OverloadParameterHelpInfo() {
        [OverloadParameterHelpInfo]::InitializeFormatters()
    }

    OverloadParameterHelpInfo() {}

    OverloadParameterHelpInfo([OrderedDictionary]$metadata) : base($metadata) {}

    OverloadParameterHelpInfo([AstInfo]$parameterAstInfo) {
        $this.Initialize(
            $parameterAstInfo,
            [DecoratingCommentsBlockParsed]::new()
        )
    }

    OverloadParameterHelpInfo(
        [AstInfo]$parameterAstInfo,
        [DecoratingCommentsBlockParsed]$overloadHelp
    ) {
        $this.Initialize($parameterAstInfo, $overloadHelp)
    }

    OverloadParameterHelpInfo([ParameterAst]$parameterAst) {
        $this.Initialize(
            $parameterAst,
            [DecoratingCommentsBlockParsed]::new()
        )
    }

    OverloadParameterHelpInfo(
        [ParameterAst]$parameterAst,
        [DecoratingCommentsBlockParsed]$overloadHelp
    ) {
        $this.Initialize($parameterAst, $overloadHelp)
    }

    hidden [void] Initialize(
        [AstInfo]$parameterAstInfo,
        [DecoratingCommentsBlockParsed]$overloadHelp
    ) {
        [ParameterAst]$ParameterAst = [OverloadParameterHelpInfo]::GetValidatedAst(
            $parameterAstInfo
        )
        $ParameterName = $ParameterAst.Name.VariablePath.ToString()
        $ParameterType = $ParameterAst.StaticType.FullName
        $this.Name     = $ParameterName
        # For custom types the parser doesn't know about, they're listed as
        # an attribute instead. We should use that as the type name if
        # available.
        if ($ParameterType -eq 'System.Object' -and $ParameterAst.Attributes.Count -gt 0) {
            $this.Type = Resolve-TypeName -TypeName $ParameterAst.Attributes[0].TypeName
        } else {
            $this.Type = $ParameterType
        }

        $ParameterHelp = $overloadHelp.GetKeywordEntry('Parameter', $ParameterName)

        if ($null -ne $ParameterHelp -and ![string]::IsNullOrEmpty($ParameterHelp)) {
            $this.Description = $ParameterHelp
        } elseif ($ParameterComment = $parameterAstInfo.DecoratingComment.MungedValue) {
            $ParentString       = $ParameterAst.Parent.Extent.ToString()
            $ParameterString    = $ParameterAst.Extent.ToString()
            $ParameterOnNewLine = $ParentString -match "\r?\n\s*$([regex]::Escape($ParameterString))"
            if ($ParameterOnNewLine) {
                $this.Description = $ParameterComment
            }
        } else {
            $this.Description = ''
        }
    }

    hidden [void] Initialize(
        [ParameterAst]$parameterAst,
        [DecoratingCommentsBlockParsed]$overloadHelp
    ) {
        $ParameterName = $parameterAst.Name.VariablePath.ToString()
        $ParameterType = $parameterAst.StaticType.FullName
        $this.Name     = $ParameterName
        # For custom types the parser doesn't know about, they're listed as
        # an attribute instead. We should use that as the type name if
        # available.
        if ($ParameterType -eq 'System.Object' -and $parameterAst.Attributes.Count -gt 0) {
            $this.Type = Resolve-TypeName -TypeName $parameterAst.Attributes[0].TypeName
        } else {
            $this.Type = $ParameterType
        }

        if ($ParameterHelp = $overloadHelp.GetKeywordEntry('Parameter', $ParameterName)) {
            $this.Description = $ParameterHelp
        } else {
            $this.Description = ''
        }
    }

    hidden static [ParameterAst] GetValidatedAst([AstInfo]$astInfo) {
        [ParameterAst]$TargetAst = $astInfo.Ast -as [ParameterAst]

        if ($null -eq $TargetAst) {
            $Message = @(
                'Invalid AstInfo for OverloadParameterHelpInfo.'
                'Expected the Ast property to be a ParameterAst whose parent AST is an overload,'
                "but the AST object's type was $($astInfo.Ast.GetType().FullName)."
            ) -join ' '
            throw $Message
        }

        return $TargetAst
    }

    static [OverloadParameterHelpInfo[]] Resolve(
        [AstInfo]$overloadAstInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($overloadAstInfo.Ast -isnot [FunctionMemberAst]) {
            $Message = @(
                'The [OverloadParameterHelpInfo]::Resolve() method expects an AstInfo object'
                'where the Ast property is a FunctionMemberAst,'
                'but received an AstInfo object with an Ast type of'
                $overloadAstInfo.Ast.GetType().FullName
            ) -join ' '
            throw $Message
        }

        if ($overloadAstInfo.Ast.Parameters.Count -eq 0) {
            return @()
        }
        $OverloadHelp = $overloadAstInfo.DecoratingComment.ParsedValue

        $ParameterInfo = [OverloadParameterHelpInfo]::GetParametersAstInfo(
            $overloadAstInfo,
            $registry
        )

        if ($ParameterInfo.Count -eq 0) {
            return @()
        }

        return $ParameterInfo | ForEach-Object -Process {
            if ($OverloadHelp.IsUsable()) {
                [OverloadParameterHelpInfo]::new($_, $OverloadHelp)
            } else {
                [OverloadParameterHelpInfo]::new($_)
            }
        }
    }

    hidden static [AstInfo[]] GetParametersAstInfo(
        [AstInfo]$overloadAstInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        $FindValueParameters = @{
            AstInfo                = $overloadAstInfo
            Type                   = 'ParameterAst'
            AsAstInfo              = $true
            Registry               = $registry
            ParseDecoratingComment = $true
            Recurse                = $true
        }
        return (Find-Ast @FindValueParameters)
    }

    hidden static [OrderedDictionary] AddYamlFormatting([OrderedDictionary]$metadata) {
        $metadata.Name        = $metadata.Name        | yayaml\Add-YamlFormat -ScalarStyle Plain   -PassThru
        $metadata.Type        = $metadata.Type        | yayaml\Add-YamlFormat -ScalarStyle Plain   -PassThru
        $metadata.Description = $metadata.Description | yayaml\Add-YamlFormat -ScalarStyle Literal -PassThru

        return $metadata
    }

    static [HelpInfoFormatterDictionary] $Formatters

    static InitializeFormatters() {
        [OverloadParameterHelpInfo]::InitializeFormatters($false, $false)
    }

    static [HelpInfoFormatterDictionary] InitializeFormatters([bool]$passThru, [bool]$force) {
        if ($force -or [OverloadParameterHelpInfo]::Formatters.Count -eq 0) {
            [OverloadParameterHelpInfo]::Formatters = [HelpInfoFormatterDictionary]::new(
                [ordered]@{
                    Block    = [OverloadParameterHelpInfo]::GetDefaultFormatter()
                    ListItem = [OverloadParameterHelpInfo]::GetListItemFormatter()
                },
                [ordered]@{
                    Block = [OverloadParameterHelpInfo]::GetDefaultSectionFormatter()
                    List  = [OverloadParameterHelpInfo]::GetListSectionFormatter()
                }
            )
        }

        if ($passThru) {
            return [OverloadParameterHelpInfo]::Formatters
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
                    [OverloadParameterHelpInfo]
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

                $Title = '{0} ({1})' -f $HelpInfo.Name, $HelpInfo.Type

                $MarkdownBuilder | Add-Heading -Level $Level -Content $Title

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
                    [OverloadParameterHelpInfo]
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

                $Title = '`${0}` (**{1}**)' -f $HelpInfo.Name, $HelpInfo.Type

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
                    [OverloadParameterHelpInfo[]]
                    $HelpInfo,

                    [string]
                    $Prefix,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [ValidateRange(1, 5)]
                    [int]
                    $Level = 3
                )

                if ($null -eq $MarkdownBuilder) {
                    $options = @{
                        SpaceMungingOptions = 'CollapseEnd', 'TrimStart'
                    }
                    $MarkdownBuilder = Documentarian.MarkdownBuilder\New-Builder @options
                }

                $MarkdownBuilder | Add-Heading -Level $Level -Content 'Parameters'

                foreach ($param in $HelpInfo) {
                    $formatter = [OverloadParameterHelpInfo]::Formatters.Block
                    $formatter.Parameters.Level = $Level + 1

                    $MarkdownBuilder | Add-Line -Content $param.ToMarkdown($formatter)
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
                    [OverloadParameterHelpInfo[]]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [string]
                    $Prefix,

                    [ValidateRange(1, 6)]
                    [int]
                    $Level = 5,

                    [string]
                    $HeadingText = 'Parameters'
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
                    $formatter = [OverloadParameterHelpInfo]::Formatters.ListItem
                    $formatted = $param.ToMarkdown($formatter)

                    $MarkdownBuilder | Add-ListItem -ListItem $formatted
                }

                $MarkdownBuilder.EndList().ToString()
            }
        }
    }

    [string] ToMarkdown() {
        return $this.ToMarkdown([OverloadParameterHelpInfo]::Formatters.Default)
    }

    [string] ToMarkdown([HelpInfoFormatter]$formatter) {
        return $formatter.Format($this)
    }

    static [string] ToMarkdown([OverloadParameterHelpInfo[]]$values) {
        return [OverloadParameterHelpInfo]::ToMarkdown($values, [OverloadParameterHelpInfo]::Formatters.Section.Default)
    }

    static [string] ToMarkdown([OverloadParameterHelpInfo[]]$values, [HelpInfoFormatter]$formatter) {
        return $formatter.FormatSection($values)
    }
}
