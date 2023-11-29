# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
using module ./BaseHelpInfo.psm1
using module ./MethodOverloadHelpInfo.psm1

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

class ClassMethodHelpInfo : BaseHelpInfo {
    # The name of the method, shared by all overloads.
    [string] $Name
    # A short description of the method.
    [string] $Synopsis = ''
    # The list of overloads for this method with their documentation.
    [MethodOverloadHelpInfo[]] $Overloads = @()

    ClassMethodHelpInfo() {}

    ClassMethodHelpInfo(
        [string]$methodName,
        [AstInfo]$classAstInfo
    ) {
        $this.Initialize($methodName, $classAstInfo, [DecoratingCommentsRegistry]::Get())
    }
    ClassMethodHelpInfo(
        [string]$methodName,
        [AstInfo]$classAstInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        $this.Initialize($methodName, $classAstInfo, $registry)
    }
    ClassMethodHelpInfo(
        [string]$methodName,
        [TypeDefinitionAst]$classAst
    ) {
        $this.Initialize($methodName, $classAst, [DecoratingCommentsRegistry]::Get())
    }
    ClassMethodHelpInfo(
        [string]$methodName,
        [TypeDefinitionAst]$classAst,
        [DecoratingCommentsRegistry]$registry
    ) {
        $this.Initialize($methodName, $classAst, $registry)
    }

    hidden [void] Initialize(
        [string]$methodName,
        [TypeDefinitionAst]$classAst,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        $AstInfo = Get-AstInfo -TargetAst $classAst -Regisistry $registry -ParseDecoratingComment

        $this.Initialize($methodName, $AstInfo, $registry)
    }

    hidden [void] Initialize(
        [string]$methodName,
        [AstInfo]$classAstInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($classAstInfo.Ast -isnot [TypeDefinitionAst]) {
            $Message = @(
                'Invalid argument. [ClassMethodHelpInfo] expects an AstInfo object where'
                "the Ast property is a TypeDefinitionAst that defines a class,"
                "but the Ast property's type was $($classAstInfo.Ast.GetType().FullName)"
            ) -join ' '
            throw [System.ArgumentException]::new($Message, 'classAstInfo')
        }
        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        [TypeDefinitionAst]$ClassAst = $classAstInfo.Ast
        $ClassHelp = $classAstInfo.DecoratingComment.ParsedValue
        $this.Name = $methodName

        # Find the synopsis in the class's decorating comment block first
        if ($MethodSynopsis = $ClassHelp.GetKeywordEntry('Method', [regex]"$methodName(\(\))?")) {
            $this.Synopsis = $MethodSynopsis
        }

        $this.Overloads = [MethodOverloadHelpInfo]::Resolve($methodName, $classAstInfo, $registry)

        # If the synopsis is still empty, use the first overload's synopsis if posible
        if ([string]::IsNullOrEmpty($this.Synopsis)) {
            $OverloadSynopsis = $this.Overloads.Synopsis |
                Where-Object -FilterScript { -not [string]::IsNullOrEmpty($_) } |
                Select-Object -First 1
            if ($OverloadSynopsis) {
                $this.Synopsis = $OverloadSynopsis
            } else {
                $this.Synopsis = ''
            }
        }

        # Give every overload the method's synopsis if they don't define their own.
        foreach ($Overload in $this.Overloads) {
            if ([string]::IsNullOrEmpty($Overload.Synopsis)) {
                $Overload.Synopsis = $this.Synopsis
            }
        }
    }

    static [ClassMethodHelpInfo[]] Resolve(
        [AstInfo]$classAstInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($classAstInfo.Ast -isnot [TypeDefinitionAst]) {
            $Message = @(
                'Invalid argument. [ClassMethodHelpInfo]::Resolve()'
                "expects an AstInfo object where the Ast property is a TypeDefinitionAst"
                "that defines a class, but the Ast property's type was"
                $classAstInfo.Ast.GetType().FullName
            ) -join ' '
            throw [System.ArgumentException]::new($Message, 'astInfo')
        }

        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        [TypeDefinitionAst]$ClassAst = $classAstInfo.Ast

        return $ClassAst.Members |
            Where-Object -FilterScript {
                $_.GetType().Name -eq 'FunctionMemberAst' -and -not $_.IsConstructor
            } |
            Select-Object -ExpandProperty Name -Unique |
            ForEach-Object -Process {
                [ClassMethodHelpInfo]::new($_, $classAstInfo, $registry)
            }
    }

    hidden static [OrderedDictionary] AddYamlFormatting([OrderedDictionary]$metadata) {
        $metadata.Name = $metadata.Name | yayaml\Add-YamlFormat -ScalarStyle Plain -PassThru
        $metadata.Synopsis = $metadata.Synopsis | yayaml\Add-YamlFormat -ScalarStyle Folded -PassThru

        return $metadata
    }
}
