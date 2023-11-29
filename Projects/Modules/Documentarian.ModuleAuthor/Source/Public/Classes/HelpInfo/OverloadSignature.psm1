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

class OverloadSignature : BaseHelpInfo {
    <#
        The full signature for the overload, including the type and name of
        every parameter.
    #>
    [string] $Full
    <#
        The short signature for the overload, including only the type names for
        every parameter.
    #>
    [string] $TypeOnly

    [string] ToString() {
        <#
            .SYNOPSIS
            Returns a string representing the full signature.

            .DESCRIPTION
            Returns a string representing the full signature. This is a
            convenience method instead of requiring you to access the **Full**
            property directly.

            This method is automatically called when an **OverloadSignature**
            is interpolated into a string.
        #>
        return $this.Full
    }

    OverloadSignature() {}
    
    OverloadSignature([FunctionMemberAst]$overloadAst) {
        $this.Initialize($overloadAst)
    }
    
    OverloadSignature([AstInfo]$overloadAstInfo) {
        $this.Initialize($overloadAstInfo.Ast)
    }

    hidden [void] Initialize([FunctionMemberAst]$overloadAst) {
        $this.Full = [OverloadSignature]::GetFullSignature($overloadAst)
        $this.TypeOnly = [OverloadSignature]::GetTypeOnlySignature($overloadAst)
    }

    static [string] GetTypeOnlySignature([FunctionMemberAst]$overloadAst) {
        $Name = $overloadAst.Name
        $ParameterTypes = $overloadAst.Parameters | ForEach-Object -Process {
            $Type = $_.StaticType.FullName

            # For custom types the parser doesn't know about, they're listed as an
            # attribute instead. We should use that as the type name if available.
            if ($Type -eq 'System.Object' -and $_.Attributes.Count -gt 0) {
                $Type = Resolve-TypeName -TypeName $_.Attributes[0].TypeName
            }

            $Type
        }
        $Parameters = $ParameterTypes -join ', '

        return "$Name($Parameters)"
    }
    
    static [string] GetTypeOnlySignature([AstInfo]$overloadAstInfo) {
        return [OverloadSignature]::GetTypeOnlySignature($overloadAstInfo.Ast)
    }
    
    static [string] GetFullSignature([FunctionMemberAst]$overloadAst) {
        $Name = $overloadAst.Name
        $Parameters = $overloadAst.Parameters.Extent.Text -join ', '
        return "$Name($Parameters)"
    }
    
    static [string] GetFullSignature([AstInfo]$overloadAstInfo) {
        return [OverloadSignature]::GetFullSignature($overloadAstInfo)
    }

    hidden static [OrderedDictionary] AddYamlFormatting([OrderedDictionary]$metadata) {
        $metadata.Full = $metadata.Full | yayaml\Add-YamlFormat -ScalarStyle Literal -PassThru
        $metadata.TypeOnly = $metadata.TypeOnly | yayaml\Add-YamlFormat -ScalarStyle Folded -PassThru

        return $metadata
    }
}
