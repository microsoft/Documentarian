# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

enum CodeFenceCharacters {
    <#
        .SYNOPSIS
            Defines the characters to use when creating a Markdown code fence.

        .DESCRIPTION
            Defines the characters to use when creating a Markdown code fence. Markdown supports
            two different characters for code fences: backticks and tildes.

        .LABEL Backtick
            Uses backticks to create a code fence. Code fences look like:

            ``````markdown
            ```powershell
            Get-Process
            ```
            ``````

        .LABEL Tilde
            Uses tildes to create a code fence. Code fences look like:

            ``````markdown
            ~~~powershell
            Get-Process
            ~~~
            ``````
    #>

    Backtick = 0
    Tilde    = 1
}
