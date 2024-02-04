# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

[Flags()] enum SpaceMungingOptions {
    <#
        .SYNOPSIS
            Defines the options to use when munging spaces in Markdown prose.

        .DESCRIPTION
            Defines the options to use when munging spaces in Markdown prose. When munging spaces,
            you can control whether to trim spaces at the start and end of the prose. You can also
            control whether and where to collapse consecutive blank lines into a single empty line.

            By default, no spaces are trimmed and no lines are collapsed.

            This enumeration has alias labels for the most common combinations of options. To trim
            spaces at the start and end of the prose, use the `TrimBoth` alias. To collapse blank
            lines at the start and end of the prose, use the `CollapseOuter` alias label. To
            collapse all blank lines, use the `CollapseAll` alias label.

            This enumeration includes the `GetFlags()` method, which returns an array of the flags
            that are set on the enumeration value. This is useful for writing code that needs to
            process the flags.

        .LABEL None
            No spaces are trimmed and no lines are collapsed. This is the default value.

        .LABEL TrimStart
            Removes leading horizontal and vertical space characters from the prose. Horizontal
            space characters include spaces and tabs. Vertical space characters include newlines
            and carriage returns.

        .LABEL TrimEnd
            Removes trailing horizontal and vertical space characters from the prose. Horizontal
            space characters include spaces and tabs. Vertical space characters include newlines
            and carriage returns.

        .LABEL TrimBoth
            Removes leading and trailing horizontal and vertical space characters from the prose.
            Horizontal space characters include spaces and tabs. Vertical space characters include
            newlines and carriage returns.

        .LABEL CollapseStart
            Collapses consecutive blank lines at the start of the prose into a single empty line.

        .LABEL CollapseEnd
            Collapses consecutive blank lines at the end of the prose into a single empty line.

        .LABEL CollapseOuter
            Collapses consecutive blank lines at the start and end of the prose into a single empty
            line.

        .LABEL CollapseInner
            Collapses consecutive blank lines in the middle of the prose into a single empty line.

        .LABEL CollapseAll
            Collapses all consecutive blank lines in the prose into a single empty line.
    #>

    None          = 0
    TrimStart     = 1
    TrimEnd       = 2
    TrimBoth      = 3
    CollapseStart = 4
    CollapseEnd   = 8
    CollapseOuter = 12
    CollapseInner = 16
    CollapseAll   = 28
}

$MemberDefinition = @{
    TypeName   = 'SpaceMungingOptions'
    MemberName = 'GetFlags'
    MemberType = 'ScriptMethod'
    Value      = {
        foreach ($Flag in $this.GetType().GetEnumValues()) {
          if ($this.HasFlag($Flag)) { $Flag }
        }
    }
}

Update-TypeData @MemberDefinition
