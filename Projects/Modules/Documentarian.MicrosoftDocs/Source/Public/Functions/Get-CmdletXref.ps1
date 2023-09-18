function Get-CmdletXref {
    <#
    .SYNOPSIS
    Gets a cross-reference link for a command.
    #>
    [CmdletBinding()]
    [OutputType('System.String[]')]
    param(
        # The name of the command to get a cross-reference link for.
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$Name
    )

    begin {
        $ProgressPreference = 'SilentlyContinue'
    }

    process {
        foreach ($cmdname in $Name) {
            try {
                $cmd = Get-Command $cmdname -ErrorAction Stop
                if ($cmd.CommandType -eq 'Alias') {
                    Write-Verbose "$cmdname is an alias for $($cmd.ResolvedCommand)"
                    $cmd = Get-Command $cmd.ResolvedCommand -ErrorAction Stop
                }
                $modulename  = $cmd.ModuleName
                $commandname = $cmd.Name
                $commandtype = $cmd.CommandType
                if (@('Cmdlet', 'Function') -notcontains $commandtype) {
                    Write-Verbose "$commandname is a(n) $commandtype"
                    continue
                } elseif ($modulename -eq '') {
                    $help = Get-Help $cmdname
                    if ($help.modulename -ne '') {
                       $modulename = $help.ModuleName
                       $commandname = $help.Name
                       $commandtype = $help.Category
                    }
                }
                if ($modulename -eq '') {
                    Write-Verbose "$commandname is an anonymous $commandtype."
                } else {
                    "[$commandname](xref:${modulename}.$commandname)"
                }
            } catch [System.Management.Automation.CommandNotFoundException] {
                Write-Warning "Unable to find command $cmdname"
            }
        }
    }
}
