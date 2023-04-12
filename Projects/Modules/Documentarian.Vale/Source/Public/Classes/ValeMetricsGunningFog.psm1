# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ..\Enums\ValeReadabilityRule.psm1
using module .\ValeMetricsInfo.psm1
using module .\ValeReadability.psm1

class ValeMetricsGunningFog : ValeReadability {
    hidden [void] AddDynamicMembers() {
        $this | Add-Member -Force -MemberType ScriptProperty -Name ProblemMessage -Value {
            if (-not $this.TestThreshold()) {
                $Index = [ValeReadability]::GetRoundedScore($this.Score)
                return @(
                    "Gunning fog index is $Index"
                    "try to keep below $($this.Threshold)."
                ) -join ' - '
            }
        }
    }

    ValeMetricsGunningFog() : base() {
        $this.Rule = [ValeReadabilityRule]::GunningFog
        $this.Threshold = 10
    }

    ValeMetricsGunningFog([int]$Score) : base() {
        $this.Rule = [ValeReadabilityRule]::GunningFog
        $this.Threshold = 10
        $this.Score = $Score
        $this.AddDynamicMembers()
    }

    ValeMetricsGunningFog([ValeMetricsInfo]$Metrics) : base([ValeMetricsInfo]$Metrics) {
        $this.Rule = [ValeReadabilityRule]::GunningFog
        $this.Threshold = 10
        $this.Score = [ValeMetricsGunningFog]::GetScore($Metrics)
        $this.AddDynamicMembers()
    }

    static [float] GetScore([ValeMetricsInfo]$Metrics) {
        $Result = $Metrics.WordCount / $Metrics.SentenceCount
        $Result += 100 * ($Metrics.ComplexWordCount / $Metrics.WordCount)
        $Result *= 0.4

        return $Result
    }

    [string] ToString() {
        return @(
            "Gunning fog index for '$($this.Name)':"
            $this.Score
        ) -join ' '
    }
}
