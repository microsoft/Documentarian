# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using module ../../../Public/Classes/HelpInfo/ExampleHelpInfo.psm1

function Resolve-ExampleFromHelp {
    [CmdletBinding()]
    [OutputType([ExampleHelpInfo[]])]
    param(
        [Parameter(Mandatory)]
        [CommentHelpInfo]$Help
    )

    begin {}

    process {
        foreach ($Example in $Help.Examples) {
            [ExampleHelpInfo]@{
                Title = ''
                Body  = $Example.Trim()
            }
        }
    }

    end {}
}
