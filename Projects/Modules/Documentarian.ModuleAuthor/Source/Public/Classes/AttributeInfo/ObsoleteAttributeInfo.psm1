# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class ObsoleteAttributeInfo {
    [string]$Cmdlet
    [string]$Parameter
    [string]$ParameterType
    [bool]$IsObsolete
    [string]$ParameterSetName
    [string]$Module

    [string] ToString () {
        return @(
            "$($this.Module)/"
            "$($this.Cmdlet), "
            "Parameter: $($this.Parameter) <"
            "$($this.ParameterType), >"
            "IsObsolete: $($this.IsObsolete)"
        ) -join ''
    }
}
