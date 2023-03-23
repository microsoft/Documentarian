# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ..\Enums\ValeReadabilityRule.psm1
using module .\ValeMetricsInfo.psm1
using module .\ValeReadability.psm1

class ValeMetricsAutomatedReadability : ValeReadability {
    [string] $AgeRange
    [string] $GradeLevel

    hidden [void] AddDynamicMembers() {
        $this | Add-Member -Force -MemberType ScriptProperty -Name AgeRange -Value {
            return [ValeReadability]::GetAgeRange($this.Score)
        }
        $this | Add-Member -Force -MemberType ScriptProperty -Name GradeLevel -Value {
            return [ValeReadability]::GetGradeLevel($this.Score)
        }
        $this | Add-Member -Force -MemberType ScriptProperty -Name ProblemMessage -Value {
            if (-not $this.TestThreshold()) {
                $Target = [ValeReadability]::GetGradeLevel($this.Threshold)
                return @(
                    "Automated Readability Index grade level is $($this.GradeLevel)"
                    "try to target $Target"
                ) -join ' - '
            }
        }
    }

    ValeMetricsAutomatedReadability() : base() {
        $this.Rule = [ValeReadabilityRule]::AutomatedReadability
        $this.Threshold = 8
    }

    ValeMetricsAutomatedReadability([int]$Score) : base() {
        $this.Rule = [ValeReadabilityRule]::AutomatedReadability
        $this.Threshold = 8
        $this.Score = $Score
        $this.AddDynamicMembers()
    }

    ValeMetricsAutomatedReadability([ValeMetricsInfo]$Metrics) : base([ValeMetricsInfo]$Metrics) {
        $this.Rule = [ValeReadabilityRule]::AutomatedReadability
        $this.Threshold = 8
        $this.Score = [ValeMetricsAutomatedReadability]::GetScore($Metrics)
        $this.AddDynamicMembers()
    }

    static [int] GetScore([ValeMetricsInfo]$Metrics) {
        $Result = 4.71 * ($Metrics.CharacterCount / $Metrics.WordCount)
        $Result += 0.5 * ($Metrics.WordCount / $Metrics.SentenceCount)
        $Result -= 21.43
        $Result = [Math]::Ceiling($Result)
        $Result = [Math]::Clamp($Result, 1, 14)

        return $Result
    }

    [string] ToString() {
        return @(
            "Automated Readability Index for '$($this.Name)':"
            [ValeReadability]::GetMappedScore($this.Score)
        ) -join ' '
    }
}
