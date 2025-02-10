# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This class is for testing HelpInfo and decorating comments.
# This external decorating comment is ignored because the class
# has a parseable block comment in the body.
class HelpInfoTestClassFull {
    <#
        .SYNOPSIS
        The synopsis for the class.

        .DESCRIPTION
        The description for the class. The class has no Notes, but
        it does have two examples.

        .EXAMPLE
        The first example for the class. It doesn't have a title.

        .EXAMPLE Second Example
        The second example for the class. It has a title.

        .Property Second
        Because the Second property has a decorating comment, this
        value is used as the Description - it's easier to write a
        longer document here.

        .Property Third
        This is ignored, because the Third property has a parsed block
        with both Synopsis and Description.

        .PROPERTY Fourth
        This is used as the Fourth property's Synopsis, since it has
        the Description key in its decorating block comment.

        .METHOD Repeat
        The synopsis for the Repeat method.
    #>
    <#
        .SYNOPSIS
        Synopsis for the First property.
        .DESCRIPTION
        Description for the First property.
    #>
    [ValidateNotNullOrEmpty()] [string] $First

    <# A one-line block comment for the Second, its Synopsis. #>
    static [int] $Second = 3
    <#
        .SYNOPSIS
        The Third property's Synopsis.
        .DESCRIPTION
        The Third property's Description.
    #>
    hidden [ValidateRange(1, 5)] [int] $Third
    <#
        .DESCRIPTION
        The Fourth property's Description.
    #>
    hidden static [string] $Fourth = 'Default value'

    # An external inline comment for the DoNothing method.
    [void] DoNothing() {
        <#
            .SYNOPSIS
            Synopsis for this overload.

            .DESCRIPTION
            The external comment is ignored because this overload
            has a comment block immediately inside the body. The
            synopsis is used for the method overall because it's the
            first declared overload and the class comment block doesn't
            have this method in it.
        #>
    }

    <#
        .SYNOPSIS
        Synopsis for this overload.

        .DESCRIPTION
        Because this block is immediately before the overload, it's used
        for the overload's help. This overload has no examples.

        .PARAMETER first
        The documentation for the `$first` parameter.
    #>
    [void] DoNothing([string]$first) {}

    [void] DoNothing(
        # Inline comment decorating the `$first` parameter.
        [string]$first,
        <#
            Block comment decorating the `$third` parameter. It spans
            multiple lines.

            It even has a second paragraph.
        #>
        [int]$third
    ) {
        <#
            .SYNOPSIS
            Synopsis for this overload.

            .DESCRIPTION
            Because this block is immediately inside the overload, it's
            used for the overload's help. This overload documents the
            `$first` parameter in the block, but uses a decorating
            comment for the `$third` parameter.

            .PARAMETER first
            The documentation for the `$first` parameter. This overrides
            the decorating comment above the parameter.
        #>
    }

    [string] Repeat([string]$a) {
        # An internal inline comment for the Repeat method. It has
        # no other comments or documentation. This is ignored because
        # the parser only looks for block comments in the body.
        return ($a * 2)
    }

    hidden [string] Repeat([string]$a, [int]$b) {
        <#
            .DESCRIPTION
            The description for this overload. Neither parameter is
            documented. It doesn't have a Synopsis declared or any
            examples.
        #>
        return ($a * $b)
    }

    static [string] ToUpper([string]$a) {
        <#
            .SYNOPSIS
            The synopsis for this overload.
            .DESCRIPTION
            The description for this overload.

            .PARAMETER a
            The documentation for the `$a` parameter.

            .EXCEPTION System.ArgumentException

            The exception documentation for this overload. It informs
            consumers when and why the overload might throw an
            exception.

            .EXAMPLE
            An example for this overload. It doesn't have a title.

            .EXAMPLE Another Example
            Another example for this overload. It has a title.
        #>
        if ([string]::IsNullOrEmpty($a)) {
            # A decorating comment for a throw statement.
            throw [System.ArgumentException]::new(
                "a can't be null or empty",
                'a'
            )
        }

        return $a.ToUpper()
    }
}
