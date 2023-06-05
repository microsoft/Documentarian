# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/LineEnding.psm1
using module ../Classes/MarkdownBuilder.psm1

function Stop-CodeFence {
    [cmdletbinding()]
    [OutputType([MarkdownBuilder])]
    param(
        [parameter(ValueFromPipeline)]
        [MarkdownBuilder]$Builder,

        [LineEnding]$LineEnding,

        [switch]$PassThru
    )

    begin {
        if ($null -eq $Builder) {
            $Builder = New-Builder
            if ($null -ne $LineEnding) {
                $Builder.DefaultLineEnding = $LineEnding
            }
        }
    }

    process {
        $PipelinePosition = $PSCmdlet.MyInvocation.PipelinePosition
        $PipelineLength = $PSCmdlet.MyInvocation.PipelineLength

        if ($PipelineLength -gt 1 -and $PipelinePosition -ne $PipelineLength) {
            $PassThru = $true
        }

        $Updated = if ($Builder.Fences.Count -gt 0) {
            if ($null -ne $LineEnding) {
                $Builder.CloseCodeFence($LineEnding)
            } else {
                $Builder.CloseCodeFence()
            }
        } else {
            Write-Warning 'No code fence to close. Ignoring.'
            $Builder
        }

        if ($PassThru) {
            $Updated
        }
    }

    end {}
}
