# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Invoke-Pandoc {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [string[]]$Path,
        [string]$OutputPath = '.',
        [switch]$Recurse
    )
    $pandocExe = Get-Command pandoc.exe # Find pandoc in PATH
    if ($null -eq $pandocExe) {
        Write-Error 'pandoc.exe not found in PATH. See https://pandoc.org/installing.html'
        return
    }
    $pandocArgs = @(
        '--from=gfm',
        '--to=plain+multiline_tables',
        '--columns=79',
        '--quiet'
    )

    if (-not $PSBoundParameters.ContainsKey('Recurse')) {
        $Recurse = $false
    }

    $files = Get-ChildItem $Path -Recurse:$Recurse
    foreach ($f in $files) {
        $outfile = Join-Path $OutputPath "$($f.BaseName).help.txt"
        Write-Verbose "Converting $($f.Name) to $outfile"

        $metadata = Get-Metadata -Path $f
        # Write error and skip if no metadata or no title
        if ($null -eq $metadata) {
            Write-Error "No metadata found in $($f.Name)"
            continue
        }
        if (-not $metadata.Contains('title') -or $metadata.title -eq '') {
            Write-Error "Missing metadata.title in $($f.Name)"
            continue
        }

        $markdown = Get-Content $f

        # Find the short description block and opening lines of the article
        if ($metadata.title -like '*provider') {
            $firstSection = Select-String -Pattern '^## Provider name$' -Path $f
            $startLine = $firstSection[0].LineNumber - 1
            $pattern = '^## (Short|Detailed) Description$'
            $shortBlock = Select-String -Pattern $pattern -Path $f
            $begin = $shortBlock[0].LineNumber
            $end = $shortBlock[1].LineNumber - 2
            $shortDescription = ($markdown[$begin..$end] -join ' ').Trim()
        } else {
            $pattern = '^## (Short|Long) Description$'
            $shortBlock = Select-String -Pattern $pattern -Path $f
            $begin = $shortBlock[0].LineNumber
            $end = $shortBlock[1].LineNumber - 2
            $shortDescription = ($markdown[$begin..$end] -join ' ').Trim()
            $startLine = $shortBlock[1].LineNumber - 1
        }

        $about = $markdown[$startLine..($markdown.Count - 1)] | & $pandocExe @pandocArgs
        $header = @(
            'TOPIC'
            WrapText -line $metadata.title -pad 4
            ''
            'SHORT DESCRIPTION'
            WrapText -line $shortDescription -pad 4
            ''
        )
        $header, $about | Out-File $outfile -Encoding utf8
    }
}
