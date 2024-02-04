# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/CodeFenceCharacter.psm1
using module ../Classes/LineEnding.psm1
using module ../Classes/MarkdownBuilder.psm1

function Add-List {
    [cmdletbinding(DefaultParameterSetName = 'BulletedList')]
    [OutputType([MarkdownBuilder])]
    param(
        [parameter(ValueFromPipeline, ParameterSetName = 'BulletedList')]
        [parameter(ValueFromPipeline, ParameterSetName = 'NumberedList')]
        [MarkdownBuilder]
        $Builder,

        [Parameter(ParameterSetName = 'BulletedList')]
        [Parameter(ParameterSetName = 'NumberedList')]
        [string[]]
        $ListItem,

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

        $list = [MarkdownList]::new()

        if ($AsNumberedList) {
            $list = [NumberedList]::new()
            if ($PSBoundParameters.ContainsKey('NumberedListStyle')) {
                $list.Style = $NumberedListStyle
            } else {
                $list.Style = $Builder.NumberedListStyle
            }
            if ($PSBoundParameters.ContainsKey('StartAt')) {
                $list.StartingNumber = $StartAt
            }
            if ($PSBoundParameters.ContainsKey('ListItem')) {
                $list.Items = $ListItem
            }
        } else {
            $list = [BulletList]::new()
            if ($PSBoundParameters.ContainsKey('BulletListStyle')) {
                $list.Style = $BulletListStyle
            } else {
                $list.Style = $Builder.BulletListStyle
            }
            if ($PSBoundParameters.ContainsKey('ListItem')) {
                $list.Items = $ListItem
            }
        }

        $Updated = if ($PSBoundParameters.ContainsKey('LineEnding')) {
            $Builder.AppendList($list, $LineEnding)
        } else {
            $Builder.AppendList($list)
        }

        if ($PassThru) {
            $Updated
        }
    }

    end {}
}
