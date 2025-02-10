# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class HasValidationAttributeInfo {
    [string]$Cmdlet
    [string]$Parameter
    [string]$ParameterType
    [string]$ValidationAttribute
    [string]$ParameterSetName
    [string]$Module

    [string] ToString () {
        return @(
            "$($this.Module)/"
            "$($this.Cmdlet), "
            "Parameter: $($this.Parameter) <"
            "$($this.ParameterType)>, "
            "ValidationAttribute: $($this.ValidationAttribute)"
        ) -join ''
    }
}
