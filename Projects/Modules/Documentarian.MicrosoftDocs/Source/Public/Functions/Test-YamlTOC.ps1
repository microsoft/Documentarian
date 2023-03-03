# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Test-YamlTOC {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Path
    )

    $toc = Get-Item $Path
    $basepath = "$($toc.Directory)\"

    $hrefs = (Select-String -Pattern '\s*href:\s+([\w\-\._/]+)\s*$' -Path $toc.FullName).Matches |
        ForEach-Object { $_.Groups[1].Value } |
        Sort-Object

    $hrefs | ForEach-Object {
        $file = $basepath + ($_ -replace '/', '\')
        if (-not (Test-Path $file)) {
            "File does not exist - $_"
        }
    }

    $files = Get-ChildItem $basepath\*.md, $basepath\*.yml -Recurse -File |
        Where-Object Name -NE 'toc.yml'

    $files.FullName | ForEach-Object {
        $file = ($_ -replace [regex]::Escape($basepath)) -replace '\\', '/'
        if ($hrefs -notcontains $file) {
            "File not in TOC - $file"
        }
    }

}
