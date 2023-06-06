# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using module ../../../Public/Classes/HelpInfo/OverloadHelpInfo.psm1

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

function Resolve-OverloadHelpText {
    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory)]
        [FunctionMemberAst]$Method,
        [Parameter()]
        [CommentHelpInfo]$Help,
        [Parameter()]
        [Token[]]$Tokens,
        [OverloadHelpInfo]$Info,
        [switch]$ForConstructor
    )

    process {
        if ($null -eq $Info) {
            $Info = [OverloadHelpInfo]::new()
        }

        $Synopsis = ''
        $Description = ''

        $DecoratingComment = if ($null -ne $Tokens) {
            $ResolutionParameters = @{
                StatementFirstLine = $Method.Extent.StartLineNumber
                Tokens             = $Tokens
            }
            Resolve-CommentDecoration @ResolutionParameters
        } else { '' }

        if ($MethodBodyHelp = $Method.Body.GetHelpContent()) {
            [string]$Synopsis = $MethodBodyHelp.Synopsis
            [string]$Description = $MethodBodyHelp.Description
        }

        if ([string]::IsNullOrEmpty($Synopsis)) {
            $Synopsis = $DecoratingComment
        }

        if (![string]::IsNullOrEmpty($Synopsis)) {
            $Info.Synopsis = $Synopsis.Trim()
        }
        if (![string]::IsNullOrEmpty($Description)) {
            $Info.Description = $Description.Trim()
        }
    }
}
