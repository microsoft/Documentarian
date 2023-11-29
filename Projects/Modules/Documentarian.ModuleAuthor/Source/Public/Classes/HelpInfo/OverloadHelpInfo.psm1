# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
using module ./BaseHelpInfo.psm1
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

class OverloadHelpInfo : BaseHelpInfo {
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

    OverloadHelpInfo() {}
    OverloadHelpInfo([OrderedDictionary]$metadata) : base($metadata) {
    }

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

        if ($Help.IsUsable()) {
            if ($HelpSynopsis = $Help.GetKeywordEntry('Synopsis')) {
                $this.Synopsis = $HelpSynopsis
            }
            if ($HelpDescription = $Help.GetKeywordEntry('Description')) {
                $this.Description = $HelpDescription
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

    hidden static [OrderedDictionary] AddYamlFormatting([OrderedDictionary]$metadata) {
        $metadata.Synopsis = $metadata.Synopsis | yayaml\Add-YamlFormat -ScalarStyle Folded -PassThru
        $metadata.Description = $metadata.Description | yayaml\Add-YamlFormat -ScalarStyle Literal -PassThru

        return $metadata
    }
}
