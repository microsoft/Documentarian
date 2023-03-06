# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Convert-MDLinks {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]]$Path,

        [switch]$PassThru
    )

    $mdlinkpattern = '[\s\n]+(?<link>!?\[(?<label>[^\]]*)\]\((?<target>[^\)]+)\))[\s\n]?'
    $reflinkpattern = '[\s\n]+(?<link>!?\[(?<label>[^\]]*)\]\[(?<ref>[^\[\]]+)\])[\s\n]?'
    $refpattern = '^(?<refdef>\[(?<ref>[^\[\]]+)\]:\s(?<target>.+))$'

    $Path = Get-Item $Path # resolve wildcards

    foreach ($filename in $Path) {
        $mdfile = Get-Item $filename

        $mdlinks = Get-Content $mdfile -Raw | Select-String -Pattern $mdlinkpattern -AllMatches
        $reflinks = Get-Content $mdfile -Raw | Select-String -Pattern $reflinkpattern -AllMatches
        $refdefs = Select-String -Path $mdfile -Pattern $refpattern -AllMatches

        Write-Verbose ('{0}/{1}: {2} links' -f $mdfile.Directory.Name, $mdfile.Name, $mdlinks.count)
        Write-Verbose ('{0}/{1}: {2} ref links' -f $mdfile.Directory.Name, $mdfile.Name, $reflinks.count)
        Write-Verbose ('{0}/{1}: {2} ref defs' -f $mdfile.Directory.Name, $mdfile.Name, $refdefs.count)

        function GetMDLinks {
            foreach ($mdlink in $mdlinks.Matches) {
                # Skip INCLUDE and tab links
                if (-not $mdlink.Value.Trim().StartsWith('[!INCLUDE') -and
                    -not $mdlink.Value.Trim().Contains('#tab/')
                ) {
                    $linkitem = [pscustomobject]([ordered]@{
                            mdlink = ''
                            target = ''
                            ref    = ''
                            label  = ''
                        })
                    switch ($mdlink.Groups) {
                        { $_.Name -eq 'link' } { $linkitem.mdlink = $_.Value }
                        { $_.Name -eq 'target' } { $linkitem.target = $_.Value }
                        { $_.Name -eq 'label' } { $linkitem.label = $_.Value }
                    }
                    $linkitem
                }
            }

            foreach ($reflink in $reflinks.Matches) {
                if (-not $reflink.Value.Trim().StartsWith('[!INCLUDE')) {
                    $linkitem = [pscustomobject]([ordered]@{
                            mdlink = ''
                            target = ''
                            ref    = ''
                            label  = ''
                        })
                    switch ($reflink.Groups) {
                        { $_.Name -eq 'link' } { $linkitem.mdlink = $_.Value }
                        { $_.Name -eq 'label' } { $linkitem.label = $_.Value }
                        { $_.Name -eq 'ref' } { $linkitem.ref = $_.Value }
                    }
                    $linkitem
                }
            }
        }
        function GetRefTargets {
            foreach ($refdef in $refdefs.Matches) {
                $refitem = [pscustomobject]([ordered]@{
                        refdef = ''
                        target = ''
                        ref    = ''
                    })

                switch ($refdef.Groups) {
                    { $_.Name -eq 'refdef' } { $refitem.refdef = $_.Value }
                    { $_.Name -eq 'target' } { $refitem.target = $_.Value }
                    { $_.Name -eq 'ref' } { $refitem.ref = $_.Value }
                }
                if (!$RefTargets.ContainsKey($refitem.ref)) {
                    $RefTargets.Add(
                        $refitem.ref,
                        [pscustomobject]@{
                            target = $refitem.target
                            ref    = $refitem.ref
                            refdef = $refitem.refdef
                        }
                    )
                }
            }
        }

        $linkdata = GetMDLinks
        $RefTargets = @{}; GetRefTargets

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
            $newlinks += '[{0:d2}]: {1}' -f ($targets.IndexOf($linkdata[$x].target) + 1), $linkdata[$x].target

            $parms = @{
                InputObject = $linkdata[$x]
                MemberType  = 'NoteProperty'
                Name        = 'newlink'
                Value       = '{0}[{1}][{2:d2}]' -f $bang, $linkdata[$x].label, ($targets.IndexOf($linkdata[$x].target) + 1)
            }
            Add-Member @parms
        }

        $mdtext = Get-Content $mdfile
        foreach ($link in $linkdata) {
            $mdtext = $mdtext -replace [regex]::Escape($link.mdlink), $link.newlink
        }
        $mdtext += '<!-- updated link references -->'
        $mdtext += $newlinks | Sort-Object -Unique
        if ($PassThru) {
            $linkdata
        } else {
            Set-Content -Path $mdfile -Value $mdtext -Encoding utf8 -Force
        }
    }

}
