# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

enum StrikethroughStyle {
    <#
        .SYNOPSIS
            Defines the style to use when striking through text in Markdown prose.

        .DESCRIPTION
            Defines the style to use when striking through text in Markdown prose. Not all Markdown
            tools support inline striking prose with special syntax. To support the widest range of
            Markdown tools, the highlight style supports using raw HTML and the sometimes-supported
            `~~` syntax.

        .LABEL HTML
            Uses HTML to strike through text. Struck through text looks like:

            ```markdown
            <s>This is struck through text.</s>
            ```

        .LABEL Tilde
            Uses tildes to strike through text. Struck through text looks like:

            ```markdown
            ~~This is struck through text.~~
            ```
    #>

    HTML  = 0
    Tilde = 1
}
