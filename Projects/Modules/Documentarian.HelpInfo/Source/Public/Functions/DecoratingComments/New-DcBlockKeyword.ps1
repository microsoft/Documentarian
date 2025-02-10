# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Enums/DecoratingCommentsBlockKeywordKind.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsBlockKeyword.psm1

function New-DcBlockKeyword {
    [CmdletBinding()]
    [OutputType([DecoratingCommentsBlockKeyword[]])]
    param(
        [Parameter(Mandatory)]
        [string[]]
        $Name,

        [DecoratingCommentsBlockKeywordKind]
        $Kind,

        [switch]
        $SupportMultipleEntries,

        [regex]
        $Pattern
    )

    process {
        $Signature = 'Name'
        if ($null -ne $Kind) { $Signature += 'Kind' }
        if ($null -ne $Pattern) { $Signature += 'Pattern' }

        foreach ($KeywordName in $Name) {
            switch ($Signature) {
                'Name' {
                    [DecoratingCommentsBlockKeyword]::new($Name, $SupportMultipleEntries)
                }
                'NameKind' {
                    [DecoratingCommentsBlockKeyword]::new($Name, $Kind, $SupportMultipleEntries)
                }
                'NamePattern' {
                    [DecoratingCommentsBlockKeyword]::new(
                        $Name,
                        $SupportMultipleEntries,
                        $Pattern
                    )
                }
                'NameKindPattern' {
                    [DecoratingCommentsBlockKeyword]::new(
                        $Name,
                        $Kind,
                        $SupportMultipleEntries,
                        $Pattern
                    )
                }
                default {
                    [DecoratingCommentsBlockKeyword]::new($Name, $SupportMultipleEntries)
                }
            }
        }
    }
}
