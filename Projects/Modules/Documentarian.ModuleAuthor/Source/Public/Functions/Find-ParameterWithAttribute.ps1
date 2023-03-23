# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/DontShowAttributeInfo.psm1
using module ../Classes/ExperimentalAttributeInfo.psm1
using module ../Classes/HasValidationAttributeInfo.psm1
using module ../Classes/SupportsWildcardsAttributeInfo.psm1
using module ../Classes/ValueFromPipelineAttributeInfo.psm1
using module ../Classes/ValueFromRemainingAttributeInfo.psm1
using module ../Enums/ParameterAttributeKind.psm1

function Find-ParameterWithAttribute {
    [CmdletBinding()]
    [OutputType(
        [DontShowAttributeInfo],
        [ExperimentalAttributeInfo],
        [HasValidationAttributeInfo],
        [SupportsWildcardsAttributeInfo],
        [ValueFromPipelineAttributeInfo],
        [ValueFromRemainingAttributeInfo]
    )]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ParameterAttributeKind]$AttributeKind,

        [Parameter(Position = 1)]
        [SupportsWildcards()]
        [string[]]$CommandName = '*',

        [ValidateSet('Cmdlet', 'Module', 'None')]
        [string]$GroupBy = 'None'
    )
    begin {
        $cmdlets = Get-Command $CommandName -Type Cmdlet, ExternalScript, Filter, Function, Script
    }
    process {
        foreach ($cmd in $cmdlets) {
            foreach ($param in $cmd.Parameters.Values) {
                $result = $null
                foreach ($attr in $param.Attributes) {
                    if ($attr.TypeId.ToString() -eq 'System.Management.Automation.ParameterAttribute' -and
                        $AttributeKind -in 'DontShow', 'Experimental', 'ValueFromPipeline', 'ValueFromRemaining') {
                        switch ($AttributeKind) {
                            DontShow {
                                if ($attr.DontShow) {
                                    $result = [DontShowAttributeInfo]@{
                                        Cmdlet           = $cmd.Name
                                        Parameter        = $param.Name
                                        ParameterType    = $param.ParameterType.Name
                                        DontShow         = $attr.DontShow
                                        ParameterSetName = $param.ParameterSets.Keys -join ', '
                                        Module           = $cmd.Source
                                    }
                                }
                                break
                            }
                            Experimental {
                                if ($attr.ExperimentName) {
                                    $result = [ExperimentalAttributeInfo]@{
                                        Cmdlet           = $cmd.Name
                                        Parameter        = $param.Name
                                        ParameterType    = $param.ParameterType.Name
                                        DontShow         = $attr.ExperimentName
                                        ParameterSetName = $param.ParameterSets.Keys -join ', '
                                        Module           = $cmd.Source
                                    }
                                }
                                break
                            }
                            ValueFromPipeline {
                                if ($attr.ValueFromPipeline -or $attr.ValueFromPipelineByPropertyName) {
                                    $result = [ValueFromPipelineAttributeInfo]@{
                                        Cmdlet            = $cmd.Name
                                        Parameter         = $param.Name
                                        ParameterType     = $param.ParameterType.Name
                                        ValueFromPipeline = ('ByValue({0}), ByName({1})' -f $attr.ValueFromPipeline, $attr.ValueFromPipelineByPropertyName)
                                        ParameterSetName  = $param.ParameterSets.Keys -join ', '
                                        Module            = $cmd.Source
                                    }
                                }
                                break
                            }
                            ValueFromRemaining {
                                if ($attr.ValueFromRemainingArguments) {
                                    $result = [ValueFromRemainingAttributeInfo]@{
                                        Cmdlet             = $cmd.Name
                                        Parameter          = $param.Name
                                        ParameterType      = $param.ParameterType.Name
                                        ValueFromRemaining = $attr.ValueFromRemainingArguments
                                        ParameterSetName   = $param.ParameterSets.Keys -join ', '
                                        Module             = $cmd.Source
                                    }
                                }
                                break
                            }
                        }
                    } elseif ($attr.TypeId.ToString() -like 'System.Management.Automation.Validate*Attribute' -and
                        $AttributeKind -eq 'HasValidation') {
                        $result = [HasValidationAttributeInfo]@{
                            Cmdlet              = $cmd.Name
                            Parameter           = $param.Name
                            ParameterType       = $param.ParameterType.Name
                            ValidationAttribute = $attr.TypeId.ToString().Split('.')[ - 1].Replace('Attribute', '')
                            ParameterSetName    = $param.ParameterSets.Keys -join ', '
                            Module              = $cmd.Source
                        }
                    } elseif ($attr.TypeId.ToString() -eq 'System.Management.Automation.SupportsWildcardsAttribute' -and
                        $AttributeKind -eq 'SupportsWildcards') {
                        $result = [SupportsWildcardsAttributeInfo]@{
                            Cmdlet            = $cmd.Name
                            Parameter         = $param.Name
                            ParameterType     = $param.ParameterType.Name
                            SupportsWildcards = $true
                            ParameterSetName  = $param.ParameterSets.Keys -join ', '
                            Module            = $cmd.Source
                        }
                    }
                }
                if ($result) {
                    switch ($GroupBy) {
                        'Cmdlet' {
                            $typename = $result.GetType().Name + '#ByCmdlet'
                            $result.psobject.TypeNames.Insert(0, $typename)
                            break
                        }
                        'Module' {
                            $typename = $result.GetType().Name + '#ByModule'
                            $result.psobject.TypeNames.Insert(0, $typename)
                            break
                        }
                    }
                    $result #| Sort-Object -Unique
                }
            }
        }
    }
}
