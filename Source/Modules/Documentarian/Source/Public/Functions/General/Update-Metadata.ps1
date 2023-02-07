# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Update-Metadata {

    param(
        [Parameter()]
        [SupportsWildcards()]
        [string]$Path,
        [hashtable]$NewMetadata,
        [switch]$Recurse
    )

    foreach ($file in (Get-ChildItem -Path $Path -Recurse:$Recurse)) {
        $file.name
        $OldMetadata = Get-Metadata -Path $file
        $mdtext = Get-ContentWithoutHeader -path $file

        $update = $OldMetadata.Clone()
        foreach ($key in $NewMetadata.Keys) {
            if ($update.ContainsKey($key)) {
                $update[$key] = $NewMetadata[$key]
            }
            else {
                $update.Add($key, $NewMetadata[$key])
            }
        }

        Set-Content -Value (hash2yaml $update) -Path $file -Force -Encoding utf8
        Add-Content -Value $mdtext -Path $file -Encoding utf8
    }

}
