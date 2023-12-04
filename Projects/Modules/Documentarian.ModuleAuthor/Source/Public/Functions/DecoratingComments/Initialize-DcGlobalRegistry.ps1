# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/DecoratingComments/DecoratingCommentsBlockKeyword.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsBlockSchema.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsRegistry.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
    $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
    Resolve-Path -Path "$SourceFolder/Public/Functions/DecoratingComments/New-DecoratingCommentsRegistry.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
    . $RequiredFunction
}

#endregion RequiredFunctions

function Initialize-DcGlobalRegistry {
    [cmdletbinding()]
    [OutputType([DecoratingCommentsRegistry])]
    param(
        [DecoratingCommentsBlockSchema[]]
        $Schema,

        [DecoratingCommentsBlockKeyword[]]
        $Keyword,

        [switch]
        $WithoutDefaults,

        [switch]
        $Force,

        [switch]
        $PassThru
    )

    begin {
        $GlobalRegistryExists       = $null -ne $Global:ModuleAuthorDecoratingCommentsRegistry
        $ValidNewRegistryParameters = Get-Command -Name New-DecoratingCommentsRegistry |
            ForEach-Object -Process { $_.Parameters.Keys }
    }

    process {
        $NewRegistryParameters = @{}

        if ($GlobalRegistryExists) {
            Write-Verbose 'Reinitializing the global registry'

            if ($null -eq $Schema) { $Schema  = @() }
            if ($null -eq $Keyword) { $Keyword = @() }

            if ($WithoutDefaults) {
                $Global:ModuleAuthorDecoratingCommentsRegistry.InitializeWithoutDefaults(
                    $Schema,
                    $Keyword,
                    $Force
                )
            } else {
                $Global:ModuleAuthorDecoratingCommentsRegistry.Initialize(
                    $Schema,
                    $Keyword,
                    $Force
                )
            }
        } else {
            Write-Verbose 'Creating the global registry'

            $p = @{}
            foreach ($Parameter in $PSBoundParameters.Keys) {
                if ($Parameter -in $ValidNewRegistryParameters) {
                    $p.$Parameter = $PSBoundParameters[$Parameter]
                }
            }
            $Global:ModuleAuthorDecoratingCommentsRegistry = New-DecoratingCommentsRegistry @p
        }

        if ($PassThru) {
            $Global:ModuleAuthorDecoratingCommentsRegistry
        }
    }
}
