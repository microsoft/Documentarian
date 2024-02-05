# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

enum NumberedListStyle {
    <#
        .SYNOPSIS
            Defines the style to use when turning list items into a Markdown numbered list.

        .DESCRIPTION

            Defines the style to use when turning list items into a Markdown numbered list.
            Markdown supports two syntaxes for numbered lists: period and parentheses. Markdown
            supports using any numerals for the list numbers.

            It's often useful to use the same
            number for each item in the list, as this enables reordering the items without updating
            the numbers. When you use a same number style, the list items use the starting list
            number for every item in the list.

            For lists using an incrementing number instead of the same number, this enumeration
            supports left-padding the numerals with spaces or zeroes to ensure the list items start
            at the same column. This only has an affect on longer lists, where the numeral count
            for the items isn't the same for every item.

        .LABEL SameNumberPeriod
            Uses periods to create a numbered list with the same number for each item. This is the
            default style. List items look like:

            ```markdown
            1. Item 1
            1. Item 2
            1. Item 3
            ```

        .LABEL SameNumberParentheses
            Uses parentheses to create a numbered list with the same number for each item. List
            items look like:

            ```markdown
            1) Item 1
            1) Item 2
            1) Item 3
            ```

        .LABEL IncrementingNumberPeriod
            Uses periods to create a numbered list with an incrementing number for each item. List
            items look like:

            ```markdown
            1. Item 1
            2. Item 2
            3. Item 3
            ```

            For longer lists, this style left-pads the numerals with spaces when needed. List items
            look like:

            ```markdown
             8. Item 8
             9. Item 9
            10. Item 10
            ```

        .LABEL IncrementingNumberParentheses
            Uses parentheses to create a numbered list with an incrementing number for each item.
            List items look like:

            ```markdown
            1) Item 1
            2) Item 2
            3) Item 3
            ```

            For longer lists, this style left-pads the numerals with spaces when needed. List items
            look like:

            ```markdown
             8) Item 8
             9) Item 9
            10) Item 10
            ```

        .LABEL IncrementingNumberPeriodZeroPadded
            Uses periods to create a numbered list with an incrementing number for each item.

            ```markdown
            1. Item 1
            2. Item 2
            3. Item 3
            ```

            For longer lists, this style left-pads the numerals with zeroes when needed. List items
            look like:

            ```markdown
            08. Item 8
            09. Item 9
            10. Item 10
            ```

        .LABEL IncrementingNumberParenthesesZeroPadded
            Uses parentheses to create a numbered list with an incrementing number for each item.
            List items look like:

            ```markdown
            1) Item 1
            2) Item 2
            3) Item 3
            ```

            For longer lists, this style left-pads the numerals with zeroes when needed. List items
            look like:

            ```markdown
            08) Item 8
            09) Item 9
            10) Item 10
            ```
    #>

    SameNumberPeriod
    SameNumberParentheses
    IncrementingNumberPeriod
    IncrementingNumberParentheses
    IncrementingNumberPeriodZeroPadded
    IncrementingNumberParenthesesZeroPadded
}

