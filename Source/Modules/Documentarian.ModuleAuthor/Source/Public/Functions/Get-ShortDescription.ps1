# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Get-ShortDescription {

    $crlf = "`r`n"
    Get-ChildItem *.md | ForEach-Object {
        if ($_.directory.basename -ne $_.basename) {
            $filename = $_.Name
            $name = $_.BaseName
            $headers = Select-String -Path $filename -Pattern '^## \w*' -AllMatches
            $mdtext = Get-Content $filename
            $start = $headers[0].LineNumber
            $end = $headers[1].LineNumber - 2
            $short = $mdtext[($start)..($end)] -join ' '
            if ($short -eq '') { $short = '{{Placeholder}}' }

            '### [{0}]({1}){3}{2}{3}' -f $name, $filename, $short.Trim(), $crlf
        }
    }

}
