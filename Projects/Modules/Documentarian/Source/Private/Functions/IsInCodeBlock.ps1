# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function IsInCodeBlock {
    param(
        $linenumber,
        $codefences
    )
    foreach ($fence in $codefences) {
        if ($linenumber -ge $fence.Start -and $linenumber -le $fence.End) {
            return $true
        }
    }
    return $false

}
