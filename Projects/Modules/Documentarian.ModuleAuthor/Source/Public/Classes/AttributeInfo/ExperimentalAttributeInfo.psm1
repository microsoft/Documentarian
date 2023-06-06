# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class ExperimentalAttributeInfo {
    [string]$Cmdlet
    [string]$Parameter
    [string]$ParameterType
    [string]$ExperimentName
    [string]$ParameterSetName
    [string]$Module

    [string] ToString () {
        return @(
            "$($this.Module)/"
            "$($this.Cmdlet), "
            "Parameter: $($this.Parameter) <"
            "$($this.ParameterType)>, "
            "Experiment: $($this.ExperimentName)"
        ) -join ''
    }
}
