# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/DecoratingComments/DecoratingCommentsBlockKeyword.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsRegistry.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
    $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
    Resolve-Path -Path "$SourceFolder/Public/Functions/DecoratingComments/Get-DcBlockKeyword.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
    . $RequiredFunction
}

#endregion RequiredFunctions

function Register-DcBlockKeyword {
    [CmdletBinding(DefaultParameterSetName='ByName')]
    [OutputType([DecoratingCommentsBlockKeyword[]])]
    param(
        [Parameter(Mandatory, ParameterSetName='ByKeywordName')]
        [string[]]
        $Name,

        [Parameter(Mandatory, ParameterSetName='ByKeywordObject')]
        [DecoratingCommentsBlockKeyword[]]
        $Keyword,

        [DecoratingCommentsRegistry]
        $Registry = $Global:ModuleAuthorDecoratingCommentsRegistry,

        [switch]
        $Force,

        [switch]
        $PassThru
    )

    process {
        if ($null -eq $Registry) {
            $Message = @(
                'Called Register-DcBlockKeyword, but the Registry parameter is null.'
                'You can use New-DecoratingCommentsRegistry to create a registry object,'
                'or Initialize-DcGlobalRegistry to create a global registry that the'
                "functions in this module will use when you don't specify the Registry parameter."
            ) -join ' '
            Write-Error $Message
            return
        }

        if ($null -eq $Keyword) {
            $Keyword = Get-DcBlockKeyword -Name $Name -BuiltInOnly -Registry $Registry

            if ($Keyword.Count -eq 0) {
                $W = 'Unable to resolve any DecoratingCommentBlockKeyword objects from parameters.'
                Write-Warning $W
            }
        }

        if ($Keyword.Count -gt 0) {
            $Registry.RegisterKeywords($Keyword, $Force, $PassThru)
        }
    }
}
