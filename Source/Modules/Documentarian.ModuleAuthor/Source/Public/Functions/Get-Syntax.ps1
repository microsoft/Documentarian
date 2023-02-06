function Get-Syntax {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$CmdletName,
        [switch]$Markdown
    )

    function formatString {
        param(
            $cmd,
            $pstring
        )

        $parts = $pstring -split ' '
        $parameters = @()
        for ($x = 0; $x -lt $parts.Count; $x++) {
            $p = $parts[$x]
            if ($x -lt $parts.Count - 1) {
                if (!$parts[$x + 1].StartsWith('[')) {
                    $p += ' ' + $parts[$x + 1]
                    $x++
                }
                $parameters += , $p
            } else {
                $parameters += , $p
            }
        }

        $line = $cmd + ' '
        $temp = ''
        for ($x = 0; $x -lt $parameters.Count; $x++) {
            if ($line.Length + $parameters[$x].Length + 1 -lt 100) {
                $line += $parameters[$x] + ' '
            }
            else {
                $temp += $line + "`r`n"
                $line = ' ' + $parameters[$x] + ' '
            }
        }
        $temp + $line.TrimEnd()
    }


    try {
        $cmdlet = Get-Command $cmdletname -ea Stop
        if ($cmdlet.CommandType -eq 'Alias') { $cmdlet = Get-Command $cmdlet.Definition }
        if ($cmdlet.CommandType -eq 'ExternalScript') {
            $name = $CmdletName
        } else {
            $name = $cmdlet.Name
        }

        $syntax = (Get-Command $name).ParameterSets |
            Select-Object -Property @{n = 'Cmdlet'; e = { $cmdlet.Name } },
            @{n = 'ParameterSetName'; e = { $_.name } },
            IsDefault,
            @{n = 'Parameters'; e = { $_.ToString() } }
    }
    catch [System.Management.Automation.CommandNotFoundException] {
        $_.Exception.Message
    }

    $mdHere = @'
### {0}{1}

```
{2}
```

'@

    if ($Markdown) {
        foreach ($s in $syntax) {
            $string = $s.Cmdlet, $s.Parameters -join ' '
            if ($s.IsDefault) { $default = ' (Default)' } else { $default = '' }
            if ($string.Length -gt 100) {
                $string = formatString $s.Cmdlet $s.Parameters
            }
            $mdHere -f $s.ParameterSetName, $default, $string
        }
    }
    else {
        $syntax
    }

}
