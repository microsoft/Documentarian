function Update-Headings {

    param(
        [Parameter(Mandatory)]
        [SupportsWildcards()]
        [string]$Path,
        [switch]$Recurse
    )
    $headings = '## Synopsis', '## Syntax', '## Description', '## Examples', '## Parameters',
                '### CommonParameters', '## Inputs', '## Outputs', '## Notes', '## Related links',
                '## Short description', '## Long description', '## See also'

    Get-ChildItem $Path -Recurse:$Recurse | ForEach-Object {
        $_.name
        $md = Get-Content -Encoding utf8 -Path $_
        foreach ($h in $headings) {
            $md = $md -replace "^$h$", $h
        }
        Set-Content -Encoding utf8 -Value $md -Path $_ -Force
    }

}
