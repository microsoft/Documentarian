# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Enums/BulletListStyle.psm1
using module ../Enums/NumberedListStyle.psm1
using module ../Enums/SpaceMungingOptions.psm1
using module ./CodeFenceCharacter.psm1
using module ./LineEnding.psm1
using module ./MarkdownList.psm1
using module ./BulletList.psm1
using module ./NumberedList.psm1
using module ./InlineFormatter.psm1

class MarkdownBuilder {
    # The StringBuilder this class wraps for building Markdown content.
    [System.Text.StringBuilder]
    $StringBuilder

    # A dictionary of open code fences and their indices.
    [System.Collections.Generic.Dictionary[int, string]]
    $Fences

    # The default character to use for code fences.
    [CodeFenceCharacter]
    $DefaultFenceCharacter

    # The default length of code fences. Nested fences are automatically updated to ensure they
    # increase the number of characters by this amount. Users can override this value on a
    # per-fence basis.
    [ValidateRange(3, [int]::MaxValue)]
    [int]
    $DefaultFenceLength = 3

    # The default style to use for numbered lists. This can be overridden on a per-list basis.
    [NumberedListStyle]
    $NumberedListStyle = [NumberedListStyle]::SameNumberPeriod

    # The default style to use for bullet lists. This can be overridden on a per-list basis.
    [BulletListStyle]
    $BulletListStyle = [BulletListStyle]::Hyphen

    # A collection of open bullet lists.
    [System.Collections.Generic.List[BulletList]]
    $BulletLists

    # A collection of open bullet lists.
    [System.Collections.Generic.List[MarkdownList]]
    $Lists

    # The custom formatting to apply to inline elements.
    [InlineFormatter]
    $InlineFormatter

    # The default line ending to use when appending lines.
    [LineEnding]
    $DefaultLineEnding

    # The default options for space munging. By default, the MarkdownBuilder doesn't munge any
    # spaces and passes the text back exactly as submitted.
    [SpaceMungingOptions]
    $SpaceMungingOptions = [SpaceMungingOptions]::None

    [ValidateRange(0, [int]::MaxValue)]
    [int]
    $LeadingSpaceCount = 0

    MarkdownBuilder() {
        <#
            .SYNOPSIS
            Creates a new MarkdownBuilder object.
            .DESCRIPTION
            Creates a new MarkdownBuilder object with an empty StringBuilder and
            default options.
        #>

        $this.InitializeDefaultProperties()
    }

    MarkdownBuilder([LineEnding]$defaultLineEnding) {
        <#
            .SYNOPSIS
            Creates a new MarkdownBuilder object.
            .DESCRIPTION
            Creates a new MarkdownBuilder object with an empty StringBuilder and
            specified default line ending. All other options are default.
        #>

        $this.InitializeDefaultProperties()

        $this.DefaultLineEnding = $defaultLineEnding
    }

    MarkdownBuilder(
        [LineEnding]$defaultLineEnding,
        [SpaceMungingOptions]$spaceMungingOptions
    ) {
        <#
            .SYNOPSIS
            Creates a new MarkdownBuilder object.
            .DESCRIPTION
            Creates a new MarkdownBuilder object with an empty StringBuilder and
            specified default line ending. All other options are default.
        #>

        $this.InitializeDefaultProperties()

        $this.DefaultLineEnding     = $defaultLineEnding
        $this.SpaceMungingOptions   = $spaceMungingOptions
    }

    MarkdownBuilder([string]$content) {
        <#
            .SYNOPSIS
            Creates a new MarkdownBuilder object with the specified content.

            .DESCRIPTION
            Creates a new MarkdownBuilder object with the specified content and
            default options.
        #>

        $this.InitializeDefaultProperties()

        $this.StringBuilder = [System.Text.StringBuilder]::new($content)
    }

    MarkdownBuilder([System.Text.StringBuilder]$builder) {
        <#
            .SYNOPSIS
            Creates a new MarkdownBuilder object from the specified StringBuilder.

            .DESCRIPTION
            Creates a new MarkdownBuilder object from the specified StringBuilder
            and with default options.
        #>

        $this.InitializeDefaultProperties()

        $this.StringBuilder = $builder
    }

    MarkdownBuilder([string]$content, [LineEnding]$defaultLineEnding) {
        <#
            .SYNOPSIS
            Creates a new MarkdownBuilder object.
            .DESCRIPTION
            Creates a new MarkdownBuilder object with the specified content and
            default line ending. All other options are default.
        #>

        $this.InitializeDefaultProperties()

        $this.StringBuilder     = [System.Text.StringBuilder]::new($content)
        $this.DefaultLineEnding = $defaultLineEnding
    }

    MarkdownBuilder([System.Text.StringBuilder]$builder, [LineEnding]$defaultLineEnding) {
        <#
            .SYNOPSIS
            Creates a new MarkdownBuilder object.
            .DESCRIPTION
            Creates a new MarkdownBuilder object with the specified string
            builder and default line ending. All other options are default.
        #>

        $this.InitializeDefaultProperties()

        $this.StringBuilder     = $builder
        $this.DefaultLineEnding = $defaultLineEnding
    }

    hidden [void] InitializeDefaultProperties() {
        <#
            .SYNOPSIS
            Initializes the default properties of the MarkdownBuilder object.

            .DESCRIPTION
            Initializes the default properties of the MarkdownBuilder object.
            This method is used by the MarkdownBuilder constructors to ensure
            the object has the correct default properties.

            Constructors should call this method before setting the properties
            based on the method parameters, so the user-specified values override
            the default values.
        #>

        $this.StringBuilder         = [System.Text.StringBuilder]::new()
        $this.DefaultFenceCharacter = [CodeFenceCharacter]::new()
        $this.DefaultLineEnding     = [LineEnding]::new()
        $this.Fences                = [System.Collections.Generic.Dictionary[int, string]]::new()
        $this.Lists                 = [System.Collections.Generic.List[MarkdownList]]::new()
        $this.InlineFormatter       = [InlineFormatter]::new()
    }

    hidden [void] ReplaceCodeFence([int]$Index, [string]$OldFence, [string]$NewFence) {
        <#
            .SYNOPSIS
            Replaces a code fence in the StringBuilder.

            .DESCRIPTION
            Replaces a code fence in the StringBuilder with an updated code fence.
            This method is used to update the code fence when a nested code fence
            is opened.

            .PARAMETER Index
            The index of the code fence to replace.

            .PARAMETER OldFence
            The old code fence to replace.

            .PARAMETER NewFence
            The new code fence to replace the old code fence with.
        #>

        $this.StringBuilder.Replace(
            $OldFence,
            $NewFence,
            $Index,
            $OldFence.Length
        )
    }

    hidden [void] UpdateOpenFences([int]$minimumFenceLength) {
        <#
            .SYNOPSIS
            Updates open code fences when a nested fence is opened.

            .DESCRIPTION
            Updates open code fences when a nested fence is opened. This method is used to ensure
            parent fences of the new fence have enough fence characters to be valid.

            .PARAMETER minimumFenceLength
            Specifies the minimum length of the updated code fences. If the length of the fence is
            less than this value, the fence is padded to this length. If the fence is longer than
            this value, the fence is extended by one character.

        #>

        if ($this.Fences.Count -gt 0) {
            # We need to use a two-step process here because we can't modify the
            # dictionary while we're iterating over it in Windows PowerShell.
            # First, build the list of updates we need to make.
            $Updates = $this.Fences.GetEnumerator() | ForEach-Object -Process {
                $FenceKey = $_.Key
                $FenceValue = $_.Value
                $NewFence = if ($FenceValue.Length -lt $minimumFenceLength) {
                    $FenceValue.padRight($minimumFenceLength, $FenceValue[-1])
                } else {
                    $FenceValue + $FenceValue[-1]
                }
                [PSCustomObject]@{
                    Index    = $FenceKey
                    OldFence = $FenceValue
                    NewFence = $NewFence
                }
            }
            # Then, make the updates and ensure the dictionary reflects them.
            foreach ($Update in $Updates) {
                $this.ReplaceCodeFence(
                    $Update.Index,
                    $Update.OldFence,
                    $Update.NewFence
                )
                $this.Fences[$Update.Index] = $Update.NewFence
            }
        }
    }

    [MarkdownBuilder] OpenCodeFence() {
        <#
            .SYNOPSIS
            Opens a code fence with default options and no language ID.

            .DESCRIPTION
            Opens a code fence with the default fence character, fence length, and line endings. If
            there are any open fences, they're updated to ensure they have enough fence characters
            to be valid.

            The new code fence doesn't have a language ID.
        #>

        return $this.OpenCodeFence(
            '',
            $this.DefaultFenceCharacter,
            $this.DefaultFenceLength,
            $this.DefaultLineEnding
        )
    }

    [MarkdownBuilder] OpenCodeFence([CodeFenceCharacter]$codeFenceCharacter) {
        <#
            .SYNOPSIS
            Opens a code fence with the specified fence character.

            .DESCRIPTION
            Opens a code fence with the specified fence character and no language ID. The fence
            length and line endings are default. If there are any open fences, they're updated to
            ensure they have enough fence characters to be valid.

            .PARAMETER codeFenceCharacter

            The fence character to use for the code fence. Valid options include:

            - `[CodeFenceCharacter]::Backtick` - `` ` ``
            - `[CodeFenceCharacter]::Tilde` - `~`
        #>

        return $this.OpenCodeFence(
            '',
            $codeFenceCharacter,
            $this.DefaultFenceLength,
            $this.DefaultLineEnding
        )
    }

    [MarkdownBuilder] OpenCodeFence([string]$language) {
        <#
            .SYNOPSIS
            Opens a code fence for the specified language.

            .DESCRIPTION
            Opens a code fence with the specified language ID. It uses the defaults for fence
            character, fence length, and line endings. If there are any open fences, they're
            updated to ensure they have enough fence characters to be valid.

            .PARAMETER language
            The language ID to use for the code fence. This can be any string, but your Markdown
            parser or syntax highlighter might only support specific language IDs.
        #>

        return $this.OpenCodeFence(
            $language,
            $this.DefaultFenceCharacter,
            $this.DefaultFenceLength,
            $this.DefaultLineEnding
        )
    }

    [MarkdownBuilder] OpenCodeFence(
        [string]$language,
        [CodeFenceCharacter]$codeFenceCharacter,
        [int]$codeFenceLength,
        [LineEnding]$lineEnding
    ) {
        <#
            .SYNOPSIS
            Opens a code fence with the specified options.

            .DESCRIPTION
            Opens a code fence with the specified language ID, fence character, fence length, and
            line ending. If there are any open fences, they're updated to ensure they have
            enough fence characters to be valid.

            .PARAMETER language
            The language ID to use for the code fence. This can be any string, but your Markdown
            parser or syntax highlighter might only support specific language IDs.

            .PARAMETER codeFenceCharacter
            The fence character to use for the code fence. Valid options include:

            - `[CodeFenceCharacter]::Backtick` - `` ` ``
            - `[CodeFenceCharacter]::Tilde` - `~`

            .PARAMETER codeFenceLength
            The number of fence characters to use for the code fence. This must be greater than
            or equal to 3. If it's less than 3, it's set to 3. If the code fence is being opened
            inside another code fence, the lengths of the parent codefences are automatically
            increased to ensure the new fence is valid.

            .PARAMETER lineEnding
            The line ending to use for the code fence. Valid options include:

            - `[LineEnding]::CR` - `\r`
            - `[LineEnding]::CRLF` - `\r\n`
            - `[LineEnding]::LF` - `\n`
        #>

        if ($codeFenceLength -lt 3) {
            $codeFenceLength = 3
        }

        $this.UpdateOpenFences($codeFenceLength + 1)

        $NewLine = $lineEnding.ToString()
        $CurrentText = $this.StringBuilder.ToString()
        $HasPriorText = -not [string]::IsNullOrEmpty($CurrentText)
        $OnNewLine = $CurrentText.EndsWith($NewLine)
        $BlankLineBefore = $CurrentText.EndsWith($NewLine * 2)
        if ($HasPriorText -and -not $OnNewLine) {
            $this.StringBuilder.Append($NewLine * 2)
        } elseif ($HasPriorText -and -not $BlankLineBefore) {
            $this.StringBuilder.Append($NewLine)
        }

        $NewFence = $codeFenceCharacter.ToString() * $codeFenceLength
        $this.Fences.Add($this.StringBuilder.Length, $NewFence)

        $this.StringBuilder.Append("$NewFence$language").Append($NewLine)

        return $this
    }

    [MarkdownBuilder] CloseCodeFence() {
        <#
            .SYNOPSIS
            Closes the most recently opened code fence.

            .DESCRIPTION
            Closes the most recently opened code fence with the appropriate
            number of fence characters. If there are no open fences, this
            method does nothing.
        #>

        return $this.CloseCodeFence($this.DefaultLineEnding)
    }

    [MarkdownBuilder] CloseCodeFence([LineEnding]$lineEnding) {
        <#
            .SYNOPSIS
            Closes the most recently opened code fence.

            .DESCRIPTION
            Closes the most recently opened code fence with the appropriate
            number of fence characters. If there are no open fences, this
            method does nothing.
        #>
        $lineEnding = $lineEnding.ToString()
        $ClosingFence = $this.Fences.GetEnumerator() | Select-Object -Last 1
        $this.Fences.Remove($ClosingFence.Key)
        $this.StringBuilder.Append($ClosingFence.Value).Append($lineEnding).Append($lineEnding)

        return $this
    }

    [MarkdownBuilder] AppendCodeBlock([string]$code) {
        <#
            .SYNOPSIS
            Appends a code block to the MarkdownBuilder.

            .DESCRIPTION
            Appends a code block to the MarkdownBuilder. The code block is
            wrapped in a code fence with the default options and no language ID.

            .PARAMETER code
            The code to append to the MarkdownBuilder.
        #>

        return $this.AppendCodeBlock($code, $this.DefaultLineEnding)
    }

    [MarkdownBuilder] AppendCodeBlock([string]$code, [string]$language) {
        <#
            .SYNOPSIS
            Appends a code block to the MarkdownBuilder.

            .DESCRIPTION
            Appends a code block to the MarkdownBuilder. The code block is
            wrapped in a code fence with the specified language ID.

            .PARAMETER code
            The code to append to the MarkdownBuilder.

            .PARAMETER language
            The language ID to use for the code fence. This can be any string,
            but your Markdown parser or syntax highlighter might only support
            specific language IDs.
        #>

        return $this.AppendCodeBlock($code, $language, $this.DefaultLineEnding)
    }

    [MarkdownBuilder] AppendCodeBlock([string]$code, [LineEnding]$lineEnding) {
        <#
            .SYNOPSIS
            Appends a code block to the MarkdownBuilder.

            .DESCRIPTION
            Appends a code block to the MarkdownBuilder. The code block is
            wrapped in a code fence with the default options and no language ID.

            .PARAMETER code
            The code to append to the MarkdownBuilder.

            .PARAMETER lineEnding
            The line ending to use for the code fence. Valid options include:

            - `[LineEnding]::CR` - `\r`
            - `[LineEnding]::CRLF` - `\r\n`
            - `[LineEnding]::LF` - `\n`
        #>

        return $this.AppendCodeBlock($code, '', $lineEnding)
    }

    [MarkdownBuilder] AppendCodeBlock([string]$code, [string]$language, [LineEnding]$lineEnding) {
        <#
            .SYNOPSIS
            Appends a code block to the MarkdownBuilder.

            .DESCRIPTION
            Appends a code block to the MarkdownBuilder. The code block is
            wrapped in a code fence with the specified language ID.

            .PARAMETER code
            The code to append to the MarkdownBuilder.

            .PARAMETER language
            The language ID to use for the code fence. This can be any string,
            but your Markdown parser or syntax highlighter might only support
            specific language IDs.

            .PARAMETER lineEnding
            The line ending to use for the code fence. Valid options include:

            - `[LineEnding]::CR` - `\r`
            - `[LineEnding]::CRLF` - `\r\n`
            - `[LineEnding]::LF` - `\n`
        #>

        $this.OpenCodeFence(
            $language,
            $this.DefaultFenceCharacter,
            $this.DefaultFenceLength,
            $lineEnding
        )
        $this.AppendLine($code, $lineEnding)
        $this.CloseCodeFence($lineEnding)

        return $this
    }

    [MarkdownBuilder] AppendCodeBlock(
        [string]$code,
        [string]$language,
        [CodeFenceCharacter]$fenceCharacter,
        [int]$fenceLength,
        [LineEnding]$lineEnding
    ) {
        $this.OpenCodeFence(
            $language,
            $fenceCharacter,
            $fenceLength,
            $lineEnding
        ).AppendLine(
            $code,
            $lineEnding
        ).CloseCodeFence($lineEnding)

        return $this
    }

    [MarkdownBuilder] StartBulletList() {
        <#
            .SYNOPSIS
            Starts a bullet list with the default bullet style.

            .DESCRIPTION
            Starts a bullet list with the default bullet style. If there's already a list open,
            this method opens a nested list. #>

        return $this.StartBulletList($this.BulletListStyle)
    }

    [MarkdownBuilder] StartBulletList([BulletListStyle]$bulletListStyle) {
        <#
            .SYNOPSIS
            Starts a bullet list with the specified bullet style.

            .DESCRIPTION
            Starts a bullet list with the specified bullet style. If there's already a list open,
            this method does opens a nested list.

            .PARAMETER bulletListStyle
            The bullet style to use for the bullet list. Valid options include:

            - `[BulletListStyle]::Asterisk` - `*`
            - `[BulletListStyle]::Hyphen` - `-`
            - `[BulletListStyle]::Plus` - `+`
        #>

        $bulletList = [BulletList]::new($bulletListStyle)
        $this.Lists.Add($bulletList)

        return $this
    }

    [MarkdownBuilder] StartNumberedList() {
        <#
            .SYNOPSIS
            Starts a numbered list with the default style.

            .DESCRIPTION
            Starts a numbered list with the default style. If there's already a list open, this
            method opens a nested list. #>

        return $this.StartNumberedList($this.NumberedListStyle)
    }

    [MarkdownBuilder] StartNumberedList([NumberedListStyle]$style) {
        <#
            .SYNOPSIS
            Starts a numbered list with the specified style.

            .DESCRIPTION
            Starts a numbered list with the specified style. If there's already a list open, this
            method opens a nested list.

            .PARAMETER style
            The style to use for the numbered list. Valid options include:

            - `[NumberedListStyle]::SameNumberPeriod` - The list uses the value of
              **StartingIndex** for each item, followed by a period. For example, `1.` or `8.`.
            - `[NumberedListStyle]::SameNumberParentheses` - The list uses the value of
              **StartingIndex** for each item, followed by a closing parenthesis. For example,
              `1)` or `8)`.
            - `[NumberedListStyle]::IncrementingNumberPeriod` - The list increments the numeral
              used for each item in the list, starting with the value of **StartingIndex**. For
              example, `1.`, `2.`, `3.`, etc. For long lists with items that have different
              numeral counts, this style left-pads the shorter numerals with spaces to align
              the closing period.
            - `[NumberedListStyle]::IncrementingNumberParentheses` - The list increments the
              numeral used for each item in the list, starting with the value of
              **StartingIndex**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
              that have different numeral counts, this style left-pads the shorter numerals
              with spaces to align the closing parenthesis.
            - `[NumberedListStyle]::IncrementingNumberPeriodZeroPadded` - The list increments
              the numeral used for each item in the list, starting with the value of
              **StartingIndex**. For example, `1.`, `2.`, `3.`, etc. For long lists with items
              that have different numeral counts, this style left-pads the shorter numerals
              with zeroes to align the closing period.
            - `[NumberedListStyle]::IncrementingNumberParenthesesZeroPadded` - The list
              increments the numeral used for each item in the list, starting with the value of
              **StartingIndex**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
              that have different numeral counts, this style left-pads the shorter numerals
              with zeroes to align the closing parenthesis.
        #>

        $numberedList = [NumberedList]::new($style)
        $this.Lists.Add($numberedList)

        return $this
    }

    [MarkdownBuilder] StartNumberedList([int]$startingNumber) {
        <#
            .SYNOPSIS
            Starts a numbered list with the default style and the specified starting number.

            .DESCRIPTION
            Starts a numbered list with the default style and the specified starting number. If
            there's already a list open, this method opens a nested list.

            .PARAMETER startingNumber
            The number to start the list at. This value is used to determine the number to start
            the list at, enabling lists to start at a number other than `1`.
        #>

        return $this.StartNumberedList($this.NumberedListStyle, $startingNumber)
    }

    [MarkdownBuilder] StartNumberedList([NumberedListStyle]$style, [int]$startingNumber) {
        <#
            .SYNOPSIS
            Starts a numbered list with the specified style and starting number.

            .DESCRIPTION
            Starts a numbered list with the specified style and starting number. If there's
            already a list open, this method opens a nested list.

            .PARAMETER style
            The style to use for the numbered list. Valid options include:

            - `[NumberedListStyle]::SameNumberPeriod` - The list uses the value of
              **StartingIndex** for each item, followed by a period. For example, `1.` or `8.`.
            - `[NumberedListStyle]::SameNumberParentheses` - The list uses the value of
              **StartingIndex** for each item, followed by a closing parenthesis. For example,
              `1)` or `8)`.
            - `[NumberedListStyle]::IncrementingNumberPeriod` - The list increments the numeral
              used for each item in the list, starting with the value of **StartingIndex**. For
              example, `1.`, `2.`, `3.`, etc. For long lists with items that have different
              numeral counts, this style left-pads the shorter numerals with spaces to align
              the closing period.
            - `[NumberedListStyle]::IncrementingNumberParentheses` - The list increments the
              numeral used for each item in the list, starting with the value of
              **StartingIndex**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
              that have different numeral counts, this style left-pads the shorter numerals
              with spaces to align the closing parenthesis.
            - `[NumberedListStyle]::IncrementingNumberPeriodZeroPadded` - The list increments
              the numeral used for each item in the list, starting with the value of
              **StartingIndex**. For example, `1.`, `2.`, `3.`, etc. For long lists with items
              that have different numeral counts, this style left-pads the shorter numerals
              with zeroes to align the closing period.
            - `[NumberedListStyle]::IncrementingNumberParenthesesZeroPadded` - The list
              increments the numeral used for each item in the list, starting with the value of
              **StartingIndex**. For example, `1)`, `2)`, `3)`, etc. For long lists with items
              that have different numeral counts, this style left-pads the shorter numerals
              with zeroes to align the closing parenthesis.

            .PARAMETER startingNumber
            The number to start the list at. This value is used to determine the number to start
            the list at, enabling lists to start at a number other than `1`.
        #>

        $numberedList = [NumberedList]::new($startingNumber, $style)
        $this.Lists.Add($numberedList)

        return $this
    }

    [MarkdownBuilder] AddListItem([string]$item) {
        <#
            .SYNOPSIS
            Adds an item to the current list.

            .DESCRIPTION

            Adds an item to the current list. If there's no list open, this method
            throws an error. The item is added to the _last_ opened list. If you have nested
            lists, you can use this method to add items to the innermost list.

            To add an item to a specific list, use the `AddItem` method on the list,
            or use the `AddListItem()` method with the specified index.

            .PARAMETER item
            The item to add to the list.
        #>

        return $this.AddListItem(($this.Lists.Count - 1), $item)
    }

    [MarkdownBuilder] AddListItem([int]$index, [string]$item) {
        <#
            .SYNOPSIS
            Adds an item to the specified list.

            .DESCRIPTION
            Adds an item to the specified list. If there's no list open, this method
            throws an error. The item is added to the _last_ opened list. If you have nested
         lists, you can use this method to add items to the innermost list.

            To add an item to a specific list, use the `AddItem` method on the list,
            or use the `AdListItem()` method with the specified index.

            .PARAMETER index
            The index of the list to add the item to.

            .PARAMETER item
            The item to add to the list.
        #>

        if ($this.Lists.Count -eq 0) {
            throw [System.InvalidOperationException]::new('There is no open list.')
        }

        if ($index -lt 0 -or $index -ge $this.Lists.Count) {
            throw [System.ArgumentOutOfRangeException]::new(
                'index',
                $index,
                'The index must be greater than or equal to 0 and less than the number of open lists.'
            )
        }

        $this.Lists[$index].Items += $item

        return $this
    }

    [MarkdownBuilder] EndList() {
        <#
            .SYNOPSIS
            Ends the most recently opened list.

            .DESCRIPTION
            Ends the most recently opened list. If there are no open lists, this method throws an
            error. If there are nested lists, the innermost list is formatted and appended to the
            next outer list as a single item. If there is only one list open, the list is formatted
            and appended to the prose.

            This overload uses the default line ending for the builder.
        #>

        return $this.EndList($this.DefaultLineEnding)
    }

    [MarkdownBuilder] EndList([LineEnding]$lineEnding) {
        <#
            .SYNOPSIS
            Ends the most recently opened list.

            .DESCRIPTION
            Ends the most recently opened list. If there are no open lists, this method throws an
            error. If there are nested lists, the innermost list is formatted and appended to the
            next outer list as a single item. If there is only one list open, the list is formatted
            and appended to the prose.

            .PARAMETER lineEnding
            The line ending to use when formatting the list. Valid options include:

            - `[LineEnding]::CR` - `\r`
            - `[LineEnding]::CRLF` - `\r\n`
            - `[LineEnding]::LF` - `\n`
        #>

        $lineEnding = $lineEnding.ToString()

        if ($this.Lists.Count -eq 0) {
            throw [System.InvalidOperationException]::new('There is no open list.')
        } elseif ($this.Lists.Count -gt 1) {
            $listIndex  = $this.Lists.Count - 1
            $endingList = $this.Lists[$listIndex]
            $formatted  = $endingList.FormatList() -join $lineEnding

            $this.Lists[-2].Items += $formatted

            $this.Lists.RemoveAt($listIndex)
        } else {
            $listLines = $this.Lists[0].FormatList()

            $this.AppendLine($listLines, $lineEnding)
            $this.AppendLine($lineEnding)
        }

        return $this
    }

    [MarkdownBuilder] AppendList([MarkdownList]$list) {
        <#
            .SYNOPSIS
            Appends a list to the MarkdownBuilder.

            .DESCRIPTION
            Appends a list to the MarkdownBuilder. The list is formatted
            and then inserted into the prose, using the current indentation and
            other settings.

            .PARAMETER list
            The bullet list to append to the MarkdownBuilder.
        #>

        return $this.AppendList($list, $this.DefaultLineEnding)
    }

    [MarkdownBuilder] AppendList([MarkdownList]$list, [LineEnding]$lineEnding) {
        <#
            .SYNOPSIS
            Appends a bullet list to the MarkdownBuilder.

            .DESCRIPTION
            Appends a bullet list to the MarkdownBuilder. The list is formatted
            and then inserted into the prose, using the current indentation and
            other settings and the specified line ending.

            .PARAMETER list
            The bullet list to append to the MarkdownBuilder.

            .PARAMETER lineEnding
            The line ending to use when formatting the bullet list. Valid options include:

            - `[LineEnding]::CR` - `\r`
            - `[LineEnding]::CRLF` - `\r\n`
            - `[LineEnding]::LF` - `\n`
        #>

        $listLines = $list.FormatList()

        foreach ($line in $listLines) {
            $this.AppendLine($line, $lineEnding)
        }

        return $this
    }
    [MarkdownBuilder] AppendBulletList([BulletList]$list) {
        <#
            .SYNOPSIS
            Appends a bullet list to the MarkdownBuilder.

            .DESCRIPTION
            Appends a bullet list to the MarkdownBuilder. The list is formatted
            and then inserted into the prose, using the current indentation and
            other settings.

            .PARAMETER list
            The bullet list to append to the MarkdownBuilder.
        #>

        return $this.AppendBulletList($list, $this.DefaultLineEnding)
    }

    [MarkdownBuilder] AppendBulletList([BulletList]$list, [LineEnding]$lineEnding) {
        <#
            .SYNOPSIS
            Appends a bullet list to the MarkdownBuilder.

            .DESCRIPTION
            Appends a bullet list to the MarkdownBuilder. The list is formatted
            and then inserted into the prose, using the current indentation and
            other settings and the specified line ending.

            .PARAMETER list
            The bullet list to append to the MarkdownBuilder.

            .PARAMETER lineEnding
            The line ending to use when formatting the bullet list. Valid options include:

            - `[LineEnding]::CR` - `\r`
            - `[LineEnding]::CRLF` - `\r\n`
            - `[LineEnding]::LF` - `\n`
        #>

        $listLines = $list.FormatList()

        foreach ($line in $listLines) {
            $this.AppendLine($line, $lineEnding)
        }

        return $this
    }

    [MarkdownBuilder] AppendBulletList([string[]]$items) {
        <#
            .SYNOPSIS
            Appends a bullet list to the MarkdownBuilder.

            .DESCRIPTION
            Appends a bullet list to the MarkdownBuilder. The list is formatted
            and then inserted into the prose, using the current indentation and
            other settings

            .PARAMETER items
            The items to add to the bullet list.
        #>

        $list = [BulletList]::new($items, $this.BulletListStyle)

        return $this.AppendBulletList($list)
    }

    [MarkdownBuilder] AppendBulletList([string[]]$items, [LineEnding]$lineEnding) {
        <#
            .SYNOPSIS
            Appends a bullet list to the MarkdownBuilder.

            .DESCRIPTION
            Appends a bullet list to the MarkdownBuilder. The list is formatted
            and then inserted into the prose, using the current indentation and
            other settings

            .PARAMETER items
            The items to add to the bullet list.

            .PARAMETER lineEnding
            The line ending to use when formatting the bullet list. Valid options include:

            - `[LineEnding]::CR` - `\r`
            - `[LineEnding]::CRLF` - `\r\n`
            - `[LineEnding]::LF` - `\n`
        #>

        $list = [BulletList]::new($items, $this.BulletListStyle)

        return $this.AppendBulletList($list, $lineEnding)
    }

    [MarkdownBuilder] AppendBulletList([string[]]$items, [BulletListStyle]$bulletListStyle) {
        <#
            .SYNOPSIS
            Appends a bullet list to the MarkdownBuilder.

            .DESCRIPTION
            Appends a bullet list to the MarkdownBuilder. The list is formatted
            and then inserted into the prose, using the current indentation and
            other settings

            .PARAMETER items
            The items to add to the bullet list.

            .PARAMETER bulletListStyle
            The bullet style to use for the bullet list. Valid options include:

            - `[BulletListStyle]::Asterisk` - `*`
            - `[BulletListStyle]::Hyphen` - `-`
            - `[BulletListStyle]::Plus` - `+`
        #>

        $list = [BulletList]::new($items, $bulletListStyle)

        return $this.AppendBulletList($list)
    }

    [MarkdownBuilder] AppendBulletList(
        [string[]]$items,
        [BulletListStyle]$bulletListStyle,
        [LineEnding]$lineEnding
    ) {
        <#
            .SYNOPSIS
            Appends a bullet list to the MarkdownBuilder.

            .DESCRIPTION
            Appends a bullet list to the MarkdownBuilder. The list is formatted
            and then inserted into the prose, using the current indentation and
            other settings

            .PARAMETER items
            The items to add to the bullet list.

            .PARAMETER bulletListStyle
            The bullet style to use for the bullet list. Valid options include:

            - `[BulletListStyle]::Asterisk` - `*`
            - `[BulletListStyle]::Hyphen` - `-`
            - `[BulletListStyle]::Plus` - `+`

            .PARAMETER lineEnding
            The line ending to use when formatting the bullet list. Valid options include:

            - `[LineEnding]::CR` - `\r`
            - `[LineEnding]::CRLF` - `\r\n`
            - `[LineEnding]::LF` - `\n`
        #>

        $list = [BulletList]::new($items, $bulletListStyle)

        return $this.AppendBulletList($list, $lineEnding)
    }

    [MarkdownBuilder] Append([string]$Content) {
        <#
            .SYNOPSIS
            Appends the specified content to the wrapped StringBuilder.

            .DESCRIPTION
            Appends the specified content to the wrapped StringBuilder. This
            provides a convenient way to append content without having to call
            the Append method on the StringBuilder directly.
        #>

        $this.StringBuilder.Append($Content)

        return $this
    }

    [MarkdownBuilder] AppendLine() {
        <#
            .SYNOPSIS
            Appends a new line to the wrapped StringBuilder.

            .DESCRIPTION
            Appends a new line to the wrapped StringBuilder. This provides a
            convenient way to append a new line without having to call the
            AppendLine method on the StringBuilder directly.
        #>

        return $this.AppendLine($this.DefaultLineEnding)
    }

    [MarkdownBuilder] AppendLine([LineEnding]$LineEnding) {
        <#
            .SYNOPSIS
            Appends a new line to the wrapped StringBuilder.

            .DESCRIPTION
            Appends a new line to the wrapped StringBuilder. This provides a
            convenient way to append a new line without having to call the
            AppendLine method on the StringBuilder directly.
        #>
        $this.StringBuilder.Append($LineEnding.ToString())

        return $this
    }

    [MarkdownBuilder] AppendLine([string]$Content) {
        <#
            .SYNOPSIS
            Appends a new line with the specified content to the wrapped StringBuilder.

            .DESCRIPTION
            Appends a new line with the specified content to the wrapped StringBuilder.
            This provides a convenient way to append a new line without having to call
            the AppendLine method on the StringBuilder directly.
        #>

        $lineContent = (' ' * $this.LeadingSpaceCount) + $Content

        return $this.AppendLine($lineContent, $this.DefaultLineEnding)
    }

    [MarkdownBuilder] AppendLine([string[]]$Content) {
        <#
            .SYNOPSIS
            Appends a new line with the specified content to the wrapped StringBuilder.

            .DESCRIPTION
            Appends a new line with the specified content to the wrapped StringBuilder.
            This provides a convenient way to append a new line without having to call
            the AppendLine method on the StringBuilder directly.
        #>

        return $this.AppendLine($Content, $this.DefaultLineEnding)
    }

    [MarkdownBuilder] AppendLine([string]$Content, [LineEnding]$LineEnding) {
        <#
            .SYNOPSIS
            Appends a new line with the specified content to the wrapped StringBuilder.

            .DESCRIPTION
            Appends a new line with the specified content to the wrapped StringBuilder.
            This provides a convenient way to append a new line without having to call
            the AppendLine method on the StringBuilder directly.
        #>

        foreach ($line in ([MarkdownBuilder]::SplitLines($Content))) {
            $lineContent = (' ' * $this.LeadingSpaceCount) + $line
            $this.StringBuilder.Append($lineContent).Append($LineEnding.ToString())
        }

        return $this
    }

    [MarkdownBuilder] AppendLine([string[]]$Content, [LineEnding]$LineEnding) {
        <#
            .SYNOPSIS
            Appends a new line with the specified content to the wrapped StringBuilder.

            .DESCRIPTION
            Appends a new line with the specified content to the wrapped StringBuilder.
            This provides a convenient way to append a new line without having to call
            the AppendLine method on the StringBuilder directly.
        #>

        foreach ($block in $content) {
            $this.AppendLine($block, $LineEnding)
        }

        return $this
    }

    [string] ToString() {
        <#
            .SYNOPSIS
            Returns the content of the wrapped StringBuilder.

            .DESCRIPTION
            Returns the content of the wrapped StringBuilder. This provides a
            convenient way to get the content of the StringBuilder without
            having to call the ToString method on the StringBuilder directly.

            It also ensures that when you interpolate the MarkdownBuilder object
            in a string, you get the Markdown content instead of the object type.
        #>

        $output = $this.StringBuilder.ToString()

        switch ($this.SpaceMungingOptions.GetFlags()) {
            CollapseStart { $output = $output -replace '^(\r?\n)+', '$1' }
            CollapseEnd { $output = $output -replace '(\r?\n)+$', '$1' }
            CollapseInner { <# Not yet implemented #> }
            TrimStart { $output = $Output.TrimStart() }
            TrimEnd { $output = $Output.TrimEnd() }
        }

        return $output
    }

    static [string[]] SplitLines([string]$content) {
        <#
            .SYNOPSIS
            Splits a string into an array of lines.

            .DESCRIPTION
            Splits a string into an array of lines. This method is used to
            split a string into lines so that you can iterate over them and
            process them individually.

            .PARAMETER content
            The string to split into lines.
        #>

        return (($content -split '\r?\n') -split '\r')
    }
}
