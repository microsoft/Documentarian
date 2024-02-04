# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Enums/NumberedListStyle.psm1
using module ../Classes/MarkdownList.psm1

class NumberedList : MarkdownList {
    <#
        .SYNOPSIS
            Represents a Markdown numbered list.
        .DESCRIPTION
            Represents a Markdown numbered list. This class is used to render items in a Markdown
            numbered list, handling indentation and numeral style.
    #>

    <#
        .SYNOPSIS
            The default style for newly created NumberedList objects.
        
        .DESCRIPTION
            The default style for newly created NumberedList objects. This property is used to
            determine the style of a numbered list when you use one of the constructors that
            doesn't specify a style.

            The default style is `[NumberedListStyle]::SameNumberPeriod`.

            You can change the default style by setting this property to a different style. For
            example, to change the default style to `[NumberedListStyle]::IncrementingNumberPeriod`,
            use the following command:

            ```powershell
            [NumberedList]::DefaultStyle = [NumberedListStyle]::IncrementingNumberPeriod
            ```

            The available styles are:

            - `[NumberedListStyle]::SameNumberPeriod` - The list uses the value of
              **StartingNumber** for each item, followed by a period. For example, `1.` or `8.`.
            - `[NumberedListStyle]::SameNumberParentheses` - The list uses the value of
              **StartingNumber** for each item, followed by a closing parenthesis. For example,
              `1)` or `8)`.
            - `[NumberedListStyle]::IncrementingNumberPeriod` - The list increments the numeral
              used for each item in the list, starting with the value of **StartingNumber**. For
              example, `1.`, `2.`, `3.`, etc. For long lists with items that have different
              numeral counts, this style left-pads the shorter numerals with spaces to align
              the closing period.
            - `[NumberedListStyle]::IncrementingNumberParentheses` - The list increments the
              numeral used for each item in the list, starting with the value of
              **StartingNumber**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
              that have different numeral counts, this style left-pads the shorter numerals
              with spaces to align the closing parenthesis.
            - `[NumberedListStyle]::IncrementingNumberPeriodZeroPadded` - The list increments
              the numeral used for each item in the list, starting with the value of
              **StartingNumber**. For example, `1.`, `2.`, `3.`, etc. For long lists with items
              that have different numeral counts, this style left-pads the shorter numerals
              with zeroes to align the closing period.
            - `[NumberedListStyle]::IncrementingNumberParenthesesZeroPadded` - The list
              increments the numeral used for each item in the list, starting with the value of
              **StartingNumber**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
              that have different numeral counts, this style left-pads the shorter numerals
              with zeroes to align the closing parenthesis.
    #>
    static
    [NumberedListStyle]
    $DefaultStyle = [NumberedListStyle]::SameNumberPeriod

    <#
        .SYNOPSIS
            The number to start the list at.
        
        .DESCRIPTION
            The number to start the list at. This property is used to determine the number to start
            the list at when you use one of the constructors that doesn't specify a starting
            number.

            The default value is 1.
    #>
    [int]
    $StartingNumber = 1

    <#
        .SYNOPSIS
            The style of the numbered list.
        
        .DESCRIPTION
            The style to use when formatting the items as a Markdown numbered list. This property
            defaults to the value of the static **DefaultStyle** property when you create an
            instance of this class using a constructor that doesn't specify a style.

            The available styles are:

            - `[NumberedListStyle]::SameNumberPeriod` - The list uses the value of
              **StartingNumber** for each item, followed by a period. For example, `1.` or `8.`.
            - `[NumberedListStyle]::SameNumberParentheses` - The list uses the value of
              **StartingNumber** for each item, followed by a closing parenthesis. For example,
              `1)` or `8)`.
            - `[NumberedListStyle]::IncrementingNumberPeriod` - The list increments the numeral
              used for each item in the list, starting with the value of **StartingNumber**. For
              example, `1.`, `2.`, `3.`, etc. For long lists with items that have different
              numeral counts, this style left-pads the shorter numerals with spaces to align
              the closing period.
            - `[NumberedListStyle]::IncrementingNumberParentheses` - The list increments the
              numeral used for each item in the list, starting with the value of
              **StartingNumber**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
              that have different numeral counts, this style left-pads the shorter numerals
              with spaces to align the closing parenthesis.
            - `[NumberedListStyle]::IncrementingNumberPeriodZeroPadded` - The list increments
              the numeral used for each item in the list, starting with the value of
              **StartingNumber**. For example, `1.`, `2.`, `3.`, etc. For long lists with items
              that have different numeral counts, this style left-pads the shorter numerals
              with zeroes to align the closing period.
            - `[NumberedListStyle]::IncrementingNumberParenthesesZeroPadded` - The list
              increments the numeral used for each item in the list, starting with the value of
              **StartingNumber**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
              that have different numeral counts, this style left-pads the shorter numerals
              with zeroes to align the closing parenthesis.
    #>
    [NumberedListStyle]
    $Style

    <#
        .SYNOPSIS
            The items in the list.
        
        .DESCRIPTION
            The items in the list. This property is used to determine the items to include in the
            list when formatting it as Markdown. The items are rendered in the order they're
            specified in this property. Each item in the list must be the Markdown prose to include
            for that item. The prose can include line breaks and nested Markdown syntax. When the
            class formats the items, it handles indentation and the numeral prefix for each item.

            The default value is an empty array.
    #>
    [string[]]
    $Items = @()

    hidden Initialize([hashtable]$properties) {
        <#
            .SYNOPSIS
                Initializes the NumberedList object with the specified properties.

            .DESCRIPTION
                Initializes the NumberedList object with the specified properties. It sets the
                **Style** property to the default style defined by the static **DefaultStyle**
                property and the **Items** property to an empty array.

                This method is hidden from the user because it's not intended to be called
                directly. It's called by the constructors of this class.

            .PARAMETER properties
                A hashtable containing the properties to set on the object. Valid properties
                include:

                - `StartingNumber`
                - `Style`
                - `Items`
        #>

        $this.Style = [NumberedList]::DefaultStyle
        $this.Items = @()

        foreach ($key in $properties.Keys) {
            $this.$key = $properties[$key]
        }
    }

    NumberedList() {
        <#
            .SYNOPSIS
                Creates a new NumberedList object with default values.

            .DESCRIPTION
                Creates a new NumberedList object with default values. An instance of this class is
                used to render items in a Markdown bullet list, handling indentation and bullet
                style.
        #>

        $this.Initialize(@{})
    }

    NumberedList([string[]]$items) {
        <#
            .SYNOPSIS
                Creates a new NumberedList with the specified items.

            .DESCRIPTION
                Creates a new NumberedList with the specified items. An instance of this class is
                used to render items in a Markdown numbered list, handling indentation and numeral
                style.

                When you use this constructor, the list starts at 1 and uses the default style
                defined as the static **DefaultStyle** property.

            .PARAMETER items
                The items to include in the list.
        #>

        $this.Initialize(@{ Items = $items })
    }

    NumberedList([NumberedListStyle]$style) {
        <#
            .SYNOPSIS
                Creates a new NumberedList object with the specified style.

            .DESCRIPTION
                Creates a new NumberedList object with the specified style. An instance of this class
                is used to render items in a Markdown numbered list, handling indentation and style
                style.

                When you use this constructor, the list starts at 1 and uses the specified style.

            .PARAMETER style
                The style of the numbered list. Valid styles include:

                - `[NumberedListStyle]::SameNumberPeriod` - The list uses the value of
                  **StartingNumber** for each item, followed by a period. For example, `1.` or `8.`.
                - `[NumberedListStyle]::SameNumberParentheses` - The list uses the value of
                  **StartingNumber** for each item, followed by a closing parenthesis. For example,
                  `1)` or `8)`.
                - `[NumberedListStyle]::IncrementingNumberPeriod` - The list increments the numeral
                  used for each item in the list, starting with the value of **StartingNumber**. For
                  example, `1.`, `2.`, `3.`, etc. For long lists with items that have different
                  numeral counts, this style left-pads the shorter numerals with spaces to align
                  the closing period.
                - `[NumberedListStyle]::IncrementingNumberParentheses` - The list increments the
                  numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with spaces to align the closing parenthesis.
                - `[NumberedListStyle]::IncrementingNumberPeriodZeroPadded` - The list increments
                  the numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1.`, `2.`, `3.`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with zeroes to align the closing period.
                - `[NumberedListStyle]::IncrementingNumberParenthesesZeroPadded` - The list
                  increments the numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with zeroes to align the closing parenthesis.
            #>

        $this.Initialize(@{ Style = $style })
    }

    NumberedList([string[]]$items, [NumberedListStyle]$style) {
        <#
            .SYNOPSIS
                Creates a new NumberedList with the specified items and style.

            .DESCRIPTION
                Creates a new NumberedList with the specified items and style. An instance of this
                class is used to render items in a Markdown numbered list, handling indentation and
                numeral style.

                When you use this constructor, the list starts at 1 and uses the specified style.

            .PARAMETER items
                The items to include in the list.

            .PARAMETER style
                The style of the numbered list. Valid styles include:

                - `[NumberedListStyle]::SameNumberPeriod` - The list uses the value of
                  **StartingNumber** for each item, followed by a period. For example, `1.` or `8.`.
                - `[NumberedListStyle]::SameNumberParentheses` - The list uses the value of
                  **StartingNumber** for each item, followed by a closing parenthesis. For example,
                  `1)` or `8)`.
                - `[NumberedListStyle]::IncrementingNumberPeriod` - The list increments the numeral
                  used for each item in the list, starting with the value of **StartingNumber**. For
                  example, `1.`, `2.`, `3.`, etc. For long lists with items that have different
                  numeral counts, this style left-pads the shorter numerals with spaces to align
                  the closing period.
                - `[NumberedListStyle]::IncrementingNumberParentheses` - The list increments the
                  numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with spaces to align the closing parenthesis.
                - `[NumberedListStyle]::IncrementingNumberPeriodZeroPadded` - The list increments
                  the numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1.`, `2.`, `3.`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with zeroes to align the closing period.
                - `[NumberedListStyle]::IncrementingNumberParenthesesZeroPadded` - The list
                  increments the numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with zeroes to align the closing parenthesis.
        #>

        $this.Initialize(@{
            Items = $items
            Style = $style
        })
    }

    NumberedList([int]$startingNumber) {
        <#
            .SYNOPSIS
                Creates a new NumberedList starting at the specified number.

            .DESCRIPTION
                Creates a new NumberedList starting from a number other than 1. An instance of this
                class is used to render items in a Markdown numbered list, handling indentation and
                numeral style.

                When you use this constructor, the list starts at the specified number and uses
                the default style defined as the static **DefaultStyle** property.

            .PARAMETER StartingNumber
                The number to start the list at. This enables you to create a list that starts at
                a number other than 1.
        #>

        $this.Initialize(@{ StartingNumber = $startingNumber })
    }

    NumberedList([string[]]$items, [int]$startingNumber) {
        <#
            .SYNOPSIS
                Creates a new NumberedList with the specified items and starting number.

            .DESCRIPTION
                Creates a new NumberedList with the specified items and starting number. An instance
                of this class is used to render items in a Markdown numbered list, handling
                indentation and numeral style.

                When you use this constructor, the list starts at the specified number and uses
                the default style defined as the static **DefaultStyle** property.

            .PARAMETER items
                The items to include in the list.

            .PARAMETER StartingNumber
                The number to start the list at. This enables you to create a list that starts at
                a number other than 1.
        #>

        $this.Initialize(@{
            Items         = $items
            StartingNumber = $startingNumber
        })
    }

    NumberedList([int]$startingNumber, [NumberedListStyle]$style) {
        <#
            .SYNOPSIS
                Creates a new NumberedList with the specified starting number and style.

            .DESCRIPTION
                Creates a new NumberedList with the specified starting number and style. An
                instance of this class is used to render items in a Markdown numbered list,
                handling indentation and numeral style.

                When you use this constructor, the list starts at the specified number and uses
                the specified style.

            .PARAMETER StartingNumber
                The number to start the list at. This enables you to create a list that starts at
                a number other than 1.

            .PARAMETER style
                The style of the numbered list. Valid styles include:

                - `[NumberedListStyle]::SameNumberPeriod` - The list uses the value of
                  **StartingNumber** for each item, followed by a period. For example, `1.` or `8.`.
                - `[NumberedListStyle]::SameNumberParentheses` - The list uses the value of
                  **StartingNumber** for each item, followed by a closing parenthesis. For example,
                  `1)` or `8)`.
                - `[NumberedListStyle]::IncrementingNumberPeriod` - The list increments the numeral
                  used for each item in the list, starting with the value of **StartingNumber**. For
                  example, `1.`, `2.`, `3.`, etc. For long lists with items that have different
                  numeral counts, this style left-pads the shorter numerals with spaces to align
                  the closing period.
                - `[NumberedListStyle]::IncrementingNumberParentheses` - The list increments the
                  numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with spaces to align the closing parenthesis.
                - `[NumberedListStyle]::IncrementingNumberPeriodZeroPadded` - The list increments
                  the numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1.`, `2.`, `3.`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with zeroes to align the closing period.
                - `[NumberedListStyle]::IncrementingNumberParenthesesZeroPadded` - The list
                  increments the numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with zeroes to align the closing parenthesis.
        #>

        $this.Initialize(@{
            StartingNumber = $startingNumber
            Style          = $style
        })
    }

    NumberedList([string[]]$items, [int]$startingNumber, [NumberedListStyle]$style) {
        <#
            .SYNOPSIS
                Creates a new NumberedList with the specified items, starting number, and style.

            .DESCRIPTION
                Creates a new NumberedList with the specified items, starting number, and style. An
                instance of this class is used to render items in a Markdown numbered list,
                handling indentation and numeral style.

                When you use this constructor, the list starts at the specified number and uses
                the specified style.

            .PARAMETER items
                The items to include in the list.

            .PARAMETER StartingNumber
                The number to start the list at. This enables you to create a list that starts at
                a number other than 1.

            .PARAMETER style
                The style of the numbered list. Valid styles include:

                - `[NumberedListStyle]::SameNumberPeriod` - The list uses the value of
                  **StartingNumber** for each item, followed by a period. For example, `1.` or `8.`.
                - `[NumberedListStyle]::SameNumberParentheses` - The list uses the value of
                  **StartingNumber** for each item, followed by a closing parenthesis. For example,
                  `1)` or `8)`.
                - `[NumberedListStyle]::IncrementingNumberPeriod` - The list increments the numeral
                  used for each item in the list, starting with the value of **StartingNumber**. For
                  example, `1.`, `2.`, `3.`, etc. For long lists with items that have different
                  numeral counts, this style left-pads the shorter numerals with spaces to align
                  the closing period.
                - `[NumberedListStyle]::IncrementingNumberParentheses` - The list increments the
                  numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with spaces to align the closing parenthesis.
                - `[NumberedListStyle]::IncrementingNumberPeriodZeroPadded` - The list increments
                  the numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1.`, `2.`, `3.`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with zeroes to align the closing period.
                - `[NumberedListStyle]::IncrementingNumberParenthesesZeroPadded` - The list
                  increments the numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with zeroes to align the closing parenthesis.
        #>

        $this.Initialize(@{
            Items          = $items
            StartingNumber = $startingNumber
            Style          = $style
        })
    }

    [int] GetListNumeralCount() {
        <#
            .SYNOPSIS
                Gets the number of digits to use for each item in the list.
            .DESCRIPTION
                Gets the number of digits to use for each item in the list. This is used to
                determine how much space to pad the numeral with.

                For the following styles, the numeral count is based on the highest numeral in the
                list, defined as the value of **StartingNumber** plus the number of items in the
                list:

                - `[NumberedListStyle]::IncrementingNumberPeriod` - For this style, the numeral
                  count is used to left-pad the numeral with spaces. For example, if the numeral
                  count is 3, the numeral `1` is rendered as `  1.`.
                - `[NumberedListStyle]::IncrementingNumberParentheses` - For this style, the numeral
                  count is used to left-pad the numeral with spaces. For example, if the numeral
                  count is 3, the numeral `1` is rendered as `  1)`.
                - `[NumberedListStyle]::IncrementingNumberPeriodZeroPadded` - For this style, the
                  numeral count is used to left-pad the numeral with zeros. For example, if the
                  numeral count is 3, the numeral `1` is rendered as `001.`.
                - `[NumberedListStyle]::IncrementingNumberParenthesesZeroPadded` - For this style,
                  the numeral count is used to left-pad the numeral with zeros. For example, if the
                  numeral count is 3, the numeral `1` is rendered as `001)`.

                For the styles that use the same numeral for each item in the list, this method
                returns the numeral count of the **StartingNumber** property.
        #>

        $numeral = if ($this.Style -le 1) {
            $this.StartingNumber
        } else {
            $this.Items.Length + $this.StartingNumber
        }
        $count = switch ($numeral) {
            { $_ -lt 10 }         { 1 ; break }
            { $_ -lt 100 }        { 2 ; break }
            { $_ -lt 1000 }       { 3 ; break }
            { $_ -lt 10000 }      { 4 ; break }
            { $_ -lt 100000 }     { 5 ; break }
            { $_ -lt 1000000 }    { 6 ; break }
            { $_ -lt 10000000 }   { 7 ; break }
            { $_ -lt 100000000 }  { 8 ; break }
            { $_ -lt 1000000000 } { 9 ; break }
        }

        return $count
    }

    [string] GetPrefix([int]$itemIndex) {
        <#
            .SYNOPSIS
                Gets the prefix for the specified item.

            .DESCRIPTION
                Gets the prefix for the specified item. The prefix is the numeral used for the item
                followed by a period or closing parenthesis, depending on the style.

                Use this overload when you want to get the prefix for an item in the list and
                automatically determine the numeral to use.

            .PARAMETER itemIndex
                The index of the item to get the prefix for.
        #>

        $numeralValue = if ($this.Style -le 1) {
            $this.StartingNumber
        } else {
            $itemIndex + $this.StartingNumber
        }

        return $this.GetPrefix("$numeralValue")
    }

    [string] GetPrefix([string]$numeral) {
        <#
            .SYNOPSIS
                Gets the prefix for the specified numeral.

            .DESCRIPTION
                Gets the prefix for the specified numeral. The prefix is the numeral followed by a
                period or closing parenthesis, depending on the style.

                Use this overload when you want to get the prefix for a known numeral.

            .PARAMETER numeral
                The numeral to get the prefix for.
        #>

        $numeralCount = $this.GetListNumeralCount()

        $formatString = switch ($this.Style) {
            SameNumberPeriod                        { "{0}. " }
            SameNumberParentheses                   { "{0}) " }
            IncrementingNumberPeriod                { "{0,$numeralCount}. " }
            IncrementingNumberParentheses           { "{0,$numeralCount}) " }
            IncrementingNumberPeriodZeroPadded      { "{0:$('0' * $numeralCount)}. " }
            IncrementingNumberParenthesesZeroPadded { "{0:$('0' * $numeralCount)}) " }
        }

        return ($formatString -f ([int]$numeral))
    }

    [string[]] FormatListItem([string]$content, [int]$numeral) {
        <#
            .SYNOPSIS
                Formats the specified content as a list item.

            .DESCRIPTION
                Formats the specified content as a list item. This method is used to format the
                content of a list item, handling indentation and bullet style.

                Use this overload when you want to format a string as a list item and have the
                content and numeral already known.

            .PARAMETER content
                The content to format as a list item.

            .PARAMETER numeral
                The numeral to use for the list item.
        #>

        $prefix       = $this.GetPrefix("$numeral")

        return [MarkdownList]::FormatListItem($content, $prefix)
    }

    [string[]] FormatListItem([int]$index) {
        <#
            .SYNOPSIS
                Formats the specified item as a numbered list entry.

            .DESCRIPTION
                Formats the specified item as a numbered list entry. This method is used to format
                the content of a list item, handling indentation and bullet style.

                Use this overload when you want to format an item in the list automatically from
                the item's index in the list.

            .PARAMETER index
                The index of the item to format.
        #>

        $prefix       = $this.GetPrefix($index)
        $item         = $this.Items[$index]

        return [MarkdownList]::FormatListItem($item, $prefix)
    }

    [string[]] FormatList() {
        <#
            .SYNOPSIS
                Formats the list as a Markdown numbered list.

            .DESCRIPTION
                Formats the list as a Markdown numbered list. This method is used to format the list,
                handling indentation and bullet style.

            .EXAMPLE
                This example creates a numbered list with three items and formats it.

                ```powershell
                $list = [NumberedList]::new(@('Item 1', 'Item 2', 'Item 3'))
                $list.FormatList()
                ```
                ```text
                1. Item 1
                2. Item 2
                3. Item 3
                ```
        #>

        [string[]]$listLines = @()

        for ($itemIndex = 0 ; $itemIndex -lt $this.Items.Length ; $itemIndex++) {
            $listLines += $this.FormatListItem($itemIndex)
        }

        return $listLines
    }

    static [string[]] FormatList([string[]]$items) {
        <#
            .SYNOPSIS
                Formats the specified items as a Markdown numbered list.

            .DESCRIPTION
                Formats the specified items as a Markdown numbered list with the default style.

            .PARAMETER items
                The items to format as a numbered list.
        #>

        $list = [NumberedList]::new($items)

        return $list.FormatList()
    }

    static [string[]] FormatList([string[]]$items, [NumberedListStyle]$style) {
        <#
            .SYNOPSIS
                Formats the specified items as a Markdown numbered list with the specified style.

            .DESCRIPTION
                Formats the specified items as a Markdown numbered list with the specified style.

            .PARAMETER items
                The items to format as a numbered list.

            .PARAMETER style
                The style of the numbered list. Valid styles include:

                - `[NumberedListStyle]::SameNumberPeriod` - The list uses the value of
                  **StartingNumber** for each item, followed by a period. For example, `1.` or `8.`.
                - `[NumberedListStyle]::SameNumberParentheses` - The list uses the value of
                  **StartingNumber** for each item, followed by a closing parenthesis. For example,
                  `1)` or `8)`.
                - `[NumberedListStyle]::IncrementingNumberPeriod` - The list increments the numeral
                  used for each item in the list, starting with the value of **StartingNumber**. For
                  example, `1.`, `2.`, `3.`, etc. For long lists with items that have different
                  numeral counts, this style left-pads the shorter numerals with spaces to align
                  the closing period.
                - `[NumberedListStyle]::IncrementingNumberParentheses` - The list increments the
                  numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with spaces to align the closing parenthesis.
                - `[NumberedListStyle]::IncrementingNumberPeriodZeroPadded` - The list increments
                  the numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1.`, `2.`, `3.`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with zeroes to align the closing period.
                - `[NumberedListStyle]::IncrementingNumberParenthesesZeroPadded` - The list
                  increments the numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with zeroes to align the closing parenthesis.
        #>

        $list = [NumberedList]::new($items, $style)

        return $list.FormatList()
    }

    static [string[]] FormatList([string[]]$items, [int]$startingNumber) {
        <#
            .SYNOPSIS
                Formats the specified items as a Markdown numbered list starting at the specified
                number.

            .DESCRIPTION
                Formats the specified items as a Markdown numbered list starting at the specified
                number.

            .PARAMETER items
                The items to format as a numbered list.

            .PARAMETER StartingNumber
                The number to start the list at. This enables you to create a list that starts at
                a number other than 1.
        #>

        $list = [NumberedList]::new($items, $startingNumber)

        return $list.FormatList()
    }

    static [string[]] FormatList(
        [string[]]$items,
        [int]$startingNumber,
        [NumberedListStyle]$style
    ) {
        <#
            .SYNOPSIS
                Formats the specified items as a Markdown numbered list starting at the specified
                number with the specified style.

            .DESCRIPTION
                Formats the specified items as a Markdown numbered list starting at the specified
                number with the specified style.

            .PARAMETER items
                The items to format as a numbered list.

            .PARAMETER startingNumber
                The number to start the list at. This enables you to create a list that starts at
                a number other than 1.

            .PARAMETER style
                The style of the numbered list. Valid styles include:

                - `[NumberedListStyle]::SameNumberPeriod` - The list uses the value of
                  **StartingNumber** for each item, followed by a period. For example, `1.` or `8.`.
                - `[NumberedListStyle]::SameNumberParentheses` - The list uses the value of
                  **StartingNumber** for each item, followed by a closing parenthesis. For example,
                  `1)` or `8)`.
                - `[NumberedListStyle]::IncrementingNumberPeriod` - The list increments the numeral
                  used for each item in the list, starting with the value of **StartingNumber**. For
                  example, `1.`, `2.`, `3.`, etc. For long lists with items that have different
                  numeral counts, this style left-pads the shorter numerals with spaces to align
                  the closing period.
                - `[NumberedListStyle]::IncrementingNumberParentheses` - The list increments the
                  numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with spaces to align the closing parenthesis.
                - `[NumberedListStyle]::IncrementingNumberPeriodZeroPadded` - The list increments
                  the numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1.`, `2.`, `3.`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with zeroes to align the closing period.
                - `[NumberedListStyle]::IncrementingNumberParenthesesZeroPadded` - The list
                  increments the numeral used for each item in the list, starting with the value of
                  **StartingNumber**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
                  that have different numeral counts, this style left-pads the shorter numerals
                  with zeroes to align the closing parenthesis.
        #>

        $list = [NumberedList]::new($items, $startingNumber, $style)

        return $list.FormatList()
    }
}
