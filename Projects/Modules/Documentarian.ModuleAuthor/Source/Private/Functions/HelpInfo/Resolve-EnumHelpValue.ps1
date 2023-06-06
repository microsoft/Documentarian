# Copyright (c) Microsoft Corporation. # Copyright (c) Microsoft Corporation.
# Licensed under the MIT License. # Licensed under the MIT License.

using namespace System.Management.Automation.Language
using module ../../../Public/Classes/HelpInfo/EnumValueHelpInfo.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Private/Functions/Comments/Resolve-CommentDecoration.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Resolve-EnumHelpValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [MemberAst]$EnumValueAst,
        [Parameter()]
        [CommentHelpInfo]$Help,
        [Parameter(Mandatory)]
        [Token[]]$Tokens
    )

    begin {}

    process {
        $Info = [EnumValueHelpInfo]::new()
        $Info.Label = $EnumValueAst.Name.Trim()
        $Info.Value = $EnumValueAst.InitialValue.Value
        $Info.HasExplicitValue = $null -ne $EnumValueAst.InitialValue


        $ResolutionParameters = @{
            StatementFirstLine = $EnumValueAst.Extent.StartLineNumber
            Tokens             = $Tokens
        }
        $Info.Description = Resolve-CommentDecoration @ResolutionParameters

        return $Info
    }

    end {}
}
