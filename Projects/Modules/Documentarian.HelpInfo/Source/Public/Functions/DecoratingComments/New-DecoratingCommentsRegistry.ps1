# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/DecoratingComments/DecoratingCommentsBlockKeyword.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsBlockSchema.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsRegistry.psm1

function New-DecoratingCommentsRegistry {
    [cmdletbinding()]
    [OutputType([DecoratingCommentsRegistry])]
    param(
        [DecoratingCommentsBlockSchema[]]$Schema,
        [DecoratingCommentsBlockKeyword[]]$Keyword,
        [switch]$WithoutDefaults
    )

    process {
        if ($Schema.Count -gt 0 -and $Keyword.Count -gt 0) {
            [DecoratingCommentsRegistry]::new($Schema, $Keyword, $WithoutDefaults)
        } elseif ($Schema.Count -gt 0) {
            [DecoratingCommentsRegistry]::new($Schema, $WithoutDefaults)
        } elseif ($Keyword.Count -gt 0) {
            [DecoratingCommentsRegistry]::new($Keyword, $WithoutDefaults)
        } else {
            [DecoratingCommentsRegistry]::new($WithoutDefaults)
        }
    }
}
