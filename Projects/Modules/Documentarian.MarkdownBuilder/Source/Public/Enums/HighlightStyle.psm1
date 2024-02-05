# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

enum HighlightStyle {
    <#
        .SYNOPSIS
            Defines the style to use when highlighting text in Markdown prose.

        .DESCRIPTION
            Defines the style to use when highlighting text in Markdown prose. Not all Markdown
            tools support inline highlighting with special syntax. To support the widest range of
            Markdown tools, the highlight style supports using raw HTML and the sometimes-supported
            `==` syntax.

        .LABEL HTML
            Uses raw HTML to highlight text. This is the default style. Highlighted text looks like:

            ```markdown
            <mark>This is highlighted text.</mark>
            ```

        .LABEL Equals
            Uses the `==` syntax to highlight text. Highlighted text looks like:

            ```markdown
            ==This is highlighted text.==
            ```
    #>

    HTML   = 0
    Equals = 1
}
