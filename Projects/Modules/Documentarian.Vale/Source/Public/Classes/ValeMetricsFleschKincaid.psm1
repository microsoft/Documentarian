# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ..\Enums\ValeReadabilityRule.psm1
using module .\ValeMetricsInfo.psm1
using module .\ValeReadability.psm1

class ValeMetricsFleschKincaid : ValeReadability {
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
                    "Flesch-Kincaid grade level is $($this.GradeLevel)"
                    "try to keep below $Target"
                ) -join ' - '
            }
        }
    }

    ValeMetricsFleschKincaid() : base() {
        $this.Rule = [ValeReadabilityRule]::FleschKincaid
        $this.Threshold = 8
    }

    ValeMetricsFleschKincaid([int]$Score) : base() {
        $this.Rule = [ValeReadabilityRule]::FleschKincaid
        $this.Threshold = 8
        $this.Score = $Score
        $this.AddDynamicMembers()
    }

    ValeMetricsFleschKincaid([ValeMetricsInfo]$Metrics) : base([ValeMetricsInfo]$Metrics) {
        $this.Rule = [ValeReadabilityRule]::FleschKincaid
        $this.Threshold = 8
        $this.Score = [ValeMetricsFleschKincaid]::GetScore($Metrics)
        $this.AddDynamicMembers()
    }

    static [float] GetScore([ValeMetricsInfo]$Metrics) {
        $Result = 0.39 * ($Metrics.WordCount / $Metrics.SentenceCount)
        $Result += 11.8 * ($Metrics.SyllableCount / $Metrics.WordCount)
        $Result -= 15.59

        return $Result
    }

    [string] ToString() {
        return @(
            "Flesch-Kincaid score for '$($this.Name)':"
            $this.Score
            "(Ages $($this.AgeRange), Grade Level $($this.GradeLevel))"
        ) -join ' '
    }
}
