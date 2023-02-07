# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Get-HtmlMetaTags {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [uri]$ArticleUrl,

        [switch]$ShowRequiredMetadata
    )

    $hash = [ordered]@{}

    $x = Invoke-WebRequest $ArticleUrl
    $lines = (($x -split "`n").trim() | Select-String -Pattern '\<meta').line | ForEach-Object {
        $_.trimstart('<meta ').trimend(' />') | Sort-Object
    }
    $pattern = '(name|property)="(?<key>[^"]+)"\s*content="(?<value>[^"]+)"'
    foreach ($line in $lines) {
        if ($line -match $pattern) {
            if ($hash.Contains($Matches.key)) {
                $hash[($Matches.key)] += ',' + $Matches.value
            }
            else {
                $hash.Add($Matches.key, $Matches.value)
            }
        }
    }

    $result = New-Object -type psobject -prop ($hash)
    if ($ShowRequiredMetadata) {
        $result | Select-Object title, 'og:title', description, 'ms.manager', 'ms.author', author, 'ms.service', 'ms.date', 'ms.topic', 'ms.subservice', 'ms.prod', 'ms.technology', 'ms.custom', 'ROBOTS'
    }
    else {
        $result
    }

}
