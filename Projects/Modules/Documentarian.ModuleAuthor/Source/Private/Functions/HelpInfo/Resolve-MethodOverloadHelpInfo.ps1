# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using module ../../../Public/Classes/HelpInfo/MethodOverloadHelpInfo.psm1

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

function Resolve-MethodOverloadHelpInfo {
    [CmdletBinding()]
    [OutputType([MethodOverloadHelpInfo[]])]
    param (
        [Parameter(ValueFromPipeline)]
        [FunctionMemberAst[]]$Method,
        [Parameter()]
        [CommentHelpInfo]$Help,
        [Parameter(Mandatory)]
        [Token[]]$Tokens
    )

    begin {}

    process {
        foreach ($M in $Method) {
            $Info = [MethodOverloadHelpInfo]::new()
            $Info.ReturnType = Resolve-TypeName -TypeName $M.ReturnType.TypeName
            if ($M.Attributes.Count -gt 0) {
                $Info.Attributes = Resolve-AttributeHelpInfo -Attribute $M.Attributes
            }
            if ($M.Parameters.Count -gt 0) {
                $Info.Parameters = Resolve-OverloadParameterHelpInfo -Method $M -Tokens $Tokens
            }
            $Info.Signature = Resolve-OverloadSignature -Method $M
            $Info.IsHidden = $M.IsHidden
            $Info.IsStatic = $M.IsStatic
            if ($M.Body.GetHelpContent().Outputs.Count -gt 0) {
                $Info.Exceptions = Resolve-OverloadExceptionHelpInfo -Method $M
            }
            if ($MethodBodyHelp = $M.Body.GetHelpContent()) {
                $Info.Examples = Resolve-ExampleFromHelp -Help $MethodBodyHelp
            }

            Resolve-OverloadHelpText -Method $M -Help $Help -Tokens $Tokens -Info $Info

            $Info
        }
    }
}
