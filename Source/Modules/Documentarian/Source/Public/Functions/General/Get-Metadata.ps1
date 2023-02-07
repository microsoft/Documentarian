# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Get-Metadata {

    [CmdletBinding()]
    param(
        [Parameter()]
        [SupportsWildcards()]
        [string]$Path,
        [switch]$Recurse,
        [switch]$AsObject
    )

    foreach ($file in (Get-ChildItem -Recurse:$Recurse -File -Path $Path)) {
        $ignorelist = 'keywords', 'helpviewer_keywords', 'ms.assetid'
        $lines = Get-YamlBlock $file
        $meta = @{}

        ### Parse the YAML block
        ### This is a naive implementation that only works for simple single-line YAML data types
        ### and has some special cases for the metadata we care about. It's not intended to be a
        ### general purpose.

        foreach ($line in $lines) {
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
        }
        else {
            $meta
        }
    }

}
