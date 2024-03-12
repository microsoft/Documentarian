# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation

function Get-CmdletXref {
    <#
    .SYNOPSIS
    Gets a cross-reference link for a command.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        # The name of the Command or a CommandInfo instance to get a cross-reference link for.
        [Parameter(Mandatory, ValueFromPipeline)]
        [CommandInfoArgumentTransformation()]
        [CommandInfo[]] $Command
    )

    begin {
        $allowedFlags = [CommandTypes]@(
            'Cmdlet'
            'Function'
            'Filter'
        )
    }
    process {
        foreach ($cmd in $Command) {
            try {
                $modulename = $cmd.ModuleName
                $commandname = $cmd.Name
                $commandtype = $cmd.CommandType

                if (-not $allowedFlags.HasFlag($commandtype)) {
                    $PSCmdlet.WriteWarning("'$commandname' is a(n) $commandtype.")
                    continue
                }

                if (-not $modulename) {
                    $help = Get-Help $cmd.Name

                    if (-not $help.ModuleName) {
                        $PSCmdlet.WriteWarning("'$commandname' is an anonymous $commandtype.")
                        continue
                    }

                    $modulename = $help.ModuleName
                    $commandname = $help.Name
                }

                "[$commandname](xref:${modulename}.$commandname)"
            } catch [CommandNotFoundException] {
                $PSCmdlet.WriteWarning($_)
            } catch {
                $PSCmdlet.WriteError($_)
            }
        }
    }
}
