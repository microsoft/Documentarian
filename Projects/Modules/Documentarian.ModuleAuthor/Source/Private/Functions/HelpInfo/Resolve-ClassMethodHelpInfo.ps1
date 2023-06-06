# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using module ../../../Public/Classes/HelpInfo/ClassMethodHelpInfo.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Resolve-MethodOverloadHelpInfo.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Resolve-ClassMethodHelpInfo {
    [CmdletBinding(DefaultParameterSetName = 'FromOverloads')]
    [OutputType([ClassMethodHelpInfo[]])]
    param (
        [Parameter(ParameterSetName = 'FromClass')]
        [TypeDefinitionAst]$Class,
        [Parameter(ParameterSetName = 'FromOverloads')]
        [FunctionMemberAst[]]$OverloadList,
        [Parameter()]
        [CommentHelpInfo]$Help,
        [Parameter(Mandatory)]
        [Token[]]$Tokens,
        [string[]]$Name
    )

    begin {}

    process {
        if ($OverloadList.Count -eq 0) {
            $OverloadList = $Class.Members |
            Where-Object -FilterScript {
                $_.GetType().Name -eq 'FunctionMemberAst' -and -not $_.IsConstructor
            }
        }
        if ($Name.Count -eq 0) {
            $Name = $OverloadList | Select-Object -ExpandProperty Name -Unique
        }

        $Resolving = @{}
        if ($null -ne $Help) {
            $Resolving.Help = $Help
        }
        if ($null -ne $Tokens) {
            $Resolving.Tokens = $Tokens
        }

        foreach ($MethodName in $Name) {
            $Info = [ClassMethodHelpInfo]::new()
            $Info.Name = $MethodName
            $Info.Overloads = $OverloadList |
            Where-Object -FilterScript { $_.Name -eq $MethodName } |
            Resolve-MethodOverloadHelpInfo @Resolving

            $Info
        }
    }
}
