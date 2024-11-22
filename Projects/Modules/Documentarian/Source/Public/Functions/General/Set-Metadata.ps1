# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Set-Metadata {

    param(
        [Parameter(Mandatory, Position = 0)]
        [SupportsWildcards()]
        [string]$Path,

        [Parameter(Mandatory, Position = 1)]
        [hashtable]$NewMetadata,

        [switch]$Recurse
    )

    foreach ($file in (Get-ChildItem -Path $Path -Recurse:$Recurse)) {
        $header = @(
            '---'
            [environment]::NewLine
            $NewMetadata | ConvertTo-Yaml
            [environment]::NewLine
            '---'
        ) -join ''
        Set-Content -Value $header  -Path $file -Force -Encoding utf8
        Add-Content -Value $doc.Body -Path $file -Encoding utf8
        $file
    }

}
