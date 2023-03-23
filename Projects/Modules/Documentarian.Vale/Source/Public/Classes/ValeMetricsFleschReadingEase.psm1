# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ..\Enums\ValeReadabilityRule.psm1
using module .\ValeMetricsInfo.psm1
using module .\ValeReadability.psm1

class ValeMetricsFleschReadingEase : ValeReadability {
    hidden [void] AddDynamicMembers() {
        $this | Add-Member -Force -MemberType ScriptProperty -Name ProblemMessage -Value {
            if (-not $this.TestThreshold()) {
                $Ease = [ValeReadability]::GetRoundedScore($Result.Score)
                return @(
                    "Flesch reading ease score is $Ease"
                    "try to keep above $($this.Threshold)."
                ) -join ' - '
            }
        }
    }

    [bool] TestThreshold() {
        return $this.Score -ge $this.Threshold
    }

    ValeMetricsFleschReadingEase() : base() {
        $this.Rule = [ValeReadabilityRule]::FleschReadingEase
        $this.Threshold = 70
    }

    ValeMetricsFleschReadingEase([int]$Score) : base() {
        $this.Rule = [ValeReadabilityRule]::FleschReadingEase
        $this.Threshold = 70
        $this.Score = $Score
        $this.AddDynamicMembers()
    }

    ValeMetricsFleschReadingEase([ValeMetricsInfo]$Metrics) : base([ValeMetricsInfo]$Metrics) {
        $this.Rule = [ValeReadabilityRule]::FleschReadingEase
        $this.Threshold = 70
        $this.Score = [ValeMetricsFleschReadingEase]::GetScore($Metrics)
        $this.AddDynamicMembers()
    }

    static [float] GetScore([ValeMetricsInfo]$Metrics) {
        $Result = 206.835
        $Result -= 1.015 * ($Metrics.WordCount / $Metrics.SentenceCount)
        $Result -= 84.6 * ($Metrics.SyllableCount / $Metrics.WordCount)

        return $Result
    }

    [string] ToString() {
        return @(
            "Flesch reading ease score for '$($this.Name)':"
            $this.Score
        ) -join ' '
    }
}
