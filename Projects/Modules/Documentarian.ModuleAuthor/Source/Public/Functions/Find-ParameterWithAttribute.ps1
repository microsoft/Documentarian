# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Enums/ParameterAttributeKind.psm1

function Find-ParameterWithAttribute {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ParameterAttributeKind]$AttributeKind,

        [Parameter(Position = 1)]
        [SupportsWildcards()]
        [string[]]$CommandName = '*'
    )
    begin {
        $cmdlets = Get-Command $CommandName -Type Cmdlet, ExternalScript, Filter, Function, Script
    }
    process {
        foreach ($cmd in $cmdlets) {
            foreach ($param in $cmd.Parameters.Values) {
                $result = @()
                foreach ($attr in $param.Attributes) {
                    if ($attr.TypeId.ToString() -eq 'System.Management.Automation.ParameterAttribute' -and
                        $AttributeKind -in 'DontShow', 'Experimental', 'ValueFromPipeline', 'ValueFromRemaining') {
                        switch ($AttributeKind) {
                            DontShow {
                                if ($attr.DontShow) {
                                    $result = $attr | Select-Object @{n = 'Cmdlet'; e = { $cmd.Name } },
                                    @{n = 'Parameter'; e = { $param.Name } },
                                    DontShow,
                                    @{n = 'ParameterSetName'; e = { $param.ParameterSets.Keys -join ', ' } }
                                }
                                break
                            }
                            Experimental {
                                if ($attr.ExperimentName) {
                                    $result = $attr | Select-Object @{n = 'Cmdlet'; e = { $cmd.Name } },
                                    @{n = 'Parameter'; e = { $param.Name } },
                                    ExperimentName,
                                    @{n = 'ParameterSetName'; e = { $param.ParameterSets.Keys -join ', ' } }
                                }
                                break
                            }
                            ValueFromPipeline {
                                if ($attr.ValueFromPipeline -or $attr.ValueFromPipelineByPropertyName) {
                                    $result = $attr | Select-Object @{n = 'Cmdlet'; e = { $cmd.Name } },
                                    @{n = 'Parameter'; e = { $param.Name } },
                                    @{n = 'Pipeline'; e = { 'ByValue({0}), ByName({1})' -f $_.ValueFromPipeline, $_.ValueFromPipelineByPropertyName } },
                                    @{n = 'ParameterSetName'; e = { $param.ParameterSets.Keys -join ', ' } }
                                }
                                break
                            }
                            ValueFromRemaining {
                                if ($attr.ValueFromRemainingArguments) {
                                    $result = $attr | Select-Object @{n = 'Cmdlet'; e = { $cmd.Name } },
                                    @{n = 'Parameter'; e = { $param.Name } },
                                    ValueFromRemainingArguments,
                                    @{n = 'ParameterSetName'; e = { $param.ParameterSets.Keys -join ', ' } }
                                }
                                break
                            }
                        }
                    } elseif ($attr.TypeId.ToString() -like 'System.Management.Automation.Validate*Attribute' -and
                        $AttributeKind -eq 'HasValidation') {
                        $result = $attr | Select-Object @{n = 'Cmdlet'; e = { $cmd.Name } },
                        @{n = 'Parameter'; e = { $param.Name } },
                        @{n = 'Attribute'; e = { $attr.TypeId.ToString().Split('.')[-1].Replace('Attribute', '') } },
                        @{n = 'ParameterSetName'; e = { $param.ParameterSets.Keys -join ', ' } }
                    } elseif ($attr.TypeId.ToString() -eq 'System.Management.Automation.SupportsWildcardsAttribute' -and
                        $AttributeKind -eq 'SupportsWildcards') {
                        $result = $attr | Select-Object @{n = 'Cmdlet'; e = { $cmd.Name } },
                        @{n = 'Parameter'; e = { $param.Name } },
                        @{n = 'SupportsWildcards'; e = { $true } },
                        @{n = 'ParameterSetName'; e = { $param.ParameterSets.Keys -join ', ' } }
                    }
                }
                if ($result) { $result | Sort-Object -Unique }
            }
        }
    }
}
