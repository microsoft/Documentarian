# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This decorating comment is ignored because the enum has a parsed decorating
# codeblock inside it.
[Flags()]
enum HelpInfoTestEnumFlags {
    <#
        .SYNOPSIS

        The HelpInfoTestEnumFlags shows how HelpInfo works for flag enums.

        .DESCRIPTION

        The HelpInfoTestEnumFlags shows how HelpInfo works for flag enums. It
        has a synopsis, description, examples, and notes. The labels are
        documented in the comment block.

        .EXAMPLE
        This is the first example.

        .EXAMPLE With a title
        This is the second example. It has a title.

        .LABEL Foo
        This documents the Foo label.

        .LABEL Bar
        This documents the Bar label.

        .LABEL Baz
        This documents the Baz label.

        .NOTES
        These are some notes.
    #>
    # Foo flag comment.
    Foo = 1
    Bar = 2 # Bar flag comment.
    # Baz flag comment.
    Baz = 4
}