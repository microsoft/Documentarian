# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/CodeFenceCharacter.psm1
using module ../Classes/LineEnding.psm1
using module ../Classes/MarkdownBuilder.psm1

function New-Builder {
    [cmdletbinding(DefaultParameterSetName = 'FromContent')]
    [OutputType([MarkdownBuilder])]
    param(
        [Parameter(ParameterSetName = 'FromContent')]
        [string]$Content,

        [Parameter(ParameterSetName = 'FromStringBuilder')]
        [System.Text.StringBuilder]$StringBuilder,

        [LineEnding]$DefaultLineEnding,

        [CodeFenceCharacter]$DefaultCodeFenceCharacter,

        [ValidateRange(3, [int]::MaxValue)]
        [int]$DefaultCodeFenceLength
    )

    begin {}

    process {
        $Builder = if ($Content) {
            [MarkdownBuilder]::new($Content)
        } elseif ($StringBuilder) {
            [MarkdownBuilder]::new($StringBuilder)
        } else {
            [MarkdownBuilder]::new()
        }

        if ($null -ne $DefaultCodeFenceCharacter) {
            $Builder.DefaultFenceCharacter = $DefaultCodeFenceCharacter
        }

        if ($DefaultCodeFenceLength -ge 3) {
            $Builder.DefaultFenceLength = $DefaultCodeFenceLength
        }

        if ($null -ne $DefaultLineEnding) {
            $Builder.DefaultLineEnding = $DefaultLineEnding
        }

        $Builder
    }

    end {}
}
