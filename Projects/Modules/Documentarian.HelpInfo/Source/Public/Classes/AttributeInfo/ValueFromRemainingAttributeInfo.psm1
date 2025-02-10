# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class ValueFromRemainingAttributeInfo {
    [string]$Cmdlet
    [string]$Parameter
    [string]$ParameterType
    [bool]$ValueFromRemaining
    [string]$ParameterSetName
    [string]$Module

    [string] ToString () {
        return @(
            "$($this.Module)/"
            "$($this.Cmdlet), "
            "Parameter: $($this.Parameter) <"
            "$($this.ParameterType)>, "
            "ValueFromRemaining: $($this.ValueFromRemaining)"
        ) -join ''
    }
}
