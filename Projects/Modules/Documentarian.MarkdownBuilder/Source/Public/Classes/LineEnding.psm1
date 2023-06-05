# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Enums/LineEndings.psm1

class LineEnding {
    # The line ending character flags, any combination of `CR` and `LF`.
    [LineEndings] $Value = [LineEndings]::LF

    LineEnding() {
        <#
            .SYNOPSIS
            Creates a new LineEnding object with LF as the line ending.

            .DESCRIPTION
            Creates a new LineEnding object with LF as the line ending.
        #>

        $this.Value = [LineEndings]::LF
    }

    LineEnding([LineEndings] $lineEnding) {
        <#
            .SYNOPSIS
            Creates a new LineEnding object with the specified line ending.

            .DESCRIPTION
            Creates a new LineEnding object with the specified line ending. If you
            specify multiple line endings, they're combined into a single line ending.

            .PARAMETER LineEndings
            The line ending characters to use. `CR` is carriage return, `LF` is line feed, and
            `CRLF` is carriage return and line feed.
        #>

        $this.Value = $lineEnding
    }

    LineEnding([string] $lineEnding) {
        <#
            .SYNOPSIS
            Creates a new LineEnding object with the specified line ending.
            .DESCRIPTION
            Creates a new LineEnding object with the specified line ending. You can
            specify the line ending as a string, such as `CR`, `LF`, or `CRLF`. You can also
            specify the line ending as a literal string, such as "`r", "`n", or "`r`n".

            .PARAMETER LineEndings
            The line ending characters to use. You specify the shorthand string, the literal
            string, or regex string for a line ending.

            Valid options are listed in the table below:

            |            Name             | Shorthand String | Literal String | Regex String |
            | :-------------------------- | :--------------: | :------------: | :----------: |
            | Carriage Return             |       `CR`       |    `` `r ``    |     `\r`     |
            | Line Feed                   |       `LF`       |    `` `n ``    |     `\n`     |
            | Carriage Return + Line Feed |      `CRLF`      |   `` `r`n ``   |    `\r\n`    |

            .EXAMPLE
            This example shows using the shorthand strings to create line ending objects.

            ```powershell
            [LineEnding]::new('CR').ToString() | ConvertTo-Json
            [LineEnding]::new('CRLF').ToString() | ConvertTo-Json
            [LineEnding]::new('LF').ToString() | ConvertTo-Json
            ```

            ```output
            "\r"
            "\r\n"
            "\n"
            ```
            .EXAMPLE
            This example shows passing literal line endings to create line ending objects.

            ```powershell
            [LineEnding]::new("`r").ToString() | ConvertTo-Json
            [LineEnding]::new("`r`n").ToString() | ConvertTo-Json
            [LineEnding]::new("`n").ToString() | ConvertTo-Json
            ```

            ```output
            "\r"
            "\r\n"
            "\n"
            ```
        #>
        switch ($lineEnding) {
            { $lineEnding -in @('CR', "`r", '`r', '\r') } {
                $this.Value = [LineEndings]::CR
            }

            { $lineEnding -in @('LF', "`n", '`n', '\n') } {
                $this.Value = [LineEndings]::LF
            }

            { $lineEnding -in @('CRLF', "`r`n", '`r`n', '\r\n') } {
                $this.Value = [LineEndings]::CRLF
            }

            default {
                $Message = @(
                    "Specified invalid line ending character(s) '$lineEnding'"
                    'Valid values are: "LF", "CR", "CRLF", "`n", "`r", "`r`n", "\n", "\r", "\r\n"'
                ) -join ' - '

                throw [System.ArgumentException]::new($Message)
            }
        }
    }

    [string] ToString() {
        <#
            .SYNOPSIS
            Outputs the line ending as a string.
            .DESCRIPTION
            Outputs the line ending as a string. If the line ending is CR, it outputs "`r". If the
            line ending is LF, it outputs "`n". If the line ending is CRLF, it outputs "`r`n".
        #>

        switch ($this.Value) {
            CR {
                return "`r"
            }

            LF {
                return "`n"
            }

            CRLF {
                return "`r`n"
            }
        }

        throw [System.InvalidOperationException]::new(
            "Invalid line ending value '$($this.Value)'"
        )
    }
}
