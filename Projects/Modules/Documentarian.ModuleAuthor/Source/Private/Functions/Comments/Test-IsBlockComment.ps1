# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language

Function Test-IsBlockComment {
    [CmdletBinding()]
    Param(
        [token]$Token
    )

    begin {}

    process {
        if ($Token.Kind -ne 'Comment') {
            return $false
        }

        return ($Token.Text -match '^<#')
    }

    end {}
}
