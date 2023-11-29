# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
using module ./BaseHelpInfo.psm1
using module ./AttributeHelpInfo.psm1

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
    ClassPropertyHelpInfo([OrderedDictionary]$metadata) : base($metadata) {
    }
    ClassPropertyHelpInfo([AstInfo]$propertyAstInfo) {
        $this.Initialize(
            $propertyAstInfo,
            [DecoratingCommentsBlockParsed]::new()
        )
    }
    ClassPropertyHelpInfo([AstInfo]$propertyAstInfo, [DecoratingCommentsBlockParsed]$classHelp) {
        $this.Initialize($propertyAstInfo, $classHelp)
    }

    hidden [void] Initialize([AstInfo]$astInfo, [DecoratingCommentsBlockParsed]$classHelp) {
        [PropertyMemberAst]$PropertyAst = [ClassPropertyHelpInfo]::GetValidatedAst($astInfo)

        $PropertyName = $PropertyAst.Name.Trim()
        $this.Name = $PropertyName
        $this.Type = Resolve-TypeName -TypeName $PropertyAst.PropertyType.TypeName
        $this.Attributes = [AttributeHelpInfo]::Resolve($astInfo)
        $this.IsHidden = $PropertyAst.IsHidden
        $this.IsStatic = $PropertyAst.IsStatic
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
                "expects an AstInfo object where the Ast property is a TypeDefinitionAst"
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
        $metadata.Name = $metadata.Name | yayaml\Add-YamlFormat -ScalarStyle Plain -PassThru
        $metadata.Type = $metadata.Type | yayaml\Add-YamlFormat -ScalarStyle Plain -PassThru
        $metadata.Synopsis = $metadata.Synopsis | yayaml\Add-YamlFormat -ScalarStyle Folded -PassThru
        $metadata.Description = $metadata.Description | yayaml\Add-YamlFormat -ScalarStyle Literal -PassThru

        return $metadata
    }
}
