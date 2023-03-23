# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ..\Enums\ValeReadabilityRule.psm1
using module .\ValeMetricsInfo.psm1
using module .\ValeReadability.psm1

class ValeMetricsLIX : ValeReadability {
    hidden [void] AddDynamicMembers() {
        $this | Add-Member -Force -MemberType ScriptProperty -Name ProblemMessage -Value {
            if (-not $this.TestThreshold()) {
                $Index = [ValeReadability]::GetRoundedScore($this.Score)
                return @(
                    "LIX readability index is $Index"
                    "try to keep below $($this.Threshold)."
                ) -join ' - '
            }
        }
    }

    ValeMetricsLIX() : base() {
        $this.Rule = [ValeReadabilityRule]::LIX
        $this.Threshold = 35
    }

    ValeMetricsLIX([int]$Score) : base() {
        $this.Rule = [ValeReadabilityRule]::LIX
        $this.Threshold = 35
        $this.Score = $Score
        $this.AddDynamicMembers()
    }

    ValeMetricsLIX([ValeMetricsInfo]$Metrics) : base([ValeMetricsInfo]$Metrics) {
        $this.Rule = [ValeReadabilityRule]::LIX
        $this.Threshold = 35
        $this.Score = [ValeMetricsLIX]::GetScore($Metrics)
        $this.AddDynamicMembers()
    }

    static [float] GetScore([ValeMetricsInfo]$Metrics) {
        $Result = $Metrics.WordCount / $Metrics.SentenceCount
        $Result += $Metrics.LongWordCount * 100 / $Metrics.WordCount

        return $Result
    }

    [string] ToString() {
        return @(
            "LIX readability index for '$($this.Name)':"
            $this.Score
        ) -join ' '
    }
}
