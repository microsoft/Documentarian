# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ..\Enums\ValeReadabilityRule.psm1
using module .\ValeMetricsInfo.psm1
using module .\ValeReadability.psm1

class ValeMetricsColemanLiau : ValeReadability {
    [string] $AgeRange
    [string] $GradeLevel

    hidden [void] AddDynamicMembers() {
        $this | Add-Member -Force -MemberType ScriptProperty -Name AgeRange -Value {
            return [ValeReadability]::GetAgeRange($this.Score + 1)
        }

        $this | Add-Member -Force -MemberType ScriptProperty -Name GradeLevel -Value {
            return [ValeReadability]::GetGradeLevel($this.Score + 1)
        }

        $this | Add-Member -Force -MemberType ScriptProperty -Name ProblemMessage -Value {
            if (-not $this.TestThreshold()) {
                $Target = [ValeReadability]::GetGradeLevel($this.Threshold + 1)
                return @(
                    "Coleman-Liau Index grade level is $($this.GradeLevel)"
                    "try to keep below $Target"
                ) -join ' - '
            }
        }
    }

    ValeMetricsColemanLiau() : base() {
        $this.Rule = [ValeReadabilityRule]::ColemanLiau
        $this.Threshold = 9
    }

    ValeMetricsColemanLiau([int]$Score) : base() {
        $this.Rule = [ValeReadabilityRule]::ColemanLiau
        $this.Threshold = 9
        $this.Score = $Score
        $this.AddDynamicMembers()
    }

    ValeMetricsColemanLiau([ValeMetricsInfo]$Metrics) : base([ValeMetricsInfo]$Metrics) {
        $this.Rule = [ValeReadabilityRule]::ColemanLiau
        $this.Threshold = 9
        $this.Score = [ValeMetricsColemanLiau]::GetScore($Metrics)
        $this.AddDynamicMembers()
    }

    static [float] GetScore([ValeMetricsInfo]$Metrics) {
        $Result = 0.0588 * ($Metrics.CharacterCount / $Metrics.WordCount) * 100
        $Result -= 0.296 * ($Metrics.SentenceCount / $Metrics.WordCount) * 100
        $Result -= 15.8

        return $Result
    }

    [string] ToString() {
        return @(
            "Coleman-Liau Index for '$($this.Name)':"
            $this.Score
            "(Ages $($this.AgeRange), Grade Level $($this.GradeLevel))"
        ) -join ' '
    }
}
