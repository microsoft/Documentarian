# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
using module ./OverloadHelpInfo.psm1
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

class ConstructorOverloadHelpInfo : OverloadHelpInfo {
    static [ConstructorOverloadHelpInfo] GetDefaultConstructor([string]$ClassName) {
        return [ConstructorOverloadHelpInfo]@{
            Signature = [OverloadSignature]@{
                Full     = "$ClassName()"
                TypeOnly = "$ClassName()"
            }
            Synopsis  = 'Creates an instance of the class with default values for every property.'
        }
    }

    ConstructorOverloadHelpInfo() : base() {}

    ConstructorOverloadHelpInfo(
        [AstInfo]$astInfo
    ) : base($astInfo) {}

    ConstructorOverloadHelpInfo(
        [AstInfo]$astInfo,
        [DecoratingCommentsRegistry]$registry
    ) : base($astInfo, $registry) {}

    ConstructorOverloadHelpInfo(
        [FunctionMemberAst]$targetAst
    ) : base($targetAst) {}

    ConstructorOverloadHelpInfo(
        [FunctionMemberAst]$targetAst,
        $registry
    ) : base($targetAst, $registry) {}

    static [ConstructorOverloadHelpInfo[]] Resolve(
        [AstInfo]$astInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($astInfo.Ast -isnot [TypeDefinitionAst]) {
            $Message = @(
                'Invalid argument. [ConstructorOverloadHelpInfo]::Resolve()'
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

        $Constuctors = $ClassAst.Members | Where-Object -FilterScript {
            $_.GetType().Name -eq 'FunctionMemberAst' -and $_.IsConstructor
        } | ForEach-Object -Process {
            $GetParameters = @{
                TargetAst              = $_
                Token                  = $astInfo.Tokens
                Registry               = $registry
                ParseDecoratingComment = $true
            }
            $ConstructorAstInfo = Get-AstInfo @GetParameters
            [ConstructorOverloadHelpInfo]::new($ConstructorAstInfo, $registry)
        }

        if ($null -eq $Constuctors) {
            $Constuctors = @(
                [ConstructorOverloadHelpInfo]::GetDefaultConstructor($ClassAst.Name.Trim())
            )
        }

        return $Constuctors
    }
}
