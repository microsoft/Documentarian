# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/CodeFenceCharacter.psm1
using module ../Classes/LineEnding.psm1
using module ../Classes/MarkdownBuilder.psm1

function Add-ListItem {
    [cmdletbinding(DefaultParameterSetName)]
    [OutputType([MarkdownBuilder])]
    param(
        [parameter(ValueFromPipeline)]
        [MarkdownBuilder]
        $Builder,

        [parameter(Mandatory)]
        [string[]]
        $ListItem,

        [ValidateRange(0, [int]::MaxValue)]
        [int]
        $ListIndex,

        [switch]
        $PassThru
    )

    begin {
        if ($null -eq $Builder) {
            $NewBuilderParameters = @{}
            if ($null -ne $LineEnding) {
                $NewBuilderParameters.DefaultLineEnding = $LineEnding
            }
            $Builder = New-Builder @NewBuilderParameters
        }
    }

    process {
        $PipelinePosition = $PSCmdlet.MyInvocation.PipelinePosition
        $PipelineLength   = $PSCmdlet.MyInvocation.PipelineLength

        if ($PipelineLength -gt 1 -and $PipelinePosition -ne $PipelineLength) {
            $PassThru = $true
        }

        $listCount     = $Builder.Lists.Count
        $lastListIndex = $listCount - 1

        if ($listCount -eq 0) {
            throw [System.InvalidOperationException]::new('No list to add item to.')
        }

        if ($PSBoundParameters.ContainsKey('ListIndex')) {
            if ($ListIndex -gt $lastListIndex) {
                $errorMessage = @(
                    "The specified list index ($ListIndex) is out of range."
                    "The maximum index for the builder is $lastListIndex."
                    "Specify a value between 0 and $lastListIndex."
                ) -join ' '

                throw [System.ArgumentOutOfRangeException]::new(
                    'ListIndex',
                    $ListIndex,
                    $errorMessage
                )
            }
        } else {
            $ListIndex = $lastListIndex
        }

        foreach ($item in $ListItem) {
            $Updated = $Builder.AddListItem($ListIndex, $item)
        }

        if ($PassThru) {
            $Updated
        }
    }

    end {}
}
