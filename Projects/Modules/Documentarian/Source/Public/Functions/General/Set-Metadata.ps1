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
        $file.Name
        $mdtext = Get-ContentWithoutHeader -Path $file
        Set-Content -Value (hash2yaml $NewMetadata) -Path $file -Force -Encoding utf8
        Add-Content -Value $mdtext -Path $file -Encoding utf8
    }

}
