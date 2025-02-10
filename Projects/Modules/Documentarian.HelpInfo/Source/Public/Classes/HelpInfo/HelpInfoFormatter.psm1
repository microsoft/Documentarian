# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ./BaseHelpInfo.psm1

class HelpInfoFormatter {
    [scriptblock]
    $ScriptBlock = {
        param (
            [BaseHelpInfo] $helpInfo
        )

        throw 'HelpInfoFormmater.ScriptBlock must be defined.'
    }

    [hashtable]
    $Parameters  = @{}

    HelpInfoFormatter() {}

    HelpInfoFormatter([scriptblock]$scriptBlock) {
        $this.ScriptBlock = $scriptBlock
    }

    [void] ValidateScriptBlock() {
        <#
        .SYNOPSIS
            Validates the script block for the HelpInfoFormatter.
        .DESCRIPTION
            Validates the script block for the HelpInfoFormatter. Every formatter must define a
            script block. The scriptblock must have a parameter named `HelpInfo` that accepts
            the object to format. It may have other parameters, but `HelpInfo` is required.
        .EXCEPTION System.MissingMemberException
            Thrown if the script block is not defined for the formatter.
        .EXCEPTION System.Management.Automation.ParameterBindingException
            Thrown if the script block does not have a parameter named `HelpInfo`.
        #>
        if ($null -eq $this.ScriptBlock) {
            throw [System.MissingMemberException]::new(
                'HelpInfoFormatter.ScriptBlock must be defined.'
            )
        }

        $DefinedParameters = $this.ScriptBlock.Ast.ParamBlock.Parameters.ForEach{
            $_.Name.ToString()
        }

        if ('$HelpInfo' -notin $DefinedParameters) {
            $Message = @(
                "Invalid HelpInfoFormatter.ScriptBlock: missing parameter 'HelpInfo'."
                "The 'HelpInfo' parameter passes the object to format."
            ) -join ' '
            throw [System.Management.Automation.ParameterBindingException]::new($Message)
        }
    }

    [string] Format([BaseHelpInfo]$helpInfo) {
        $this.ValidateScriptBlock()

        $this.Parameters['HelpInfo'] = $helpInfo
        $ParametersHash              = $this.Parameters

        return (& $this.ScriptBlock @ParametersHash)
    }

    static [string] Format([HelpInfoFormatter]$formatter, [BaseHelpInfo]$helpInfo) {
        return $formatter.Format($helpInfo)
    }

    [string] FormatSection([BaseHelpInfo[]]$helpInfo) {
        $this.ValidateScriptBlock()

        $this.Parameters['HelpInfo'] = $helpInfo
        $ParametersHash              = $this.Parameters

        return (& $this.ScriptBlock @ParametersHash)
    }

    static [string] FormatSection([HelpInfoFormatter]$formatter, [BaseHelpInfo[]]$helpInfo) {
        return $formatter.Format($helpInfo)
    }
}
