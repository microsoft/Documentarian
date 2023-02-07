# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Invoke-Pandoc {

    param(
        [string[]]$Path,
        [string]$OutputPath = '.',
        [switch]$Recurse
    )
    $pandocExe = 'C:\Program Files\Pandoc\pandoc.exe'
    Get-ChildItem $Path -Recurse:$Recurse | ForEach-Object {
        $outfile = Join-Path $OutputPath "$($_.BaseName).help.txt"
        $pandocArgs = @(
            '--from=gfm',
            '--to=plain+multiline_tables',
            '--columns=79',
            "--output=$outfile",
            '--quiet'
        )
        Get-ContentWithoutHeader $_ | & $pandocExe $pandocArgs
    }

}
