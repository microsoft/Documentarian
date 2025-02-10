# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

enum DecoratingCommentsBlockKeywordKind {
    <#
        .SCHEMA Enum

        .SYNOPSIS
        Represents how a decorated comment keyword is processed.

        .DESCRIPTION
        A CommentDecorationKeyword can be one of three different kinds. The kind
        a keyword has informs the caller how it should parse the keyword and an
        author how they should write it.

        .LABEL Block
        Represents a keyword that doesn't have a distinguishing value, only a block
        of text that accompanies it. `Block` keywords include the `Synopsis`,
        `Description`, and `Notes` keywords.

        .LABEL BlockAndValue
        Represents a keyword that has a distinguishing value and a block of text.
        `BlockAndValue` keywords include the `Label`, `Parameter`, and `Property`
        keywords.

        .LABEL BlockAndOptionalValue
        Represents a keyword that has an optional distinguishing value and a block
        of text. `BlockAndOptionalValue` keywords include the `Example` keyword.

        .LABEL Value
        Represents a keyword that has a distinguishing value without a block of
        text. `Value` keywords include the `Component`, `ExternalHelp`, and `Link`
        keywords.

        .EXAMPLE
        ```powershell
        [DecoratingCommentsBlockKeywordKind]::BlockAndValue
        ```

        Gets the `BlockAndValue` enumeration.
    #>

    Block
    BlockAndValue
    BlockAndOptionalValue
    Value
}
