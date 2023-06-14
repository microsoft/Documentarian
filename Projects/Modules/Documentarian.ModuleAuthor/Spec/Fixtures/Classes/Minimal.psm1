# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# This class is for testing HelpInfo and decorating comments.
# It only has decorating comments, no parseable blocks.
#
# The First property is documented with a line comment. The
# Second and Third properties are documented with block
# comments. The Fourth property has no comment.
#
# The default constructor has no comments. The second constructor
# has an external line comment. The third constructor has an
# internal line comment.
#
# The DoNothing methods are documented with external comments.
# The Repeat and ToUpper methods are documented with internal
# comments.
class HelpInfoTestClassMinimal {
    # An inline comment for the First property.
    [ValidateNotNullOrEmpty()] [string] $First
    <# A one-line block comment for the Second property. #>
    static [int] $Second = 3
    <#
        A multi-line block comment for the Third property.
        It has multiple lines, indented.
    #>
    hidden [ValidateRange(1, 5)] [int] $Third
    hidden static [string] $Fourth = 'Default value'

    # An external inline comment for the DoNothing method.
    [void] DoNothing() {}

    <# An external one-line block comment for the DoNothing method. #>
    [void] DoNothing([string]$first) {}

    <#
        An external multi-line block comment for the DoNothing method.
        It has multiple lines, indented.
    #>
    [void] DoNothing(
        # Inline comment decorating the `$first` parameter.
        [string]$first,
        <#
            Block comment decorating the `$third` parameter. It spans
            multiple lines.

            It even has a second paragraph.
        #>
        [int]$third
    ) {}

    [string] Repeat([string]$a) {
        # An internal inline comment for the Repeat method. It has
        # no other comments or documentation. This is ignored because
        # the parser only looks for block comments in the body.
        return ($a * 2)
    }

    hidden [string] Repeat([string]$a, [int]$b) {
        <# An internal one-line block comment for the Repeat method. #>
        return ($a * $b)
    }

    static [string] ToUpper([string]$a) {
        <#
            An internal multi-line block comment for the ToUpper method.
            It has multiple lines, indented.
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