# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
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

class ClassPropertyHelpInfo {
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
    [string] $InitialValue
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

    [OrderedDictionary] ToMetadataDictionary() {
        <#
            .SYNOPSIS
            Converts an instance of the class into a dictionary.

            .DESCRIPTION
            The `ToMetadataDictionary()` method converts an instance of the
            class into an ordered dictionary so you can export the
            documentation metadata into YAML or JSON.

            This makes it easier for you to use the data-docs model, which
            separates the content of the reference documentation from its
            presentation.
        #>

        $Metadata = [OrderedDictionary]::new([System.StringComparer]::OrdinalIgnoreCase)
        $Metadata.Add('Name', $this.Name.Trim())
        $Metadata.Add('Synopsis', $this.Synopsis.Trim())
        $Metadata.Add('Description', $this.Description.Trim())
        $Metadata.Add('Type', $this.Type.Trim())
        if ($this.Attributes.Count -gt 0) {
            $Metadata.Add('Attributes', [OrderedDictionary[]]($this.Attributes.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Attributes', [OrderedDictionary[]]@())
        }
        if ($null -eq $this.InitialValue) {
            $Metadata.Add('InitialValue', $null)
        } else {
            $Metadata.Add('InitialValue', $this.InitialValue)
        }
        $Metadata.Add('IsHidden', $this.IsHidden)
        $Metadata.Add('IsStatic', $this.IsStatic)

        return $Metadata
    }

    ClassPropertyHelpInfo() {}
    ClassPropertyHelpInfo([AstInfo]$propertyAstInfo) {
        $this.Initialize(
            $propertyAstInfo,
            [OrderedDictionary]::new([System.StringComparer]::OrdinalIgnoreCase)
        )
    }
    ClassPropertyHelpInfo([AstInfo]$propertyAstInfo, [OrderedDictionary]$classHelp) {
        $this.Initialize($propertyAstInfo, $classHelp)
    }

    hidden [void] Initialize([AstInfo]$astInfo, [OrderedDictionary]$classHelp) {
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
        if ($null -ne $PropertyHelp) {
            if ($PropertyHelp.Synopsis) {
                $this.Synopsis = $PropertyHelp.Synopsis.Trim()
            }
            if ($PropertyHelp.Description) {
                $this.Description = $PropertyHelp.Description.Trim()
            }
        } elseif ($CommentHelp = $astInfo.DecoratingComment.MungedValue) {
            $this.Synopsis = $CommentHelp
        }
        if ($null -ne $classHelp.Property) {
            $classHelp.Property | Where-Object -FilterScript {
                $_.Value -eq $PropertyName
            } | Select-Object -First 1 -ExpandProperty Content | ForEach-Object -Process {
                if ([string]::IsNullOrEmpty($this.Synopsis)) {
                    $this.Synopsis = $_.Trim()
                } elseif ([string]::IsNullOrEmpty($this.Description)) {
                    $this.Description = $_.Trim()
                }
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
            if ($null -ne $Help) {
                [ClassPropertyHelpInfo]::new($PropertyAstInfo, $Help)
            } else {
                [ClassPropertyHelpInfo]::new($PropertyAstInfo)
            }

        }
    }
}
