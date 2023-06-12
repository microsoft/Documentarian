# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
using module ./OverloadHelpInfo.psm1

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

class MethodOverloadHelpInfo : OverloadHelpInfo {
    <#
        The full type name of the overload's output. If the overload doesn't
        return any output, this value should be `System.Void`.
    #>
    [string] $ReturnType
    <#
        Indicates whether the overload is available on the class itself instead
        of an instance of the class.
    #>
    [bool] $IsStatic = $false

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
        $Metadata.Add('ReturnType', $this.ReturnType.Trim())
        $Metadata.Add('IsHidden', $this.IsHidden)
        $Metadata.Add('IsStatic', $this.IsStatic)
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

    MethodOverloadHelpInfo() : base() {}

    MethodOverloadHelpInfo(
        [AstInfo]$astInfo
    ) : base($astInfo) {
        [FunctionMemberAst]$MethodAst = $astInfo.Ast
        $this.SetProperties($MethodAst)
    }

    MethodOverloadHelpInfo(
        [AstInfo]$astInfo,
        [DecoratingCommentsRegistry]$registry
    ) : base($astInfo, $registry) {
        [FunctionMemberAst]$MethodAst = $astInfo.Ast
        $this.SetProperties($MethodAst)
    }

    MethodOverloadHelpInfo(
        [FunctionMemberAst]$targetAst
    ) : base($targetAst) {
        $this.SetProperties($targetAst)
    }

    MethodOverloadHelpInfo(
        [FunctionMemberAst]$targetAst,
        $registry
    ) : base($targetAst, $registry) {
        $this.SetProperties($targetAst)
    }

    hidden [void] SetProperties([FunctionMemberAst]$methodAst) {
        $this.ReturnType = Resolve-TypeName -TypeName $methodAst.ReturnType.TypeName
        $this.IsStatic = $methodAst.IsStatic
    }

    static [MethodOverloadHelpInfo[]] Resolve(
        [string]$methodName,
        [AstInfo]$astInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($astInfo.Ast -isnot [TypeDefinitionAst]) {
            $Message = @(
                'Invalid argument. [MethodOverloadHelpInfo]::Resolve()'
                "expects an AstInfo object where the Ast property is a TypeDefinitionAst"
                "that defines a class, but the Ast property's type was"
                $astInfo.Ast.GetType().FullName
            ) -join ' '
            throw [System.ArgumentException]::new($Message, 'astInfo')
        }

        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        [TypeDefinitionAst]$ClassAst = $astInfo.Ast

        return $ClassAst.Members | Where-Object -FilterScript {
            ($_.GetType().Name -eq 'FunctionMemberAst') -and
            (-not $_.IsConstructor) -and
            ($_.Name -eq $methodName)
        } | ForEach-Object -Process {
            $GetParameters = @{
                TargetAst              = $_
                Token                  = $astInfo.Tokens
                Registry               = $registry
                ParseDecoratingComment = $true
            }
            $MethodAstInfo = Get-AstInfo @GetParameters
            [MethodOverloadHelpInfo]::new($MethodAstInfo)
        }
    }
}
