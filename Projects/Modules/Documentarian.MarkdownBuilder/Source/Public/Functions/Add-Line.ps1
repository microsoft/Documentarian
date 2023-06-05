# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/LineEnding.psm1
using module ../Classes/MarkdownBuilder.psm1

function Add-Line {
    [CmdletBinding()]
    [OutputType([MarkdownBuilder])]
    param(
        [string]$Content,

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

        $HasContent = ![string]::IsNullOrEmpty($Content)
        $HasLineEnding = $null -ne $LineEnding

        $Updated = if ($HasContent -and $HasLineEnding) {
            $Builder.AppendLine($Content, $LineEnding)
        } elseif ($HasContent) {
            $Builder.AppendLine($Content)
        } elseif ($HasLineEnding) {
            $Builder.AppendLine($LineEnding)
        } else {
            $Builder.AppendLine()
        }

        if ($PassThru) {
            $Updated
        }
    }

    end {}
}
