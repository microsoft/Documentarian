# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class MarkdownList {
    <#
        .SYNOPSIS
            The base class for Markdown bullet and numbered lists.

        .DESCRIPTION
            The base class for Markdown bullet and numbered lists. This class is used to render
            items in a Markdown list, handling indentation and prefix style. Using the base class
            allows the same code to be used for both bullet and numbered lists and for the
            **MarkdownBuilder** to support nested lists of either type.
    #>

    <#
        .SYNOPSIS
            The list items for the Markdown list.

        .DESCRIPTION
            The list items for the Markdown list. Each item should be a block of Markdown prose.
            When formatted, the prose should have the appropriate prefix for the list type and
            inserted for the first line and the remaining lines indented to the appropriate
            column with spaces.
    #>
    [string[]] $Items = @()

    [string[]] FormatList() {
        <#
            .SYNOPSIS
                Formats the list items into a Markdown list with prefix and indentation.

            .DESCRIPTION
                Formats the list items into a Markdown list with prefix and indentation. This
                method is used by the **MarkdownBuilder** to render the list items into a Markdown
                list.

                This method is not implemented in the base class and must be implemented by derived
                classes.
        #>

        throw "FormatList() is not implemented."
    }

    <#
        .SYNOPSIS
            A regular expression pattern for matching Markdown bullet list syntax.

        .DESCRIPTION
            A regular expression pattern for matching Markdown bullet list syntax. This pattern
            matches the following list prefixes:

            - Hyphen (`-`)
            - Plus (`+`)
            - Asterisk (`*`)

            The bullet must be the first non-space character on the line and be followed by a
            space.
    #>
    static [string] $BulletPattern = '(?<bulletPrefix>-|\+|\*) '

    <#
        .SYNOPSIS
            A regular expression pattern for matching Markdown numbered list syntax.

        .DESCRIPTION
            A regular expression pattern for matching Markdown numbered list syntax. It matches
            the following list prefixes:

            - Number followed by a period (`.`)
            - Number followed by a closing parenthesis (`)`)

            The number must be the first non-space character on the line. The prefix must be
            followed by a space.
    #>
    static [string] $NumeralPrefixPattern = '(?<numeralPrefix>[0-9]+(\.|\))) '

    <#
        .SYNOPSIS
            A regular expression pattern for matching nested list items.

        .DESCRIPTION
            A regular expression pattern for matching nested list items. It matches the following
            list prefixes:

            - Hyphen (`-`)
            - Plus (`+`)
            - Asterisk (`*`)
            - Number followed by a period (`.`)
            - Number followed by a closing parenthesis (`)`)

            The prefix may be preceded by any number of spaces.

            This pattern uses the following named capture groups:

            - `nestedLeadingSpace` - The leading space before the list prefix.
            - `nestedItemPrefix` - The list prefix.
            - `bulletPrefix` - The prefix for a bullet list item, if found.
            - `numeralPrefix` - The prefix for a numbered list item, if found.
            - `nestedContent` - The content of the list item.
    #>
    static [string] $NestedListPattern = @(
        '^(?<nestedLeadingSpace> *)'            # Capture all leading space til the list prefix.
        '(?<nestedItemPrefix>('                 # Capture the list prefix.
            [MarkdownList]::BulletPattern
            '|'
            [MarkdownList]::NumeralPrefixPattern
        '))'
        '(?<nestedContent>.+)$'                 # Capture the content for the rest of the line.
    ) -join ''

    <#
        .SYNOPSIS
            Formats the specified list item.

        .DESCRIPTION
            Formats the specified list item. This method is used to format the list items for
            Markdown lists. It handles adding the prefix to the first line of the list item and
            indenting the rest of the lines to the appropriate column.

        .PARAMETER item
            The prose of the list item to format.

        .PARAMETER prefix
            The prefix to use for the list item, like `- ` or `1. `.
    #>
    static [string[]] FormatListItem([string]$item, [string]$prefix) {
        [string[]]$formattedLines = @()

        $leadingSpace = ' ' * $prefix.Length
        $lines        = ($item -split '\r?\n') -split '\r'
        $itemIsNested = $false

        for ($lineIndex = 0 ; $lineIndex -lt $lines.Length ; $lineIndex++) {
            $line         = $lines[$lineIndex]

            if ($lineIndex -eq 0) {
                $itemIsNested = $line -match [MarkdownList]::NestedListPattern
                if ($itemIsNested) {
                    $replacementPattern = '${nestedLeadingSpace}${nestedItemPrefix}${nestedContent}'

                    $line = $line -replace [MarkdownList]::NestedListPattern, $replacementPattern
                    $line = "${leadingSpace}$line"
                } else {
                    $line = "${prefix}$line"
                }
            } else {
                $line = "${leadingSpace}${line}"
            }

            $formattedLines += $line
        }

        if ($itemIsNested) {
            $formattedLines = [string[]]'' + $formattedLines + ''
        }

        return $formattedLines
    }
}