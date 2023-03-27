# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function GetRefTargets {
    param(
        $refdefs # results from regex match
    )
    $RefTargets = @{}
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
    $RefTargets
}
