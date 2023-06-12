# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
using module ./AttributeHelpInfo.psm1
using module ./ClassMethodHelpInfo.psm1
using module ./ClassPropertyHelpInfo.psm1
using module ./ConstructorOverloadHelpInfo.psm1
using module ./ExampleHelpInfo.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Resolve-TypeName.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

class ClassHelpInfo {
    # The name of the defined PowerShell class.
    [string] $Name = ''
    # A short description of the class.
    [string] $Synopsis = ''
    # A full description of the class, with details.
    [string] $Description = ''
    # A list of examples showing how you can use the class.
    [ExampleHelpInfo[]] $Examples = @()
    # Additional information about the class.
    [string] $Notes = ''
    # A list of full type names for the classes this class inherits from and
    # the interfaces this class implements.
    [string[]] $BaseTypes = @()
    # A list of attributes applied to the class.
    [AttributeHelpInfo[]] $Attributes = @()
    # A list of constructor overloads for the class with their documentation.
    [ConstructorOverloadHelpInfo[]] $Constructors = @()
    # A list of methods defined by the class with their documentation.
    [ClassMethodHelpInfo[]] $Methods = @()
    # A list of properties defined by the class with their documentation.
    [ClassPropertyHelpInfo[]] $Properties = @()

    # A list of links used in your documentation. Not retrieved from source.
    [OrderedDictionary] $LinkReferences = @{}

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
        if ($this.Examples.Count -gt 0) {
            $Metadata.Add('Examples', [OrderedDictionary[]]($this.Examples.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Examples', [OrderedDictionary[]]@())
        }
        $Metadata.Add('Notes', $this.Notes.Trim())
        if ($this.BaseTypes.Count -gt 0) {
            $Metadata.Add('BaseTypes', [string[]]($this.BaseTypes.Trim()))
        } else {
            $Metadata.Add('BaseTypes', [string[]]@())
        }
        if ($this.Attributes.Count -gt 0) {
            $Metadata.Add('Attributes', [OrderedDictionary[]]($this.Attributes.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Attributes', [OrderedDictionary[]]@())
        }
        if ($this.Constructors.Count -gt 0) {
            $Metadata.Add('Constructors', [OrderedDictionary[]]($this.Constructors.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Constructors', [OrderedDictionary[]]@())
        }
        if ($this.Methods.Count -gt 0) {
            $Metadata.Add('Methods', [OrderedDictionary[]]($this.Methods.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Methods', [OrderedDictionary[]]@())
        }
        if ($this.Properties.Count -gt 0) {
            $Metadata.Add('Properties', [OrderedDictionary[]]($this.Properties.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Properties', [OrderedDictionary[]]@())
        }
        $Metadata.Add('LinkReferences', $this.LinkReferences)

        return $Metadata
    }

    ClassHelpInfo() {}

    ClassHelpInfo([AstInfo]$astInfo) {
        $this.Initialize($astInfo, [DecoratingCommentsRegistry]::Get())
    }

    ClassHelpInfo([AstInfo]$astInfo, [DecoratingCommentsRegistry]$registry) {
        $this.Initialize($astInfo, $registry)
    }

    hidden [void] Initialize([AstInfo]$astInfo, [DecoratingCommentsRegistry]$registry) {
        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        $ClassAst = [ClassHelpInfo]::GetValidatedAst($astInfo)
        $Help = $astInfo.DecoratingComment.ParsedValue

        $this.Name = $ClassAst.Name.Trim()
        $this.BaseTypes = $ClassAst.BaseTypes.ForEach({ Resolve-TypeName -TypeName -$_.TypeName })
        $this.Attributes = [AttributeHelpInfo]::Resolve($astInfo)
        $this.Properties = [ClassPropertyHelpInfo]::Resolve($astInfo, $registry)
        $this.Constructors = [ConstructorOverloadHelpInfo]::Resolve($astInfo, $registry)
        $this.Methods = [ClassMethodHelpInfo]::Resolve($astInfo, $registry)

        if ($null -ne $Help) {
            if ($Help.Synopsis) {
                $this.Synopsis = $Help.Synopsis.Trim()
            }
            if ($Help.Description) {
                $this.Description = $Help.Description.Trim()
            }
            if ($Help.Examples.Count -gt 0) {
                $this.Examples = [ExampleHelpInfo]::Resolve($Help)
            }
            if ($Help.Notes) {
                $this.Notes = $Help.Notes.Trim()
            }
        } elseif ($SynopsisHelp = $astInfo.DecoratingComment.MungedValue) {
            $this.Synopsis = $SynopsisHelp.Trim()
        }
    }

    hidden static [TypeDefinitionAst] GetValidatedAst([AstInfo] $astInfo) {
        $TargetAst = $astInfo.Ast -as [TypeDefinitionAst]

        if ($null -eq $TargetAst) {
            $Message = @(
                'Invalid AstInfo for ClassHelpInfo.'
                'Expected the Ast property to be a TypeDefinitionAst for a class,'
                "but the AST object's type was $($astInfo.Ast.GetType().FullName)."
            ) -join ' '
            throw $Message
        } elseif (-not $TargetAst.IsClass) {
            $Message = @(
                'Invalid AstInfo for ClassHelpInfo.'
                'Expected the Ast property to be a TypeDefinitionAst for a class,'
                "but the AST is for the $($TargetAst.Name) enum."
            ) -join ' '
            throw $Message
        }

        return $TargetAst
    }
}
