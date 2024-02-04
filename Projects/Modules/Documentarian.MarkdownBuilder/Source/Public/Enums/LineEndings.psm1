# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

enum LineEndings {
    <#
        .SYNOPSIS
            Defines the line endings to use when writing Markdown prose.

        .DESCRIPTION
            Defines the line endings to use when writing Markdown prose. Markdown supports three
            different line endings: carriage return, line feed, and carriage return and line feed.

        .LABEL CR
            Carriage return line ending, maps to `\r`.

        .LABEL LF
            Line feed line ending, maps to `\n`.

        .LABEL CRLF
            Carriage return and line feed line ending, maps to `\r\n`.
    #>

    CR   = 1
    LF   = 2
    CRLF = 3
}
