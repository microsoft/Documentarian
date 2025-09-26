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

    # Initialize recurse parameter if not specified
    if (-not $PSBoundParameters.ContainsKey('Recurse')) {
        $Recurse = $false
    }

    # Ensure pandoc is available
    $pandocExe = Get-Command pandoc.exe
    if ($null -eq $pandocExe) {
        Write-Error 'pandoc.exe not found in PATH. See https://pandoc.org/installing.html'
        return
    }

    # Define Pandoc template, filter, and arguments
    $aboutTemplate = @(
        'TOPIC'
        '    $title$'
        ''
        'SYNOPSIS'
        '    $description$'
        ''
        '$body$'
    ) -join [Environment]::NewLine

    $luaFilter = @(
        'function Header(elem)'
        '    local text = pandoc.utils.stringify(elem.content)'
        '    local underline_char = { "=", "=" }'
        '    local level = elem.level'
        '    local underline = string.rep(underline_char[level] or "-", #text)'
        '    return pandoc.Para{pandoc.Str(text), pandoc.LineBreak(), pandoc.Str(underline)}'
        'end'
    ) -join [Environment]::NewLine

    $templatePath = "$env:TEMP\pandoc-template.txt"
    $luaFilterPath = "$env:TEMP\pandoc-filter.lua"
    $pandocArgs = @(
        '--from=gfm',
        '--to=plain+multiline_tables-yaml_metadata_block',
        "--lua-filter=$luaFilterPath",
        "--template=$templatePath",
        '--columns=79',
        '--quiet'
    )
    Write-Verbose "Pandoc: $($pandocExe.Source)"
    Write-Verbose "Args: $($pandocArgs -join ' ')"

    # Create Pandoc assets
    $aboutTemplate | Out-File $templatePath -Encoding utf8
    $luaFilter | Out-File $luaFilterPath -Encoding utf8

    # Process files
    $files = Get-ChildItem $Path -Recurse:$Recurse
    foreach ($f in $files) {
        $outfile = Join-Path $OutputPath "$($f.BaseName).help.txt"
        Write-Verbose "Converting $($f.Name) to $outfile"

        $metadata = Get-Metadata -Path $f
        if ($null -eq $metadata) {
            Write-Error "No metadata found in $($f.Name)"
            continue # Skip to next file
        }
        if (-not $metadata.Contains('title') -or $metadata.title -eq '') {
            Write-Error "Missing metadata.title in $($f.Name)"
            continue # Skip to next file
        }
        if (-not $metadata.Contains('description') -or $metadata.description -eq '') {
            Write-Error "Missing metadata.description in $($f.Name)"
            continue # Skip to next file
        }

        # Remove H1 from markdown content
        $markdown = (Get-Content $f -Raw) -replace "# $($metadata.title)\r?\n", ''

        $markdown | & $pandocExe @pandocArgs | Out-File $outfile -Encoding utf8
    }
}
