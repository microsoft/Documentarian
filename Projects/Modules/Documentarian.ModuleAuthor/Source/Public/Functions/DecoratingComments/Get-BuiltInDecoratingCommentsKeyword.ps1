# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Enums/DecoratingCommentsBlockKeywordKind.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsRegistry.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsBlockKeyword.psm1

function Get-BuiltInDecoratingCommentsKeyword {
    [CmdletBinding(DefaultParameterSetName='WithMultipleEntryKeywords')]
    [OutputType([DecoratingCommentsBlockKeyword[]])]
    param(
        [string[]]$Name,
        [DecoratingCommentsBlockKeywordKind[]]$Kind,
        [Parameter(ParameterSetName='WithMultipleEntryKeywords')]
        [switch]$SupportsMultipleEntries,
        [Parameter(ParameterSetName='WithoutMultipleEntryKeywords')]
        [switch]$NotSupportsMultipleEntries
    )

    process {
        $Keywords = [DecoratingCommentsRegistry]::BuiltInKeywords

        if ($Name.Count -gt 0) {
            $Keywords = $Keywords | Where-Object -FilterScript {
                $_.Name -in $Name
            }
        }

        if ($Kind.Count -gt 0) {
            $Keywords = $Keywords | Where-Object -FilterScript {
                $_.Kind -in $Kind
            }
        }

        if ($SupportsMultipleEntries) {
            $Keywords = $Keywords | Where-Object -FilterScript {
                $_.SupportsMultipleEntries -eq $true
            }
        }

        if ($NotSupportsMultipleEntries) {
            $Keywords = $Keywords | Where-Object -FilterScript {
                $_.SupportsMultipleEntries -eq $false
            }
        }

        $Keywords
    }
}
