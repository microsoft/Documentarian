# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

[Flags()] enum InlineFormatOptions {
    <#
        .SYNOPSIS
            Defines a set of inline formatting options for a snippet of Markdown prose.

        .DESCRIPTION
            Defines a set of inline formatting options for a snippet of Markdown prose. A snippet
            of prose can be formatted in multiple ways, such as being emphasized, highlighted,
            or struck through. This enum defines the set of formatting options that can be applied
            to the prose as a set of flags.

            This enumeration includes the `GetFlags()` method, which returns an array of the flags
            that are set on the enumeration value. This is useful for writing code that needs to
            process each of the flags.

        .LABEL None
            No formatting options are applied to the prose.

        .LABEL Code
            The prose is formatted as inline code, equivalent to the `<code>` HTML element.

        .LABEL Emphasize
            The prose is emphasized, equivalent to the `<em>` HTML element.

        .LABEL Strong
            The prose is strongly emphasized, equivalent to the `<strong>` HTML element.

        .LABEL Strikethrough
            The prose is struck through, equivalent to the `<s>` HTML element.

        .LABEL Highlight
            The prose is highlighted, equivalent to the `<mark>` HTML element.

        .LABEL Superscript
            The prose is superscripted, equivalent to the `<sup>` HTML element.

        .LABEL Subscript
            The prose is subscripted, equivalent to the `<sub>` HTML element.
    #>

    None          = 0
    Code          = 1
    Emphasize     = 2
    Strong        = 4
    Strikethrough = 8
    Highlight     = 16
    Superscript   = 32
    Subscript     = 64
}

$MemberDefinition = @{
    TypeName   = 'InlineFormatOptions'
    MemberName = 'GetFlags'
    MemberType = 'ScriptMethod'
    Value      = {
        foreach ($Flag in $this.GetType().GetEnumValues()) {
          if ($this.HasFlag($Flag)) { $Flag }
        }
    }
}

Update-TypeData @MemberDefinition
