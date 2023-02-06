function Set-Metadata {

    param(
        [Parameter()]
        [SupportsWildcards()]
        [string]$Path,
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
