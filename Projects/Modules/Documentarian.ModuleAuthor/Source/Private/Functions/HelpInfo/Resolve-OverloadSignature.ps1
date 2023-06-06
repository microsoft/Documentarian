# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using module ../../../Public/Classes/HelpInfo/OverloadSignature.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Get-MemberSignature.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Resolve-OverloadSignature {
    [CmdletBinding()]
    [OutputType([OverloadSignature])]
    param (
        [Parameter(Mandatory)]
        [FunctionMemberAst]$Method
    )

    process {
        [OverloadSignature]@{
            Full     = Get-MemberSignature -MemberAst $Method -Mode Full
            TypeOnly = Get-MemberSignature -MemberAst $Method -Mode TypeOnly
        }
    }
}
