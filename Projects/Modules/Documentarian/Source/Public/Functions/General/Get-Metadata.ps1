# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Get-Metadata {

    [CmdletBinding(DefaultParameterSetName = 'AsHash')]
    param(
        [Parameter(ParameterSetName = 'AsHash', Mandatory, Position = 0)]
        [Parameter(ParameterSetName = 'AsJson', Mandatory, Position = 0)]
        [Parameter(ParameterSetName = 'AsObject', Mandatory, Position = 0)]
        [Parameter(ParameterSetName = 'AsYaml', Mandatory, Position = 0)]
        [SupportsWildcards()]
        [string]$Path,

        [Parameter(ParameterSetName = 'AsJson', Mandatory)]
        [switch]$AsJson,

        [Parameter(ParameterSetName = 'AsObject', Mandatory)]
        [switch]$AsObject,

        [Parameter(ParameterSetName = 'AsYaml', Mandatory)]
        [switch]$AsYaml,

        [Parameter(ParameterSetName = 'AsHash')]
        [Parameter(ParameterSetName = 'AsJson')]
        [Parameter(ParameterSetName = 'AsObject')]
        [Parameter(ParameterSetName = 'AsYaml')]
        [switch]$Recurse
    )

    foreach ($file in (Get-ChildItem -Recurse:$Recurse -File -Path $Path)) {
        $doc = Get-Document -Path $file.FullName
        if ($AsObject) {
            [pscustomobject]$doc.FrontMatter
        } elseif ($AsJson) {
            $doc.FrontMatter | ConvertTo-Json
        } elseif ($AsYaml) {
            $doc.FrontMatter | YaYaml\ConvertTo-Yaml
        } else {
            $doc.FrontMatter
        }
    }
}
