# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/CodeFenceCharacter.psm1
using module ../Classes/LineEnding.psm1
using module ../Classes/MarkdownBuilder.psm1

function Start-List {
    [cmdletbinding(DefaultParameterSetName = 'BulletedList')]
    [OutputType([MarkdownBuilder])]
    param(
        [parameter(ValueFromPipeline, ParameterSetName = 'BulletedList')]
        [parameter(ValueFromPipeline, ParameterSetName = 'NumberedList')]
        [MarkdownBuilder]
        $Builder,

        [Parameter(ParameterSetName = 'BulletedList')]
        [BulletListStyle]
        $BulletListStyle,

        [Parameter(ParameterSetName = 'NumberedList')]
        [switch]
        $AsNumberedList,

        [Parameter(ParameterSetName = 'NumberedList')]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $StartAt = 1,

        [Parameter(ParameterSetName = 'NumberedList')]
        [NumberedListStyle]
        $NumberedListStyle,

        [parameter(ValueFromPipeline, ParameterSetName = 'BulletedList')]
        [parameter(ValueFromPipeline, ParameterSetName = 'NumberedList')]
        [LineEnding]
        $LineEnding,

        [parameter(ValueFromPipeline, ParameterSetName = 'BulletedList')]
        [parameter(ValueFromPipeline, ParameterSetName = 'NumberedList')]
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

        $specifiedBulletStyle = $PSBoundParameters.ContainsKey('BulletListStyle')
        $specifiedNumberStyle = $PSBoundParameters.ContainsKey('NumberedListStyle')
        $specifiedNumberStart = $PSBoundParameters.ContainsKey('StartAt')

        $Updated = if ($AsNumberedList -and $specifiedNumberStyle -and $specifiedNumberStart) {
            $Builder.StartNumberedList($StartAt, $NumberedListStyle)
        } elseif ($AsNumberedList -and $specifiedNumberStart) {
            $Builder.StartNumberedList($StartAt)
        } elseif ($AsNumberedList -and $specifiedNumberStyle) {
            $Builder.StartNumberedList($NumberedListStyle)
        } elseif ($AsNumberedList) {
            $Builder.StartNumberedList()
        } elseif ($specifiedBulletStyle) {
            $Builder.StartBulletList($BulletListStyle)
        } else {
            $Builder.StartBulletList()
        }

        if ($PassThru) {
            $Updated
        }
    }

    end {}
}
