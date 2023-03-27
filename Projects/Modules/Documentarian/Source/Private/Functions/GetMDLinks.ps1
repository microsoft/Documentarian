# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function GetMDLinks {
    param(
        $mdlinks, # results from regex match
        $reflinks  # results from regex match
    )
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
