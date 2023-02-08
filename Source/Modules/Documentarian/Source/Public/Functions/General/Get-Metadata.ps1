# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Get-Metadata {

    [CmdletBinding(DefaultParameterSetName = 'AsHash')]
    param(
        [Parameter(ParameterSetName = 'AsHash', Mandatory, Position = 0)]
        [Parameter(ParameterSetName = 'AsObject', Mandatory, Position = 0)]
        [Parameter(ParameterSetName = 'AsYaml', Mandatory, Position = 0)]
        [SupportsWildcards()]
        [string]$Path,

        [Parameter(ParameterSetName = 'AsObject', Mandatory)]
        [switch]$AsObject,

        [Parameter(ParameterSetName = 'AsYaml', Mandatory)]
        [switch]$AsYaml,

        [Parameter(ParameterSetName = 'AsHash')]
        [Parameter(ParameterSetName = 'AsObject')]
        [Parameter(ParameterSetName = 'AsYaml')]
        [switch]$Recurse
    )

    foreach ($file in (Get-ChildItem -Recurse:$Recurse -File -Path $Path)) {
        $ignorelist = 'keywords', 'helpviewer_keywords', 'ms.assetid'
        $lines = Get-YamlHeader $file

        if ($AsYaml) {
            $lines
        } else {
            $meta = @{}
            foreach ($line in $lines) {
                ### Parse the YAML block
                ### This is a naive implementation that only works for simple single-line
                ### YAML data types and has some special cases for the metadata we care
                ### about. It's not intended to be a general purpose solution.
                $i = $line.IndexOf(':')
                if ($i -ne -1) {
                    $key = $line.Substring(0, $i)
                    if (!$ignorelist.Contains($key)) {
                        $value = $line.Substring($i + 1).replace('"', '')
                        switch ($key) {
                            'title' {
                                $value = $value.split('|')[0].Trim()
                            }
                            'ms.date' {
                                [datetime]$date = $value.Trim()
                                $value = Get-Date $date -Format 'MM/dd/yyyy'
                            }
                            Default {
                                $value = $value.Trim()
                            }
                        }

                        $meta.Add($key, $value)
                    }
                }
            }
            if ($AsObject) {
                $meta.Add('file', $file.FullName)
                [pscustomobject]$meta
            } else {
                $meta
            }
        }
    }

}
