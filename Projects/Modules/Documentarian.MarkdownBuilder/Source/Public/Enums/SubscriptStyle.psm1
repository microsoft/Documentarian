# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

enum SubscriptStyle {
    <#
        .SYNOPSIS
            Defines the style to use when subscripting text in Markdown prose.

        .DESCRIPTION
            Defines the style to use when subscripting text in Markdown prose. Not all Markdown
            tools support subscripting prose with special syntax. To support the widest range of
            Markdown tools, the highlight style supports using raw HTML and the sometimes-supported
            `~` syntax.

        .LABEL HTML
            Uses HTML to subscript text. Subscripted text looks like:

            ```markdown
            <sub>This is subscripted text.</sub>
            ```

        .LABEL Tilde
            Uses tildes to subscript text. Subscripted text looks like:

            ```markdown
            ~This is subscripted text.~
            ```
    #>

    HTML  = 0
    Tilde = 1
}
