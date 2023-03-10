# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class ValeViolationAction {
    [string]$Name
    [string[]]$Parameters

    [string] ToString() {
        if ([string]::IsNullOrEmpty($this.Name)) {
            return ''
        }

        return "$($this.Name) ($($this.Parameters -join ', '))"
    }
}
