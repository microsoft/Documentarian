# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class CredentialAttributeInfo {
    [string]$Cmdlet
    [string]$Parameter
    [string]$ParameterType
    [bool]$IsCredential
    [string]$ParameterSetName
    [string]$Module

    [string] ToString () {
        return @(
            "$($this.Module)/"
            "$($this.Cmdlet), "
            "Parameter: $($this.Parameter) <"
            "$($this.ParameterType)>"
            "IsCredential: $($this.IsCredential)"
        ) -join ''
    }
}
