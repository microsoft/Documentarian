# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

enum EmphasisStyle {
    <#
        .SYNOPSIS
            Defines the style to use when emphasizing text in Markdown prose.

        .DESCRIPTION
            Defines the style to use when emphasizing text in Markdown prose. Markdown supports
            two different characters for emphasis: underscores and asterisks.

        .LABEL Underscore
            Uses underscores to emphasize text. This is the default style. Emphasized text looks
            like:

            ```markdown
            _This is emphasized text._
            ```

        .LABEL Asterisk
            Uses asterisks to emphasize text. Emphasized text looks like:

            ```markdown
            *This is emphasized text.*
            ```
    #>

    Underscore = 0
    Asterisk   = 1
}
