# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

[Flags()] enum ProviderFlags {
    Registry    = 0x01
    Alias       = 0x02
    Environment = 0x04
    FileSystem  = 0x08
    Function    = 0x10
    Variable    = 0x20
    Certificate = 0x40
    WSMan       = 0x80
}

class ParameterInfo {
    [string]$Name
    [string]$HelpText
    [string]$Type
    [string]$ParameterSet
    [string]$Aliases
    [bool]$Required
    [string]$Position
    [string]$Pipeline
    [bool]$Wildcard
    [bool]$Dynamic
    [bool]$FromRemaining
    [bool]$DontShow
    [ProviderFlags]$ProviderFlags

    hidden static [string]$MarkdownTemplate = @'
### -{0}

{1}

```yaml
Type: {2}
Parameter Sets: {3}
Aliases: {4}

Required: {5}
Position: {6}
Default value: None
Accept pipeline input: {7}
Accept wildcard characters: {8}
```

'@

    <#
    DontShow: {9}
    Providers: {10}
    #>

    ParameterInfo(
        [string]$Name, [string]$HelpText, [string]$Type, [string]$ParameterSet, [string]$Aliases,
        [bool]$Required, [string]$Position, [string]$Pipeline, [bool]$Wildcard, [bool]$Dynamic,
        [bool]$FromRemaining, [bool]$DontShow, [ProviderFlags]$ProviderFlags
    ) {
        $this.Name          = $Name
        $this.HelpText      = if ($null -eq $HelpText) {
                                  '{{Placeholder}}'
                              } else {
                                  $HelpText
                              }
        $this.Type          = $Type
        $this.ParameterSet  = if ($ParameterSet -eq '__AllParameterSets') {
                                  '(All)'
                              } else {
                                  $ParameterSet -join ', '
                              }
        $this.Aliases       = $Aliases -join ', '
        $this.Required      = $Required
        $this.Position      = if ($Position -lt 0) {
                                  'Named'
                              } else {
                                  $Position
                              }
        $this.Pipeline        = $Pipeline
        $this.Wildcard        = $Wildcard
        $this.Dynamic         = $Dynamic
        $this.FromRemaining   = $FromRemaining
        $this.DontShow        = $DontShow
        $this.ProviderFlags   = $ProviderFlags
    }

    [string]ToMarkdown() {
        $newtext = [ParameterInfo]::MarkdownTemplate
        $newtext = $newtext.replace('{0}', $this.Name)
        $newtext = $newtext.replace('{1}', $this.HelpText)
        $newtext = $newtext.replace('{2}', $this.Type)
        $newtext = $newtext.replace('{3}', $this.ParameterSet)
        $newtext = $newtext.replace('{4}', $this.Aliases)
        $newtext = $newtext.replace('{5}', $this.Required)
        $newtext = $newtext.replace('{6}', $this.Position)
        $newtext = $newtext.replace('{7}', $this.Pipeline)
        $newtext = $newtext.replace('{8}', $this.Wildcard)
        $newtext = $newtext.replace('{9}', $this.DontShow)
        <#
        $ProviderName = if ($this.ProviderFlags -eq 0xFF) {
                            'All'
                        } else {
                            $this.ProviderFlags.ToString()
                        }
        $newtext = $newtext.replace('{10}', $ProviderName)
        #>
        return $newtext
    }
}

function Get-ParameterInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]]$ParameterName,

        [Parameter(Mandatory, Position = 1)]
        [string]$CmdletName,

        [switch]$AsObject
    )

    $cmdlet = Get-Command -Name $CmdletName -ErrorAction Stop
    $providerList = Get-PSProvider

    foreach ($pname in $ParameterName) {
        try {
            $paraminfo = $null
            $param = $null
            foreach ($provider in $providerList) {
                Push-Location $($provider.Drives[0].Name + ':')
                $param = $cmdlet.Parameters.Values | Where-Object Name -EQ $pname
                if ($param) {
                    if ($paraminfo) {
                        $paraminfo.ProviderFlags = $paraminfo.ProviderFlags -bor [ProviderFlags]($provider.Name)
                    } else {
                        $paraminfo = [ParameterInfo]::new(
                            $param.Name,
                            $param.Attributes.HelpMessage,
                            $param.ParameterType.FullName,
                            $param.Attributes.ParameterSetName,
                            $param.Aliases,
                            $param.Attributes.Mandatory,
                            $param.Attributes.Position,
                            ('ByValue ({0}), ByName ({1})' -f $param.Attributes.ValueFromPipeline, $param.Attributes.ValueFromPipelineByPropertyName),
                            ($param.Attributes.TypeId.Name -contains 'SupportsWildcardsAttribute'),
                            $param.IsDynamic,
                            $param.Attributes.ValueFromRemainingArguments,
                            $param.Attributes.DontShow,
                            [ProviderFlags]($provider.Name)
                        )
                    }
                }
                Pop-Location
            }
        } catch {
            Write-Error "Cmdlet $CmdletName not found."
            return
        }

        if ($paraminfo) {
            if ($AsObject) {
                $paraminfo
            } else {
                $paraminfo.ToMarkdown()
            }
        } else {
            Write-Error "Parameter $pname not found."
        }
    }
}

Get-ParameterInfo path, Options set-item -AsObject