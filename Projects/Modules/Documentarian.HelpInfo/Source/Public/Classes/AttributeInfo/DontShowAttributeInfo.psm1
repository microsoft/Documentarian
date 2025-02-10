# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class DontShowAttributeInfo {
    [string] $Cmdlet
    [string] $Parameter
    [string] $ParameterType
    [bool]   $DontShow
    [string] $ParameterSetName
    [string] $Module

    [string] ToString () {
        return @(
            "$($this.Module)/"
            "$($this.Cmdlet), "
            "Parameter: $($this.Parameter) <"
            "$($this.ParameterType)>, "
            "DontShow: $($this.DontShow)"
        ) -join ''
    }
}
