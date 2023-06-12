# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Enums/DecoratingCommentsBlockKeywordKind.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsRegistry.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsBlockKeyword.psm1

function Get-DcBlockKeyword {
    [CmdletBinding(DefaultParameterSetName='ByValueFromAny')]
    [OutputType([DecoratingCommentsBlockKeyword[]])]
    param(
        [string[]]$Name,
        [DecoratingCommentsBlockKeywordKind[]]$Kind,
        [Parameter(ParameterSetName='WithMultipleEntryKeywordsFromAny')]
        [Parameter(ParameterSetName='WithMultipleEntryKeywordsFromBuiltIn')]
        [Parameter(ParameterSetName='WithMultipleEntryKeywordsFromRegistry')]
        [switch]$SupportsMultipleEntries,
        [Parameter(ParameterSetName='WithoutMultipleEntryKeywordsFromAny')]
        [Parameter(ParameterSetName='WithoutMultipleEntryKeywordsFromBuiltIn')]
        [Parameter(ParameterSetName='WithoutMultipleEntryKeywordsFromRegistry')]
        [switch]$NotSupportsMultipleEntries,
        [Parameter(ParameterSetName='WithMultipleEntryKeywordsFromAny')]
        [Parameter(ParameterSetName='WithMultipleEntryKeywordsFromRegistry')]
        [Parameter(ParameterSetName='WithoutMultipleEntryKeywordsFromAny')]
        [Parameter(ParameterSetName='WithoutMultipleEntryKeywordsFromRegistry')]
        [DecoratingCommentsRegistry]$Registry = $Global:ModuleAuthorDecoratingCommentsRegistry,

        [Parameter(ParameterSetName='WithMultipleEntryKeywordsFromBuiltIn')]
        [Parameter(ParameterSetName='WithoutMultipleEntryKeywordsFromBuiltIn')]
        [switch]$BuiltInOnly,

        [Parameter(ParameterSetName='WithMultipleEntryKeywordsFromRegistry')]
        [Parameter(ParameterSetName='WithoutMultipleEntryKeywordsFromRegistry')]
        [switch]$RegisteredOnly
    )

    process {
        [DecoratingCommentsBlockKeyword[]]$Keywords = @()
        if ($PSCmdlet.ParameterSetName -match 'FromBuiltIn$') {
            $Keywords = [DecoratingCommentsRegistry]::BuiltInKeywords
        } elseif ($PSCmdlet.ParameterSetName -match 'FromRegistry$' -and $null -ne $Registry) {
            $Keywords = $Registry.GetEnumeratedRegisteredKeywords()
        } elseif ($PSCmdlet.ParameterSetName -match 'FromRegistry$') {
            $Message = @(
                'Called Get-DcBlockKeyword with -RegisteredOnly, but the Registry parameter'
                'is null. You can use New-DecoratingCommentsRegistry to create a registry.'
                'Use the -AsGlobalRegistry to add it as a global variable or save the output'
                'of the command to a variable, then pass it to this command as a parameter.'
            ) -join ' '
            Write-Error $Message
            return
        } elseif ($null -ne $Registry) {
            $Keywords = $Registry.GetEnumeratedRegisteredKeywords()
        } else {
            $Keywords = [DecoratingCommentsRegistry]::BuiltInKeywords
        }

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
