# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1

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

class AttributeHelpInfo {
    # The attribute's full type name.
    [string] $Type
    # The definition of the attribute as applied in the source code.
    [string] $Definition

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

        $Metadata.Add('Type', $this.Type.Trim())
        $Metadata.Add('Definition', $this.Definition.Trim())

        return $Metadata
    }

    AttributeHelpInfo() {}

    AttributeHelpInfo([AttributeAst]$attributeAst) {
        $this.Initialize($attributeAst)
    }

    hidden Initialize([AttributeAst]$attributeAst) {
        $this.Type = Resolve-TypeName $attributeAst.TypeName
        $this.Definition = $attributeAst.Extent.Text
    }

    static [AttributeHelpInfo[]] Resolve([AttributeAst[]]$attributeAsts) {
        return $attributeAsts | ForEach-Object -Process {
            [AttributeHelpInfo]::new($_)
        }
    }

    static [AttributeHelpInfo[]] Resolve([AstInfo]$astInfo) {
        if ($astInfo.Ast.Attributes.Count -gt 0) {
            return $astInfo.Ast.Attributes | ForEach-Object -Process {
                $AttributeAst = $_ -as [AttributeAst]
                [AttributeHelpInfo]::new($AttributeAst)
            }
        }

        return @()
    }
}
