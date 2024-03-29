# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
    $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
    Resolve-Path -Path "$SourceFolder/Private/Functions/GetMDLinks.ps1"
    Resolve-Path -Path "$SourceFolder/Private/Functions/GetRefTargets.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
    . $RequiredFunction
}

#endregion RequiredFunctions

function Convert-MDLinks {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [SupportsWildcards()]
        [string[]]$Path,

        [switch]$PassThru
    )

    $mdlinkpattern = '[\s\n]*(?<link>!?\[(?<label>[^\]]*)\]\((?<target>[^\)]+)\))[\s\n]?'
    $reflinkpattern = '[\s\n]*(?<link>!?\[(?<label>[^\]]*)\]\[(?<ref>[^\[\]]+)\])[\s\n]?'
    $refpattern = '^(?<refdef>\[(?<ref>[^\[\]]+)\]:\s(?<target>.+))$'

    $Path = Get-Item $Path # resolve wildcards

    foreach ($filename in $Path) {
        $mdfile = Get-Item $filename

        $mdlinks = Get-Content $mdfile -Raw | Select-String -Pattern $mdlinkpattern -AllMatches
        $reflinks = Get-Content $mdfile -Raw | Select-String -Pattern $reflinkpattern -AllMatches
        $refdefs = Select-String -Path $mdfile -Pattern $refpattern -AllMatches

        Write-Verbose ('{0}/{1}: {2} links' -f $mdfile.Directory.Name, $mdfile.Name, $mdlinks.Matches.count)
        Write-Verbose ('{0}/{1}: {2} ref links' -f $mdfile.Directory.Name, $mdfile.Name, $reflinks.Matches.count)
        Write-Verbose ('{0}/{1}: {2} ref defs' -f $mdfile.Directory.Name, $mdfile.Name, $refdefs.Matches.count)

        $linkdata = GetMDLinks $mdlinks $reflinks
        $RefTargets = GetRefTargets $refdefs

        # map targets by reference
        if ($RefTargets.Count -gt 0) {
            for ($x = 0; $x -lt $linkdata.Count; $x++) {
                foreach ($key in $RefTargets.Keys) {
                    if ($RefTargets[$key].ref -eq $linkdata[$x].ref) {
                        $linkdata[$x].target = $RefTargets[$key].target
                    }
                }
            }
        }

        # Get unique list of targets
        $targets = $linkdata.target + $RefTargets.Values.target | Sort-Object -Unique

        # Calculate new links and references
        $newlinks = @()
        for ($x = 0; $x -lt $linkdata.Count; $x++) {
            if ($linkdata[$x].mdlink.StartsWith('!')) {
                $bang = '!'
            } else {
                $bang = ''
            }
            if ($linkdata[$x].target -match 'https://github.com/\w+/\w+/(pull|issues)/(?<linkid>\d+)$') {
                $linkid = $matches.linkid
                $linkdata[$x].ref = '{0:d2}' -f $linkid
                $newlinks += '[{0}]: {1}' -f $linkid, $linkdata[$x].target
                $newlink = '[{0}][{1}]' -f $linkdata[$x].label, $linkid
            } else {
                $linkid = $targets.IndexOf($linkdata[$x].target) + 1
                $linkdata[$x].ref = '{0:d2}' -f $linkid
                $newlinks += '[{0:d2}]: {1}' -f $linkid, $linkdata[$x].target
                $newlink = '{0}[{1}][{2:d2}]' -f $bang, $linkdata[$x].label, $linkid
            }

            $parms = @{
                InputObject = $linkdata[$x]
                MemberType  = 'NoteProperty'
                Name        = 'newlink'
                Value       = $newlink
            }
            Add-Member @parms
        }

        Write-Verbose (($newlinks | Sort-Object -Unique) -join "`n")

        $mdtext = Get-Content $mdfile
        foreach ($link in $linkdata) {
            $mdtext = $mdtext -replace [regex]::Escape($link.mdlink), $link.newlink
        }
        if ($PassThru) {
            $linkdata
        } else {
            $mdtext += '<!-- updated link references -->'
            $mdtext += $newlinks | Sort-Object -Unique
            Set-Content -Path $mdfile -Value $mdtext -Encoding utf8 -Force
        }
    }

}
