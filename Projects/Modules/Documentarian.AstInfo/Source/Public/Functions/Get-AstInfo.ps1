# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/AstInfo.psm1

Function Get-AstInfo {
    <#
        .SYNOPSIS
        Gets an AstInfo object from a script block, file, or text.
    #>

    [CmdletBinding()]
    [OutputType([AstInfo])]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ByPath')]
        [ValidatePowerShellScriptPath()]
        [string]$Path,
        [Parameter(Mandatory, ParameterSetName = 'ByScriptBlock')]
        [scriptblock]$ScriptBlock,
        [Parameter(Mandatory, ParameterSetName = 'ByInputText')]
        [ValidateNotNullOrEmpty()]
        [string]$Text
    )

    begin {}

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ByPath' {
                $Path = Resolve-Path -Path $Path -ErrorAction Stop
                [AstInfo]::New($Path)
            }
            'ByScriptBlock' {
                [AstInfo]::New($ScriptBlock)
            }
            'ByInputText' {
                [AstInfo]::New([ScriptBlock]::Create($Text))
            }
        }
    }

    end {}
}
