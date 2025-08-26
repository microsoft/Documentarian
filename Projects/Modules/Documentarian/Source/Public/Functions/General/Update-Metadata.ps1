# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Update-Metadata {

    param(
        [Parameter(Mandatory, Position = 0)]
        [SupportsWildcards()]
        [string]$Path,

        [Parameter(Mandatory, Position = 1)]
        [hashtable]$NewMetadata,

        [switch]$Recurse
    )

    foreach ($file in (Get-ChildItem -Path $Path -Recurse:$Recurse)) {
        $doc = Get-Document -Path $file
        if ($null -eq $doc.FrontMatter) {
            $doc.FrontMatter = [ordered]@{}
        }

        foreach ($key in $NewMetadata.Keys) {
            if ($doc.FrontMatter.Keys -contains $key) {
                $doc.FrontMatter[$key] = $NewMetadata[$key]
            } else {
                $doc.FrontMatter.Add($key, $NewMetadata[$key])
            }
        }

        $header = @(
            '---'
            [environment]::NewLine
            $doc.FrontMatter | ConvertTo-Yaml
            [environment]::NewLine
            '---'
        ) -join ''
        Set-Content -Value $header  -Path $file -Force -Encoding utf8
        Add-Content -Value $doc.Body -Path $file -Encoding utf8
        $file
    }

}
