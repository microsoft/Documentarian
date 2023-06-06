# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class PSDefaultValueAttributeInfo {
    [string]$Cmdlet
    [string]$Parameter
    [string]$ParameterType
    [string]$DefaultValue
    [string]$ParameterSetName
    [string]$Module

    [string] ToString () {
        return @(
            "$($this.Module)/"
            "$($this.Cmdlet), "
            "Parameter: $($this.Parameter) <"
            "$($this.ParameterType), >"
            "DefaultValue: $($this.DefaultValue)"
        ) -join ''
    }
}
