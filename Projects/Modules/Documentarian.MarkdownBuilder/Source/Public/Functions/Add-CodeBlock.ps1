# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/CodeFenceCharacter.psm1
using module ../Classes/LineEnding.psm1
using module ../Classes/MarkdownBuilder.psm1

function Add-CodeBlock {
    [cmdletbinding()]
    [OutputType([MarkdownBuilder])]
    param(
        [string]$Code,

        [string]$Language,

        [parameter(ValueFromPipeline)]
        [MarkdownBuilder]$Builder,

        [CodeFenceCharacter]$Character,

        [ValidateRange(3, [int]::MaxValue)]
        [int]$Length,

        [LineEnding]$LineEnding,

        [switch]$PassThru
    )

    begin {
        if ($null -eq $Builder) {
            $NewBuilderParameters = @{}
            if ($null -ne $Character) {
                $NewBuilderParameters.DefaultCodeFenceCharacter = $Character
            }
            if ($Length -ge 3) {
                $NewBuilderParameters.DefaultCodeFenceLength = $Length
            }
            if ($null -ne $LineEnding) {
                $NewBuilderParameters.DefaultLineEnding = $LineEnding
            }
            $Builder = New-Builder @NewBuilderParameters
        }
    }

    process {
        $PipelinePosition = $PSCmdlet.MyInvocation.PipelinePosition
        $PipelineLength = $PSCmdlet.MyInvocation.PipelineLength

        if ($PipelineLength -gt 1 -and $PipelinePosition -ne $PipelineLength) {
            $PassThru = $true
        }

        if (!$PSBoundParameters.ContainsKey('Character')) {
            $Character = $Builder.DefaultFenceCharacter
        }
        if (!$PSBoundParameters.ContainsKey('Length')) {
            $Length = $Builder.DefaultFenceLength
        }
        if (!$PSBoundParameters.ContainsKey('LineEnding')) {
            $LineEnding = $Builder.DefaultLineEnding
        }

        $Updated = $Builder.AppendCodeBlock(
            $Code,
            $Language,
            $Character,
            $Length,
            $LineEnding
        )

        if ($PassThru) {
            $Updated
        }
    }

    end {}
}
