# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language

Function Get-CbhMemberEntry {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param(
        [Parameter(Mandatory)]
        [CommentHelpInfo]$Help,
        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$Name,
        [Parameter(Mandatory, ParameterSetName = 'ByPattern')]
        [string]$Pattern
    )

    begin {}

    process {
        $Filter = if ($Name) { $_.Key -eq $Name } else { $_.Key -match $Pattern }
        $Help.Parameters.GetEnumerator() |
        Where-Object -FilterScript $Filter |
        ForEach-Object -Process {
            if ($Value = $_.Value) { $Value.Trim() }
        }
    }

    end {}
}
