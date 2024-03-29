# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Enums/ValeReadabilityRule.psm1
using module ../Classes/ValeReadability.psm1
using module ../Classes/ValeMetricsAutomatedReadability.psm1
using module ../Classes/ValeMetricsColemanLiau.psm1
using module ../Classes/ValeMetricsFleschKincaid.psm1
using module ../Classes/ValeMetricsFleschReadingEase.psm1
using module ../Classes/ValeMetricsGunningFog.psm1
using module ../Classes/ValeMetricsLIX.psm1
using module ../Classes/ValeMetricsSMOG.psm1

function Get-ProseReadability {
    [CmdletBinding(DefaultParameterSetName = 'ByRule')]
    [OutputType(
        [ValeReadability],
        [ValeMetricsAutomatedReadability],
        [ValeMetricsColemanLiau],
        [ValeMetricsFleschKincaid],
        [ValeMetricsFleschReadingEase],
        [ValeMetricsGunningFog],
        [ValeMetricsLIX],
        [ValeMetricsSMOG]
    )]
    param(
        [Parameter(Mandatory, Position = 0)]
        [SupportsWildcards()]
        [string[]]$Path,

        [Parameter(Position = 1, ParameterSetName = 'ByRule')]
        [ValeReadabilityRule[]]$ReadabilityRule = [ValeReadabilityRule]::AutomatedReadability,

        [Parameter(Position = 2, ParameterSetName = 'ByRule')]
        [float]$Threshold,

        [Parameter(ParameterSetName = 'Preset')]
        [ValidateSet('GradeLevels', 'Numericals')]
        [string]$Preset,

        [Parameter(ParameterSetName = 'AllRules')]
        [switch]$All,

        [switch]$ProblemsOnly,

        [switch]$Recurse
    )

    begin {
        if ($ProblemsOnly) {
            $DecoratingType = 'ProblemMessage'
        }

        switch ($Preset) {
            'GradeLevels' {
                $ReadabilityRule = [ValeReadability]::GetGradeLevelRules()
            }
            'Numericals' {
                $ReadabilityRule = [ValeReadability]::GetNumericalRules()
            }
            default {
                if ($All) {
                    $ReadabilityRule = [ValeReadabilityRule].GetEnumNames()
                }
            }
        }
    }

    process {
        Get-ProseMetric -Path $Path -Recurse:$Recurse | ForEach-Object {
            $Metrics = $_

            if ($Metrics.WordCount -eq 0) {
                $Message = @(
                    "Skipping readability analysis for '$($Metrics.FileInfo)'"
                    'Word count is 0.'
                ) -join ' - '
                Write-Verbose $Message
                return
            }

            foreach ($Rule in $ReadabilityRule) {
                $Result = New-Object -TypeName "ValeMetrics$Rule" -ArgumentList $Metrics

                if ($Threshold -gt 0) {
                    $Result.Threshold = $Threshold
                }

                if ($ProblemsOnly -and [string]::IsNullOrEmpty($Result.ProblemMessage)) {
                    continue
                }

                if (-not [string]::IsNullOrEmpty($DecoratingType)) {
                    $Result.psobject.TypeNames.Insert(0, "ValeReadability#$DecoratingType")
                }

                $Result
            }
        }
    }
}
