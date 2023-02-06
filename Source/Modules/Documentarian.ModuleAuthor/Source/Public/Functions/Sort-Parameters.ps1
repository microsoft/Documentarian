function Sort-Parameters {

    [CmdletBinding()]
    param (
        [Parameter()]
        [SupportsWildcards()]
        [string[]]$Path
    )

    # ----------------------
    function findparams {
        param($matchlist)

        $paramlist = @()

        $inParams = $false
        foreach ($hdr in $matchlist) {
            if ($hdr.Line -eq '## Parameters') {
                $inParams = $true
            }
            if ($inParams) {
                if ($hdr.Line -match '^### -') {
                    $param = [PSCustomObject]@{
                        Name      = $hdr.Line.Trim()
                        StartLine = $hdr.LineNumber - 1
                        EndLine   = -1
                    }
                    $paramlist += $param
                }
                if ((
                        ($hdr.Line -match '^## ' -and $hdr.Line -ne '## Parameters') -or
                        ($hdr.Line -eq '### CommonParameters')
                    ) -and
                    ($paramlist.Count -gt 0)
                ) {
                    $inParams = $false
                    $paramlist[-1].EndLine = $hdr.LineNumber - 2
                }
            }
        }
        if ($paramlist.Count -gt 0) {
            for ($x = 0; $x -lt $paramlist.Count; $x++) {
                if ($paramlist[$x].EndLine -eq -1) {
                    $paramlist[$x].EndLine = $paramlist[($x + 1)].StartLine - 1
                }
            }
        }
        $paramlist
    }
    # ----------------------

    $mdfiles = Get-ChildItem $path

    foreach ($file in $mdfiles) {
        $file.Name
        $mdtext = Get-Content $file -Encoding utf8
        $mdheaders = Select-String -Pattern '^#' -Path $file

        $unsorted = findparams $mdheaders
        if ($unsorted.Count -gt 0) {
            $sorted = $unsorted | Sort-Object Name
            $newtext = $mdtext[0..($unsorted[0].StartLine - 1)]
            $confirmWhatIf = @()
            foreach ($p in $sorted) {
                if ( '### -Confirm', '### -WhatIf' -notcontains $p.Name) {
                    $newtext += $mdtext[$p.StartLine..$p.EndLine]
                }
                else {
                    $confirmWhatIf += $p
                }
            }
            foreach ($p in $confirmWhatIf) {
                $newtext += $mdtext[$p.StartLine..$p.EndLine]
            }
            $newtext += $mdtext[($unsorted[-1].EndLine + 1)..($mdtext.Count - 1)]

            Set-Content -Value $newtext -Path $file.FullName -Encoding utf8 -Force
        }
    }

}
