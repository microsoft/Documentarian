# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using module ../../../Public/Classes/HelpInfo/ConstructorOverloadHelpInfo.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Resolve-AttributeHelpInfo.ps1"
  Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Resolve-ExampleFromHelp.ps1"
  Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Resolve-OverloadExceptionHelpInfo.ps1"
  Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Resolve-OverloadHelpText.ps1"
  Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Resolve-OverloadParameterHelpInfo.ps1"
  Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Resolve-OverloadSignature.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Resolve-ConstructorOverloadHelpInfo {
    [CmdletBinding(DefaultParameterSetName = 'FromOverloads')]
    [OutputType([ConstructorOverloadHelpInfo[]])]
    param (
        [Parameter(ParameterSetName = 'FromClass')]
        [TypeDefinitionAst]$Class,
        [Parameter(ValueFromPipeline, ParameterSetName = 'FromOverloads')]
        [FunctionMemberAst[]]$Constructor,
        [Parameter()]
        [CommentHelpInfo]$Help,
        [Parameter(Mandatory)]
        [Token[]]$Tokens
    )

    begin {}

    process {
        if ($null -ne $Class) {
            $Constructor = $Class.Members | Where-Object -FilterScript {
                $_.GetType().Name -eq 'FunctionMemberAst' -and $_.IsConstructor
            }
        }
        foreach ($C in $Constructor) {
            $Info = [ConstructorOverloadHelpInfo]::new()
            if ($C.Attributes.Count -gt 0) {
                $Info.Attributes = Resolve-AttributeHelpInfo -Attribute $C.Attributes
            }
            if ($C.Parameters.Count -gt 0) {
                $Info.Parameters = Resolve-OverloadParameterHelpInfo -Method $C -Tokens $Tokens
            }
            $Info.Signature = Resolve-OverloadSignature -Method $C
            $Info.IsHidden = $C.IsHidden

            $MethodBodyHelp = $C.Body.GetHelpContent()
            if ($MethodBodyHelp.Outputs.Count -gt 0) {
                $Info.Exceptions = Resolve-OverloadExceptionHelpInfo -Method $C -Tokens $Tokens
            }
            if ($MethodBodyHelp.Examples.Count -gt 0) {
                $Info.Examples = Resolve-ExampleFromHelp -Help $MethodBodyHelp
            }

            Resolve-OverloadHelpText -Method $C -Help $Help -Tokens $Tokens -Info $Info -ForConstructor

            $Info
        }
    }
}
