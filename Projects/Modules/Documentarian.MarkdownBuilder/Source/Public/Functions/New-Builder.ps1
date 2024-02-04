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
        [Parameter(ParameterSetName = 'FromContentWithInlineFormatter')]
        [string]
        $Content,

        [Parameter(ParameterSetName = 'FromStringBuilder')]
        [Parameter(ParameterSetName = 'FromStringBuilderWithInlineFormatter')]
        [System.Text.StringBuilder]
        $StringBuilder,

        [LineEnding]
        $DefaultLineEnding,

        [SpaceMungingOptions]
        $SpaceMungingOptions,

        [CodeFenceCharacter]
        $DefaultCodeFenceCharacter,

        [ValidateRange(3, [int]::MaxValue)]
        [int]
        $DefaultCodeFenceLength,

        [NumberedListStyle]
        $NumberedListStyle,

        [BulletListStyle]
        $BulletListStyle,

        [Parameter(ParameterSetName = 'FromContentWithInlineFormatter')]
        [Parameter(ParameterSetName = 'FromStringBuilderWithInlineFormatter')]
        [InlineFormatter]
        $InlineFormatter,

        [Parameter(ParameterSetName = 'FromContent')]
        [Parameter(ParameterSetName = 'FromStringBuilder')]
        [EmphasisStyle]
        $EmphasisStyle,

        [Parameter(ParameterSetName = 'FromContent')]
        [Parameter(ParameterSetName = 'FromStringBuilder')]
        [EmphasisStyle]
        $StrongStyle,

        [Parameter(ParameterSetName = 'FromContent')]
        [Parameter(ParameterSetName = 'FromStringBuilder')]
        [StrikethroughStyle]
        $StrikethroughStyle,

        [Parameter(ParameterSetName = 'FromContent')]
        [Parameter(ParameterSetName = 'FromStringBuilder')]
        [HighlightStyle]
        $HighlightStyle,

        [Parameter(ParameterSetName = 'FromContent')]
        [Parameter(ParameterSetName = 'FromStringBuilder')]
        [SubscriptStyle]
        $SubscriptStyle,

        [Parameter(ParameterSetName = 'FromContent')]
        [Parameter(ParameterSetName = 'FromStringBuilder')]
        [SuperscriptStyle]
        $SuperscriptStyle
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

        if ($PSBoundParameters.ContainsKey('DefaultCodeFenceCharacter')) {
            $Builder.DefaultFenceCharacter = $DefaultCodeFenceCharacter
        }

        if ($DefaultCodeFenceLength -ge 3) {
            $Builder.DefaultFenceLength = $DefaultCodeFenceLength
        }

        if ($PSBoundParameters.ContainsKey('DefaultLineEnding')) {
            $Builder.DefaultLineEnding = $DefaultLineEnding
        }

        if ($PSBoundParameters.ContainsKey('SpaceMungingOptions')) {
            $Builder.SpaceMungingOptions = $SpaceMungingOptions
        }

        if ($PSBoundParameters.ContainsKey('NumberedListStyle')) {
            $Builder.NumberedListStyle = $NumberedListStyle
        }

        if ($PSBoundParameters.ContainsKey('BulletListStyle')) {
            $Builder.BulletListStyle = $BulletListStyle
        }

        if ($PSBoundParameters.ContainsKey('InlineFormatter')) {
            $Builder.InlineFormatter = $InlineFormatter
        }

        if ($PSBoundParameters.ContainsKey('EmphasisStyle')) {
            $Builder.InlineFormatter.EmphasisStyle = $EmphasisStyle
        }

        if ($PSBoundParameters.ContainsKey('StrongStyle')) {
            $Builder.InlineFormatter.StrongStyle = $StrongStyle
        }

        if ($PSBoundParameters.ContainsKey('StrikethroughStyle')) {
            $Builder.InlineFormatter.StrikethroughStyle = $StrikethroughStyle
        }

        if ($PSBoundParameters.ContainsKey('HighlightStyle')) {
            $Builder.InlineFormatter.HighlightStyle = $HighlightStyle
        }

        if ($PSBoundParameters.ContainsKey('SubscriptStyle')) {
            $Builder.InlineFormatter.SubscriptStyle = $SubscriptStyle
        }

        if ($PSBoundParameters.ContainsKey('SuperscriptStyle')) {
            $Builder.InlineFormatter.SuperscriptStyle = $SuperscriptStyle
        }

        $Builder
    }

    end {}
}
