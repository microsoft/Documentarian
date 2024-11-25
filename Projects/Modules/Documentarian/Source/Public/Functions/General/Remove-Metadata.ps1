# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Remove-Metadata {

    param(
        [Parameter(Mandatory, Position = 0)]
        [SupportsWildcards()]
        [string]$Path,

        [Parameter(Mandatory, Position = 1)]
        [string[]]$KeyName,

        [switch]$Recurse
    )

    foreach ($file in (Get-ChildItem -Path $Path -Recurse:$Recurse)) {

        $doc = Get-Document -Path $file

        foreach ($key in $KeyName) {
            if ($doc.FrontMatter.ContainsKey($key)) {
                $metadata.Remove($key)
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
