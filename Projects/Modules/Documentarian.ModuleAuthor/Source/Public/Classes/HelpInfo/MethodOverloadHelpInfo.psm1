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

    MethodOverloadHelpInfo() : base() {}

    MethodOverloadHelpInfo([OrderedDictionary]$metadata) : base($metadata) {}

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
        $this.IsStatic   = $methodAst.IsStatic
    }

    static [MethodOverloadHelpInfo[]] Resolve(
        [string]$methodName,
        [AstInfo]$astInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($astInfo.Ast -isnot [TypeDefinitionAst]) {
            $Message = @(
                'Invalid argument. [MethodOverloadHelpInfo]::Resolve()'
                'expects an AstInfo object where the Ast property is a TypeDefinitionAst'
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

    hidden static [OrderedDictionary] AddYamlFormatting([OrderedDictionary]$metadata) {
        $metadata = [OverloadHelpInfo]::AddYamlFormatting($metadata)

        $metadata.ReturnType = $metadata.Type | yayaml\Add-YamlFormat -ScalarStyle Plain -PassThru

        return $metadata
    }
}
