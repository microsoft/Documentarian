# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
using module ./AttributeHelpInfo.psm1
using module ./ExampleHelpInfo.psm1
using module ./OverloadExceptionHelpInfo.psm1
using module ./OverloadParameterHelpInfo.psm1
using module ./OverloadSignature.psm1

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

class OverloadHelpInfo {
    # The signature for the overload, distinguishing it from other overloads.
    [OverloadSignature] $Signature
    # A short description of the overload's purpose.
    [string] $Synopsis = ''
    # A full description of the overload's purpose, with details.
    [string] $Description = ''
    # A list of examples showing how to use the overload.
    [ExampleHelpInfo[]] $Examples = @()
    # Indicates whether the overload is hidden from IntelliSense.
    [bool] $IsHidden = $false
    # A list of attributes applied to the overload with their definition.
    [AttributeHelpInfo[]] $Attributes = @()
    # A list of parameters for the overload, with their documentation.
    [OverloadParameterHelpInfo[]] $Parameters = @()
    <#
        A list of exception types the overload may return, with information
        about when and why the overload would return them.
    #>
    [OverloadExceptionHelpInfo[]] $Exceptions = @()

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

        $Metadata.Add('Signature', $this.Signature.ToMetadataDictionary())
        $Metadata.Add('Synopsis', $this.Synopsis.Trim())
        $Metadata.Add('Description', $this.Description.Trim())
        if ($this.Examples.Count -gt 0) {
            $Metadata.Add('Examples', [OrderedDictionary[]]($this.Examples.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Examples', [OrderedDictionary[]]@())
        }
        $Metadata.Add('IsHidden', $this.IsHidden)
        if ($this.Attributes.Count -gt 0) {
            $Metadata.Add('Attributes', [OrderedDictionary[]]($this.Attributes.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Attributes', [OrderedDictionary[]]@())
        }
        if ($this.Parameters.Count -gt 0) {
            $Metadata.Add('Parameters', [OrderedDictionary[]]($this.Parameters.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Parameters', [OrderedDictionary[]]@())
        }
        if ($this.Exceptions.Count -gt 0) {
            $Metadata.Add('Exceptions', [OrderedDictionary[]]($this.Exceptions.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Exceptions', [OrderedDictionary[]]@())
        }

        return $Metadata
    }

    OverloadHelpInfo() {}

    OverloadHelpInfo([AstInfo]$astInfo) {
        $this.Initialize($astInfo, [DecoratingCommentsRegistry]::Get())
    }

    OverloadHelpInfo([AstInfo]$astInfo, [DecoratingCommentsRegistry]$registry) {
        $this.Initialize($astInfo, $registry)
    }

    OverloadHelpInfo([FunctionMemberAst]$targetAst) {
        $this.Initialize($targetAst, [DecoratingCommentsRegistry]::Get())
    }
    OverloadHelpInfo([FunctionMemberAst]$targetAst, $registry) {
        $this.Initialize($targetAst, $registry)
    }

    hidden [void] Initialize(
        [FunctionMemberAst]$targetAst,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        $AstInfo = Get-AstInfo -TargetAst $targetAst -Regisistry $registry -ParseDecoratingComment

        $this.Initialize($AstInfo, $registry)
    }

    hidden [void] Initialize([AstInfo]$astInfo, [DecoratingCommentsRegistry]$registry) {
        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        [FunctionMemberAst]$OverloadAst = [OverloadHelpInfo]::GetValidatedAstInfo($astInfo)

        $this.IsHidden   = $OverloadAst.IsHidden
        $this.Signature  = [OverloadSignature]::new($astInfo)
        $this.Attributes = [AttributeHelpInfo]::Resolve($astInfo)
        $this.Parameters = [OverloadParameterHelpInfo]::Resolve($astInfo, $registry)
        $this.Exceptions = [OverloadExceptionHelpInfo]::Resolve($astInfo)

        $Help = $astInfo.DecoratingComment.ParsedValue

        if ($null -ne $Help) {
            if ($Help.Synopsis) {
                $this.Synopsis = $Help.Synopsis.Trim()
            }
            if ($Help.Description) {
                $this.Description = $Help.Description.Trim()
            }
            $this.Examples = [ExampleHelpInfo]::Resolve($Help)
        } elseif ($SynopsisHelp = $astInfo.DecoratingComment.MungedValue) {
            $this.Synopsis = $SynopsisHelp.Trim()
        }
    }

    hidden static [FunctionMemberAst] GetValidatedAstInfo([AstInfo]$astInfo) {
        $TargetAst = $astInfo.Ast -as [FunctionMemberAst]
        if ($null -eq $TargetAst) {
            $Message = @(
                'Invalid AstInfo for OverloadHelpInfo.'
                'Expected the Ast property to be a FunctionMemberAst,'
                "but the AST object's type was $($astInfo.Ast.GetType().FullName)."
            ) -join ' '
            throw $Message
        }

        return $TargetAst
    }
}
