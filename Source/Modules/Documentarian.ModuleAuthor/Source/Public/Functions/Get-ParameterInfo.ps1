# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Get-ParameterInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]]$ParameterName,

        [Parameter(Mandatory, Position = 1)]
        [string]$CmdletName,

        [switch]$AsObject
    )

    $mdtext = @'
### -{0}

{1}

```yaml
Type: {2}
Parameter Sets: {3}
Aliases: {4}

Required: {5}
Position: {6}
Default value: None
Value From Remaining: {7}
Accept pipeline input: {8}
Dynamic: {9}
Accept wildcard characters: {10}
```

'@

    $providerList = Get-PSProvider

    foreach ($pname in $ParameterName) {
        try {
            foreach ($provider in $providerList) {
                Push-Location $($provider.Drives[0].Name + ':')
                $cmdlet = Get-Command -Name $CmdletName -ErrorAction Stop
                $param = $cmdlet.Parameters.Values | Where-Object Name -EQ $pname
                if ($param) {
                    $paraminfo = [PSCustomObject]@{
                        Name          = $param.Name
                        HelpText      = if ($null -eq $param.Attributes.HelpMessage) {
                            '{{Placeholder}}}'
                        } else {
                            $param.Attributes.HelpMessage
                        }
                        Type          = $param.ParameterType.FullName
                        ParameterSet  = if ($param.Attributes.ParameterSetName -eq '__AllParameterSets') {
                            '(All)'
                        } else {
                            $param.Attributes.ParameterSetName -join ', '
                        }
                        Aliases       = $param.Aliases -join ', '
                        Required      = $param.Attributes.Mandatory
                        Position      = $param.Attributes.Position -lt 0 ? 'Named' : $param.Position
                        FromRemaining = $param.Attributes.ValueFromRemainingArguments
                        Pipeline      = 'ByValue ({0}), ByName ({1})' -f $param.Attributes.ValueFromPipeline,
                        $param.Attributes.ValueFromPipelineByPropertyName
                        Dynamic       = if ($param.IsDynamic) {
                            'True ({0} provider)' -f $provider.Name
                        } else {
                            'False'
                        }
                        Wildcard      = $param.Attributes.TypeId.Name -contains 'SupportsWildcardsAttribute'
                    }
                    Pop-Location
                    break
                } else {
                    Pop-Location
                }
            }
        } catch {
            Write-Error "Cmdlet $CmdletName not found."
            return
        }

        if ($param) {
            if ($AsObject) {
                $paraminfo
            } else {
                $newtext = $mdtext
                [array]$props = $paraminfo.psobject.Properties
                for ($y = 0; $y -lt $props.Count; $y++) {
                    $newtext = $newtext.replace("{$y}", $props[$y].Value)
                }
                $newtext
            }
        } else {
            Write-Error "Parameter $pname not found."
        }
    }
}
