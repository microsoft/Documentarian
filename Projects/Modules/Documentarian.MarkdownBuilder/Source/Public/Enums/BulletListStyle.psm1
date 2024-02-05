# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

enum BulletListStyle {
    <#
        .SYNOPSIS
            Defines the style to use when turning list items into a Markdown bullet list.

        .DESCRIPTION
            Defines the style to use when turning list items into a Markdown bullet list. Markdown
            supports three different characters for bullet lists: hyphens, plus signs, and
            asterisks.

        .LABEL Hyphen
            Uses hyphens to create a bullet list. This is the default style. List items look like:

            ```markdown
            - Item 1
            - Item 2
            - Item 3
            ```

        .LABEL PlusSign
            Uses plus signs to create a bullet list. List items look like:

            ```markdown
            + Item 1
            + Item 2
            + Item 3
            ```

        .LABEL Asterisk
            Uses asterisks to create a bullet list. List items look like:

            ```markdown
            * Item 1
            * Item 2
            * Item 3
            ```
    #>

    Hyphen   = 0
    PlusSign = 1
    Asterisk = 2
}
