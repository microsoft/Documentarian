# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
<#
.SYNOPSIS
Wraps text to a specified line length.

.DESCRIPTION
Wraps text to a specified line length. Useful for formatting descriptions in
markdown files.

.PARAMETER line
The line of text to wrap.

.PARAMETER pad
The number of spaces to indent wrapped lines. Default is 0.

.PARAMETER max
The maximum line length. Default is 79.
#>
function WrapText {
    param(
        [string]$line,
        [uint]$pad = 0,
        [uint]$max = 79
    )
    $lines = @()
    [string[]]$parts = $line -split ' '
    [string]$newLine = ' ' * $pad
    foreach ($p in $parts) {
        if ($newLine.Length + $p.Length + 1 -lt $max) {
            $newLine += "$p "
        } else {
            $lines += $newLine.TrimEnd(' ')
            $newLine = ' ' * $pad + "$p "
        }
    }
    if ($newLine.Trim() -ne '') {
        $lines += $newLine.TrimEnd(' ')
    }
    $lines
}
