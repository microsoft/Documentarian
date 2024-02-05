# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

enum SuperscriptStyle {
    <#
        .SYNOPSIS
            Defines the style to use when creating superscript text in Markdown prose.

        .DESCRIPTION
            Defines the style to use when creating superscript text in Markdown prose. Not all
            Markdown tools support superscripting prose with special syntax. To support the widest
            range of Markdown tools, the highlight style supports using raw HTML and the
            sometimes-supported `^` syntax.

        .LABEL HTML
            Uses HTML to create superscript text. Superscript text looks like:

            ```markdown
            This is <sup>superscript</sup> text.
            ```

        .LABEL Caret
            Uses a caret to create superscript text. Superscript text looks like:

            ```markdown
            This is ^superscript^ text.
            ```
    #>

    HTML  = 0
    Caret = 1
}
