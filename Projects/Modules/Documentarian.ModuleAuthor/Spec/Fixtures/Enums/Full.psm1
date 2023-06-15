# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# The synopsis for the enum.
# This decorating comment block is used as the enum's synopsis, because
# it's on the line immediately preceeding the enum's declaration.
enum HelpInfoTestEnumFull {
    <#
        .SYNOPSIS
        The synopsis for the enum.

        .DESCRIPTION
        The enum's description block.

        .EXAMPLE
        An example without a title.

        .EXAMPLE Another
        Another example, but with a title.

        .Label First
        The First value's description from the enum block.

        .Label Second
        The Second value's description from the enum block.

        .NOTES
        Notes about the enum.
    #>

    First
    <# A one-line comment block decorating the Second value. #>
    Second
    <#
        A multi-line comment block. It's ignored because the value has
        a comment beside it.
    #>
    Third = 5 # An inline comment decorating the Third value.
    Fourth = 7 <# A one-line comment block decorating the Fourth value. #>
    # A multi-line set of comments documenting the Fifth value.
    #
    # As long as the comments are adjacent,
    # or bridged by an empty comment,
    # they are treated as a single decorating comment.
    Fifth
    # This comment isn't attached to anything.
    <# A one-line comment block decorating the Sixth Value. #>
    Sixth
    Seventh = 11 <#
        This is ignored because it's multi-line.
    #>
}