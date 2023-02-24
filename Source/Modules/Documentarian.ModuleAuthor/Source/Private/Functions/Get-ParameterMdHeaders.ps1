# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

<#
.SYNOPSIS
Returns a list of parameter headers from a cmdlet markdown file.

.DESCRIPTION
Returns a list of parameter headers from a cmdlet markdown file.

.PARAMETER mdheaders
An array of objects returned by `Select-String -Pattern '^#' -Path $file`

.NOTES
Used by `Update-ParameterOrder` to sort the parameters in a cmdlet markdown file.
#>
function Get-ParameterMdHeaders {
    param($mdheaders)

    $paramlist = @()

    $inParams = $false
    foreach ($hdr in $mdheaders) {
        # Find the start of the parameters section
        if ($hdr.Line -eq '## Parameters') {
            $inParams = $true
        }
        if ($inParams) {
            # Find the start of each parameter
            if ($hdr.Line -match '^### -') {
                $param = [PSCustomObject]@{
                    Line      = $hdr.Line.Trim()
                    StartLine = $hdr.LineNumber - 1
                    EndLine   = -1
                }
                $paramlist += $param
            }
            # Find the end of the last parameter
            if ((($hdr.Line -match '^## ' -and $hdr.Line -ne '## Parameters') -or
                 ($hdr.Line -eq '### CommonParameters')) -and
                ($paramlist.Count -gt 0)) {
                $inParams = $false
                $paramlist[-1].EndLine = $hdr.LineNumber - 2
            }
        }
    }
    # Find the end each last parameter
    if ($paramlist.Count -gt 0) {
        for ($x = 0; $x -lt $paramlist.Count; $x++) {
            if ($paramlist[$x].EndLine -eq -1) {
                $paramlist[$x].EndLine = $paramlist[($x + 1)].StartLine - 1
            }
        }
    }
    $paramlist
}
