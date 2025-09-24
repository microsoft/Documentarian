# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Get-ContentWithoutHeader {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Path
    )

    $doc = Get-Content $path -Encoding UTF8
    $hasFrontmatter = Select-String -Pattern '^---$' -Path $path
    if ($hasFrontmatter.Count -gt 1) {
        $start = 0
        $end = $doc.count

        if ($hasFrontmatter) {
            $start = $hasFrontmatter[1].LineNumber
        }
        $doc[$start..$end]
    } else {
        Write-Error "Invalid frontmatter in $Path"
    }
}
