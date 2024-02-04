# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsBlockParsed.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
using module ./AttributeHelpInfo.psm1
using module ./BaseHelpInfo.psm1

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

class ClassPropertyHelpInfo : BaseHelpInfo {
    # The name of the defined property.
    [string] $Name
    # The full type name of the property.
    [string] $Type
    # The list of attributes applied to the property.
    [AttributeHelpInfo[]] $Attributes = @()
    <#
        The value an instance of the class has for this property unless
        overridden by a constructor or user.
    #>
    [AllowNull()][string] $InitialValue
    # Indicates whether the property is hidden from IntelliSense.
    [bool] $IsHidden = $false
    <#
        Indicates whether the property is available on the class instead of an
        instance of the class.
    #>
    [bool] $IsStatic = $false
    # A short description of the property.
    [string] $Synopsis = ''
    # A longer description of the property with full details.
    [string] $Description = ''

    ClassPropertyHelpInfo() {}

    ClassPropertyHelpInfo([OrderedDictionary]$metadata) : base($metadata) {}

    ClassPropertyHelpInfo([AstInfo]$propertyAstInfo) {
        $this.Initialize(
            $propertyAstInfo,
            [DecoratingCommentsBlockParsed]::new()
        )
    }

    ClassPropertyHelpInfo([AstInfo]$propertyAstInfo, [DecoratingCommentsBlockParsed]$classHelp) {
        $this.Initialize($propertyAstInfo, $classHelp)
    }

    static ClassPropertyHelpInfo(){
        [ClassPropertyHelpInfo]::InitializeFormatters()
    }

    hidden [void] Initialize([AstInfo]$astInfo, [DecoratingCommentsBlockParsed]$classHelp) {
        [PropertyMemberAst]$PropertyAst = [ClassPropertyHelpInfo]::GetValidatedAst($astInfo)

        $PropertyName    = $PropertyAst.Name.Trim()
        $this.Name       = $PropertyName
        $this.Type       = Resolve-TypeName -TypeName $PropertyAst.PropertyType.TypeName
        $this.Attributes = [AttributeHelpInfo]::Resolve($astInfo)
        $this.IsHidden   = $PropertyAst.IsHidden
        $this.IsStatic   = $PropertyAst.IsStatic
        if ($null -ne $PropertyAst.InitialValue) {
            $this.InitialValue = $PropertyAst.InitialValue.Extent.Text
        }
        $PropertyHelp = $astInfo.DecoratingComment.ParsedValue
        if ($PropertyHelp.IsUsable()) {
            # First try to set the property's help from it's own parsed decorating comment block.
            if ($HelpSynopsis = $PropertyHelp.GetKeywordEntry('Synopsis')) {
                $this.Synopsis = $HelpSynopsis
            }
            if ($HelpDescription = $PropertyHelp.GetKeywordEntry('Description')) {
                $this.Description = $HelpDescription
            }
        } elseif ($CommentHelp = $astInfo.DecoratingComment.MungedValue) {
            # If the decorating comment block couldn't be parsed, use the decorating
            # comment as the synopsis
            $this.Synopsis = $CommentHelp
        }
        if ($ClassPropertyHelp = $classHelp.GetKeywordEntry('Property', $PropertyName)) {
            if ([string]::IsNullOrEmpty($this.Synopsis)) {
                $this.Synopsis = $ClassPropertyHelp
            } elseif ([string]::IsNullOrEmpty($this.Description)) {
                $this.Description = $ClassPropertyHelp
            }
        }
    }

    hidden static [PropertyMemberAst] GetValidatedAst([AstInfo]$astInfo) {
        [PropertyMemberAst]$TargetAst = $astInfo.Ast -as [PropertyMemberAst]

        if ($null -eq $TargetAst) {
            $Message = @(
                'Invalid AstInfo for ClassPropertyHelpInfo.'
                'Expected the Ast property to be a PropertyMemberAst whose parent AST is a class,'
                "but the AST object's type was $($astInfo.Ast.GetType().FullName)."
            ) -join ' '
            throw $Message
        } elseif (-not $TargetAst.Parent.IsClass) {
            $Message = @(
                'Invalid AstInfo for ClassPropertyHelpInfo.'
                'Expected the Ast property to be a PropertyMemberAst whose parent AST is a class,'
                "but the parent AST is the $($TargetAst.Parent.Name) enum."
            ) -join ' '
            throw $Message
        }

        return $TargetAst
    }

    static [ClassPropertyHelpInfo[]] Resolve(
        [AstInfo]$classAstInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($classAstInfo.Ast -isnot [TypeDefinitionAst]) {
            $Message = @(
                'Invalid argument. [ClassPropertyHelpInfo]::Resolve()'
                'expects an AstInfo object where the Ast property is a TypeDefinitionAst'
                "that defines a class, but the Ast property's type was"
                $classAstInfo.Ast.GetType().FullName
            ) -join ' '
            throw [System.ArgumentException]::new($Message, 'classAstInfo')
        }

        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        [TypeDefinitionAst]$ClassAst = $classAstInfo.Ast
        $Help = $classAstInfo.DecoratingComment.ParsedValue

        return $ClassAst.Members | Where-Object -FilterScript {
            $_ -is [PropertyMemberAst]
        } | ForEach-Object -Process {
            $GetParameters = @{
                TargetAst              = $_
                Token                  = $classAstInfo.Tokens
                Registry               = $registry
                ParseDecoratingComment = $true
            }
            $PropertyAstInfo = Get-AstInfo @GetParameters
            if ($Help.IsUsable()) {
                [ClassPropertyHelpInfo]::new($PropertyAstInfo, $Help)
            } else {
                [ClassPropertyHelpInfo]::new($PropertyAstInfo)
            }
        }
    }

    hidden static [OrderedDictionary] AddYamlFormatting([OrderedDictionary]$metadata) {
        $metadata.Name        = $metadata.Name        | yayaml\Add-YamlFormat -ScalarStyle Plain   -PassThru
        $metadata.Type        = $metadata.Type        | yayaml\Add-YamlFormat -ScalarStyle Plain   -PassThru
        $metadata.Synopsis    = $metadata.Synopsis    | yayaml\Add-YamlFormat -ScalarStyle Folded  -PassThru
        $metadata.Description = $metadata.Description | yayaml\Add-YamlFormat -ScalarStyle Literal -PassThru

        return $metadata
    }

    static [HelpInfoFormatterDictionary] $Formatters

    static InitializeFormatters() {
        [ClassPropertyHelpInfo]::InitializeFormatters($false, $false)
    }

    static [HelpInfoFormatterDictionary] InitializeFormatters([bool]$passThru, [bool]$force) {
        if ($force -or [ClassPropertyHelpInfo]::Formatters.Count -eq 0) {
            [ClassPropertyHelpInfo]::Formatters = [HelpInfoFormatterDictionary]::new(
                [ordered]@{
                    Block = [ClassPropertyHelpInfo]::GetDefaultFormatter()
                },
                [ordered]@{
                    Block = [ClassPropertyHelpInfo]::GetDefaultSectionFormatter()
                }
            )
        }

        if ($passThru) {
            return [ClassPropertyHelpInfo]::Formatters
        }

        return $null
    }

    static [HelpInfoFormatter] GetDefaultFormatter() {
        return [HelpInfoFormatter]@{
            Parameters  = @{}
            ScriptBlock = {
                [cmdletbinding()]
                [OutputType([string])]
                param(
                    [Parameter(Mandatory)]
                    [ClassPropertyHelpInfo]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [ValidateRange(1, 6)]
                    [int]
                    $Level = 3,

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

                $classLine = "[$($HelpInfo.Type)] `$$($HelpInfo.Name)"
                if ($HelpInfo.IsStatic) {
                    $classLine = "static $classLine"
                }
                if ($HelpInfo.IsHidden) {
                    $classLine = "hidden $classLine"
                }
                if ($HelpInfo.InitialValue) {
                    $classLine = "$classLine = $($HelpInfo.InitialValue)"
                }

                $MarkdownBuilder
                | Add-Heading -Level $Level -Content $HelpInfo.Name
                | Add-Line -Content $HelpInfo.Synopsis
                | Add-Line -Content ''
                | Add-Heading -Level ($Level + 1) -Content 'Definition'
                | Start-CodeFence -Language 'powershell'

                foreach ($attribute in $HelpInfo.Attributes) {
                    $MarkdownBuilder | Add-Line -Content $attribute.Definition
                }

                foreach ($line in ($classLine -split '\r?\n')) {
                    $MarkdownBuilder | Add-Line -Content $line
                }

                $MarkdownBuilder
                | Stop-CodeFence
                | Add-Heading -Level ($Level + 1) -Content 'Description'

                foreach ($line in ($HelpInfo.Description -split '\r?\n')) {
                    $MarkdownBuilder | Add-Line -Content $line
                }

                $MarkdownBuilder.ToString()
            }
        }
    }

    static [HelpInfoFormatter] GetCompressedBlockFormatter() {
        return [HelpInfoFormatter]@{
            Parameters  = @{}
            ScriptBlock = {
                [cmdletbinding()]
                [OutputType([string])]
                param(
                    [Parameter(Mandatory)]
                    [ClassPropertyHelpInfo]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [ValidateRange(1, 6)]
                    [int]
                    $Level = 3,

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

                $classLine = "[$($HelpInfo.Type)] `$$($HelpInfo.Name)"
                if ($HelpInfo.IsStatic) {
                    $classLine = "static $classLine"
                }
                if ($HelpInfo.IsHidden) {
                    $classLine = "hidden $classLine"
                }
                if ($HelpInfo.InitialValue) {
                    $classLine = "$classLine = $($HelpInfo.InitialValue)"
                }

                $MarkdownBuilder
                | Add-Heading -Level $Level -Content $HelpInfo.Name
                | Start-CodeFence -Language 'powershell'

                foreach ($attribute in $HelpInfo.Attributes) {
                    $MarkdownBuilder | Add-Line -Content $attribute.Definition
                }

                foreach ($line in ($classLine -split '\r?\n')) {
                    $MarkdownBuilder | Add-Line -Content $line
                }

                $MarkdownBuilder | Stop-CodeFence

                foreach ($line in ($HelpInfo.Description -split '\r?\n')) {
                    $MarkdownBuilder | Add-Line -Content $line
                }

                $MarkdownBuilder.ToString()
            }
        }
    }

    static [HelpInfoFormatter] GetDefaultSectionFormatter() {
        return [HelpInfoFormatter]@{
            Parameters = @{}
            ScriptBlock = {
                [cmdletbinding()]
                [OutputType([string])]
                param(
                    [Parameter(Mandatory)]
                    [ClassPropertyHelpInfo[]]
                    $HelpInfo,

                    [MarkdownBuilder]
                    $MarkdownBuilder,

                    [ValidateRange(1, 6)]
                    [int]
                    $Level = 2
                )

                if ($null -eq $MarkdownBuilder) {
                    $options = @{
                        SpaceMungingOptions = 'CollapseEnd', 'TrimStart'
                    }
                    $MarkdownBuilder = Documentarian.MarkdownBuilder\New-Builder @options
                }

                $MarkdownBuilder | Add-Heading -Level $Level -Content 'Properties'

                foreach ($property in $HelpInfo) {
                    $formatter = [ClassPropertyHelpInfo]::Formatters.Default
                    $formatter.Parameters.Level = $Level + 1

                    $MarkdownBuilder | Add-Line -Content $property.ToMarkdown($formatter)
                }

                $MarkdownBuilder.ToString()
            }
        }
    }

    [string] ToMarkdown() {
        return $this.ToMarkdown([ClassPropertyHelpInfo]::Formatters.Default)
    }

    [string] ToMarkdown([HelpInfoFormatter]$formatter) {
        return $formatter.Format($this)
    }

    static [string] ToMarkdown([ClassPropertyHelpInfo[]]$properties) {
        return [ClassPropertyHelpInfo]::ToMarkdown($properties, [ClassPropertyHelpInfo]::Formatters.Section.Default)
    }

    static [string] ToMarkdown([ClassPropertyHelpInfo[]]$properties, [HelpInfoFormatter]$formatter) {
        return $formatter.FormatSection($properties)
    }
}
