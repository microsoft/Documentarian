# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ./BaseHelpInfo.psm1

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

class AttributeHelpInfo : BaseHelpInfo {
    # The attribute's full type name.
    [string] $Type
    # The definition of the attribute as applied in the source code.
    [string] $Definition

    AttributeHelpInfo() {}

    AttributeHelpInfo([OrderedDictionary]$metadata) : base($metadata) {}

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

    hidden static [OrderedDictionary] AddYamlFormatting([OrderedDictionary]$metadata) {
        $metadata.Type       = $metadata.Type       | yayaml\Add-YamlFormat -ScalarStyle Plain   -PassThru
        $metadata.Definition = $metadata.Definition | yayaml\Add-YamlFormat -ScalarStyle Literal -PassThru

        return $metadata
    }
}
