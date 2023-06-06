# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using module ../../../Public/Classes/HelpInfo/OverloadExceptionHelpInfo.psm1

function Resolve-OverloadExceptionHelpInfo {
    [CmdletBinding()]
    [OutputType([OverloadExceptionHelpInfo[]])]
    param(
        [Parameter(Mandatory)]
        [FunctionMemberAst]$Method
    )

    begin {
        $Help = $Method.Body.GetHelpContent()
    }

    process {
        if ($Help.Outputs.Count -eq 0) {
            return @()
        }

        foreach ($Output in $Help.Outputs) {
            $Lines = $Output.Trim() -split '\r?\n'
            $Type = $Lines[0].Trim()

            if ($Lines.Count -gt 1) {
                $Description = $Lines | Select-Object -Skip 1
                $Description = $Description -join "`n"
                $Description = $Description.Trim()
            } else {
                $Description = ''
            }

            [OverloadExceptionHelpInfo]@{
                Type        = $Type
                Description = $Description
            }
        }
    }

    end {}
}
