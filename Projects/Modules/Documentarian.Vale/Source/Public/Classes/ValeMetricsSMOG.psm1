# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ..\Enums\ValeReadabilityRule.psm1
using module .\ValeMetricsInfo.psm1
using module .\ValeReadability.psm1

class ValeMetricsSMOG : ValeReadability {
    [string] $AgeRange
    [string] $GradeLevel

    hidden [void] AddDynamicMembers() {
        $this | Add-Member -Force -MemberType ScriptProperty -Name AgeRange -Value {
            $MapIndex = [int]($this.Score) + 1

            return [ValeReadability]::GetAgeRange($MapIndex)
        }

        $this | Add-Member -Force -MemberType ScriptProperty -Name GradeLevel -Value {
            $MapIndex = [int]($this.Score) + 1

            return [ValeReadability]::GetGradeLevel($MapIndex)
        }

        $this | Add-Member -Force -MemberType ScriptProperty -Name ProblemMessage -Value {
            if (-not $this.TestThreshold()) {
                $Target = [ValeReadability]::GetGradeLevel($this.Threshold + 1)
                return @(
                    "SMOG grade level is $($this.GradeLevel)"
                    "try to keep below $Target"
                ) -join ' - '
            }
        }
    }

    ValeMetricsSMOG() : base() {
        $this.Rule = [ValeReadabilityRule]::SMOG
        $this.Threshold = 10
    }

    ValeMetricsSMOG([int]$Score) : base() {
        $this.Rule = [ValeReadabilityRule]::SMOG
        $this.Threshold = 10
        $this.Score = $Score
        $this.AddDynamicMembers()
    }

    ValeMetricsSMOG([ValeMetricsInfo]$Metrics) : base([ValeMetricsInfo]$Metrics) {
        $this.Rule = [ValeReadabilityRule]::SMOG
        $this.Threshold = 10
        $this.Score = [ValeMetricsSMOG]::GetScore($Metrics)
        $this.AddDynamicMembers()
    }

    static [float] GetScore([ValeMetricsInfo]$Metrics) {
        $Result = $Metrics.ComplexWordCount * 30 / $Metrics.SentenceCount
        $Result = [Math]::Sqrt($Result)
        $Result *= 1.0430
        $Result += 3.1291

        return $Result
    }

    [string] ToString() {
        return @(
            "SMOG score for '$($this.Name)':"
            $this.Score
            "(Ages $($this.AgeRange), Grade Level $($this.GradeLevel))"
        ) -join ' '
    }
}
