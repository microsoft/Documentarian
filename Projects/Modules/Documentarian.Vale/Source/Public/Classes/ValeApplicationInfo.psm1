# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class ValeApplicationInfo {
    [System.Management.Automation.CommandTypes]
    $CommandType
    [string]
    $Definition
    [string]
    $Extension
    [psmoduleinfo]
    $Module
    [string]
    $ModuleName
    [string]
    $Name
    [System.Collections.ObjectModel.ReadOnlyCollection[System.Management.Automation.PSTypeName]]
    $OutputType
    [System.Collections.Generic.Dictionary[string, System.Management.Automation.ParameterMetadata]]
    $Parameters
    [System.Collections.ObjectModel.ReadOnlyCollection[System.Management.Automation.CommandParameterSetInfo]]
    $ParameterSets
    [string]
    $Path
    [System.Management.Automation.RemotingCapability]
    $RemotingCapability
    [string]
    $Source
    [version]
    $Version
    [System.Management.Automation.SessionStateEntryVisibility]
    $Visibility

    ValeApplicationInfo() {}

    ValeApplicationInfo([System.Management.Automation.ApplicationInfo]$Info) {
        $InfoProperties = $Info
        | Get-Member -MemberType Property
        | Select-Object -ExpandProperty Name
        foreach ($Property in $InfoProperties) {
            $this.$Property = $Info.$Property
        }

        if (($Output = & $Info --version) -match 'vale version (?<VersionString>\S+)') {
            $this.Version = [version]($Matches.VersionString)
        } else {
            throw "Unable to find version string from 'vale --version' output: $Output"
        }
    }

    [string] ToString() {
        return $this.Source
    }
}
