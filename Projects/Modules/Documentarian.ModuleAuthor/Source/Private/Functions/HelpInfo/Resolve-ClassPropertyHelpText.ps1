# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using module ../../../Public/Classes/HelpInfo/ClassPropertyHelpInfo.psm1

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

function Resolve-ClassPropertyHelpText {
    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory)]
        [PropertyMemberAst]$Property,
        [CommentHelpInfo]$Help,
        [Token[]]$Tokens,
        [ClassPropertyHelpInfo]$Info
    )

    begin {
        if ($null -eq $Info) {
            $Info = [ClassPropertyHelpInfo]::new()
        }
    }

    process {
        if ($null -ne $Tokens) {
            $ResolutionParameters = @{
                StatementFirstLine = $Property.Extent.StartLineNumber
                Tokens             = $Tokens
            }
            $Comment = Resolve-CommentDecoration @ResolutionParameters

            if (![string]::IsNullOrEmpty($Comment)) {
                $Info.Synopsis = $Comment
            }
        }
    }
}
