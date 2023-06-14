# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ./BaseHelpInfo.psm1

class ExampleHelpInfo : BaseHelpInfo {
    # The title for the example.
    [string] $Title = ''
    # The body text for the example.
    [string] $Body

    static [ExampleHelpInfo[]] Resolve ([DecoratingCommentsBlockParsed]$help) {
        if ((-not $help.IsUsable()) -or ($help.Example.Count -eq 0)) {
            return @()
        }

        return $help.Example | ForEach-Object -Process {
            [ExampleHelpInfo]@{
                Title = $_.Value
                Body  = $_.Content.Trim()
            }
        }
    }

    static [ExampleHelpInfo[]] Resolve ([AstInfo]$astInfo) {
        $help = $astInfo.DecoratingComment.ParsedValue

        if ((-not $help.IsUsable()) -or ($help.Example.Count -eq 0)) {
            return @()
        }
        
        return $help.Example | ForEach-Object -Process {
            [ExampleHelpInfo]@{
                Title = $_.Value
                Body  = $_.Content.Trim()
            }
        }
    }
}
