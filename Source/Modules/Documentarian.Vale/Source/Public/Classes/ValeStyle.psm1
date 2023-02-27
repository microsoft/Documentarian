# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module .\ValeRule.psm1

class ValeStyle {
    [string]$Name
    [string]$Path
    [ValeRule[]]$Rules

    ValeStyle([string]$Name, [string]$Path) {
        $this.Name = $Name
        $this.Path = $Path
        $this.Rules = @()
    }
}
