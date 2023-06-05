# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ./CodeFenceCharacter.psm1
using module ./LineEnding.psm1

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

    # The default length of code fences.
    [ValidateRange(3, [int]::MaxValue)]
    [int]
    $DefaultFenceLength = 3

    # The default line ending to use when appending lines.
    [LineEnding]
    $DefaultLineEnding

    MarkdownBuilder() {
        <#
            .SYNOPSIS
            Creates a new MarkdownBuilder object.
            .DESCRIPTION
            Creates a new MarkdownBuilder object with an empty StringBuilder and
            default options.
        #>

        $this.StringBuilder = [System.Text.StringBuilder]::new()
        $this.Fences = [System.Collections.Generic.Dictionary[int, string]]::new()
        $this.DefaultLineEnding = [LineEnding]::new()
        $this.DefaultFenceCharacter = [CodeFenceCharacter]::new()
    }

    MarkdownBuilder([LineEnding]$defaultLineEnding) {
        <#
            .SYNOPSIS
            Creates a new MarkdownBuilder object.
            .DESCRIPTION
            Creates a new MarkdownBuilder object with an empty StringBuilder and
            specified default line ending. All other options are default.
        #>

        $this.StringBuilder = [System.Text.StringBuilder]::new()
        $this.Fences = [System.Collections.Generic.Dictionary[int, string]]::new()
        $this.DefaultLineEnding = $defaultLineEnding
        $this.DefaultFenceCharacter = [CodeFenceCharacter]::new()
    }

    MarkdownBuilder([string]$content) {
        <#
            .SYNOPSIS
            Creates a new MarkdownBuilder object with the specified content.

            .DESCRIPTION
            Creates a new MarkdownBuilder object with the specified content and
            default options.
        #>

        $this.StringBuilder = [System.Text.StringBuilder]::new($content)
        $this.Fences = [System.Collections.Generic.Dictionary[int, string]]::new()
        $this.DefaultLineEnding = [LineEnding]::new()
        $this.DefaultFenceCharacter = [CodeFenceCharacter]::new()
    }

    MarkdownBuilder([System.Text.StringBuilder]$builder) {
        <#
            .SYNOPSIS
            Creates a new MarkdownBuilder object from the specified StringBuilder.

            .DESCRIPTION
            Creates a new MarkdownBuilder object from the specified StringBuilder
            and with default options.
        #>

        $this.StringBuilder = $builder
        $this.Fences = [System.Collections.Generic.Dictionary[int, string]]::new()
        $this.DefaultLineEnding = [LineEnding]::new()
        $this.DefaultFenceCharacter = [CodeFenceCharacter]::new()
    }

    MarkdownBuilder([string]$content, [LineEnding]$defaultLineEnding) {
        <#
            .SYNOPSIS
            Creates a new MarkdownBuilder object.
            .DESCRIPTION
            Creates a new MarkdownBuilder object with the specified content and
            default line ending. All other options are default.
        #>

        $this.StringBuilder = [System.Text.StringBuilder]::new($content)
        $this.Fences = [System.Collections.Generic.Dictionary[int, string]]::new()
        $this.DefaultLineEnding = $defaultLineEnding
        $this.DefaultFenceCharacter = [CodeFenceCharacter]::new()
    }

    MarkdownBuilder([System.Text.StringBuilder]$builder, [LineEnding]$defaultLineEnding) {
        <#
            .SYNOPSIS
            Creates a new MarkdownBuilder object.
            .DESCRIPTION
            Creates a new MarkdownBuilder object with the specified string
            builder and default line ending. All other options are default.
        #>

        $this.StringBuilder = $builder
        $this.Fences = [System.Collections.Generic.Dictionary[int, string]]::new()
        $this.DefaultLineEnding = $defaultLineEnding
        $this.DefaultFenceCharacter = [CodeFenceCharacter]::new()
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
        $this.StringBuilder.Append($Content).Append($LineEnding.ToString())

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
        return $this.StringBuilder.ToString()
    }
}
