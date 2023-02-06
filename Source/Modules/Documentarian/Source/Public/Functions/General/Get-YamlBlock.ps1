function Get-YamlBlock {

    [CmdletBinding()]
    param([string]$Path)

    $doc = Get-Content $path -Encoding UTF8
    $hasFrontmatter = Select-String -Pattern '^---$' -Path $path
    $start = 0
    $end = $doc.count

    if ($hasFrontmatter) {
        $start = $hasFrontmatter[0].LineNumber
        $end = $hasFrontmatter[1].LineNumber-2
    }
    $doc[$start..$end]

}
