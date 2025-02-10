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

    <#
        A list of the parameter types for the overload. This is the same as the
        **TypeOnly** property, but as a list instead of a string.
    #>
    [string[]] $ParameterTypes = @()

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

    [string] ToCodeBlock() {
        <#
            .SYNOPSIS
            Returns a string representing the full signature as a code block.

            .DESCRIPTION
            Returns a string representing the full signature as a code block. If the length of the
            signature is 76 characters or longer, the method formats the signature as a multiline
            code block, with each parameter on its own line. If the length of the signature is less
            than 76 characters, the method formats the signature as a single-line code block.
        #>

        $multiline = $this.Full.Length -ge 76

        return $this.ToCodeBlock($multiline)
    }

    [string] ToCodeBlock([bool]$multiline) {
        <#
            .SYNOPSIS
            Returns a string representing the full signature as a code block.

            .DESCRIPTION
            Returns a string representing the full signature as a code block. The value of the
            `$multiline` parameter determines whether the signature is formatted as a single-line
            code block or a multiline code block. For a multiline code block, each parameter is
            placed on its own line.

            .PARAMETER multiline
            Determines whether the signature is formatted as a single-line code block or a multiline
            code block.
        #>
        $output = $this.Full

        if ($Multiline) {
            $output = $output -replace '\(', "(`n$(([string]::Empty).PadRight(4))"
            $output = $output -replace ', ', ",`n$(([string]::Empty).PadRight(4))"
            $output = $output -replace '\)', "`n)"
        }

        $output = '```powershell' + "`n" + $output + "`n" + '```'

        return $output
    }

    OverloadSignature() {}

    OverloadSignature([OrderedDictionary]$metadata) : base($metadata) {}

    OverloadSignature([FunctionMemberAst]$overloadAst) {
        $this.Initialize($overloadAst)
    }

    OverloadSignature([AstInfo]$overloadAstInfo) {
        $this.Initialize($overloadAstInfo.Ast)
    }

    hidden [void] Initialize([FunctionMemberAst]$overloadAst) {
        $this.Full           = [OverloadSignature]::GetFullSignature($overloadAst)
        $this.TypeOnly       = [OverloadSignature]::GetTypeOnlySignature($overloadAst)
        $this.ParameterTypes = [OverloadSignature]::GetParameterTypes($overloadAst)
    }

    static [string[]] GetParameterTypes([FunctionMemberAst]$overloadAst) {
        return $overloadAst.Parameters | ForEach-Object -Process {
            $type = $_.StaticType.FullName

            # For custom types the parser doesn't know about, they're listed as an
            # attribute instead. We should use that as the type name if available.
            if ($type -eq 'System.Object' -and $_.Attributes.Count -gt 0) {
                $type = Resolve-TypeName -TypeName $_.Attributes[0].TypeName
            }

            $type
        }
    }

    static [string] GetTypeOnlySignature([FunctionMemberAst]$overloadAst) {
        $name       = $overloadAst.Name
        $parameters = [OverloadSignature]::GetParameterTypes($overloadAst) -join ', '

        return "$name($parameters)"
    }

    static [string] GetTypeOnlySignature([AstInfo]$overloadAstInfo) {
        return [OverloadSignature]::GetTypeOnlySignature($overloadAstInfo.Ast)
    }

    static [string] GetFullSignature([FunctionMemberAst]$overloadAst) {
        $name       = $overloadAst.Name
        $parameters = $overloadAst.Parameters.Extent.Text -join ', '

        return "$name($parameters)"
    }

    static [string] GetFullSignature([AstInfo]$overloadAstInfo) {
        return [OverloadSignature]::GetFullSignature($overloadAstInfo)
    }

    hidden static [OrderedDictionary] AddYamlFormatting([OrderedDictionary]$metadata) {
        $metadata.Full     = $metadata.Full     | yayaml\Add-YamlFormat -ScalarStyle Literal -PassThru
        $metadata.TypeOnly = $metadata.TypeOnly | yayaml\Add-YamlFormat -ScalarStyle Folded  -PassThru

        return $metadata
    }
}
