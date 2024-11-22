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
        $OldMetadata = $doc.FrontMatter

        $update = $OldMetadata.Clone()
        foreach ($key in $NewMetadata.Keys) {
            if ($update.ContainsKey($key)) {
                $update[$key] = $NewMetadata[$key]
            } else {
                $update.Add($key, $NewMetadata[$key])
            }
        }

        $header = @(
            '---'
            [environment]::NewLine
            $update | ConvertTo-Yaml
            [environment]::NewLine
            '---'
        ) -join ''
        Set-Content -Value $header  -Path $file -Force -Encoding utf8
        Add-Content -Value $doc.Body -Path $file -Encoding utf8
        $file
    }

}
