# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ..\Enums\ValeReadabilityRule.psm1
using module .\ValeMetricsInfo.psm1

class ValeReadability {
    [ValeReadabilityRule] $Rule
    [float]               $Score
    [string]              $File
    [float]               $Threshold
    [string]              $ProblemMessage
    [ValeMetricsInfo]     $Metrics

    hidden static [hashtable] $ScoreMapping = @{
        1  = @{
            AgeRange   = '5-6'
            GradeLevel = 'Kindergarten'
        }
        2  = @{
            AgeRange   = '6-7'
            GradeLevel = '1st Grade'
        }
        3  = @{
            AgeRange   = '7-8'
            GradeLevel = '2nd Grade'
        }
        4  = @{
            AgeRange   = '8-9'
            GradeLevel = '3rd Grade'
        }
        5  = @{
            AgeRange   = '9-10'
            GradeLevel = '4th Grade'
        }
        6  = @{
            AgeRange   = '10-11'
            GradeLevel = '5th Grade'
        }
        7  = @{
            AgeRange   = '11-12'
            GradeLevel = '6th Grade'
        }
        8  = @{
            AgeRange   = '12-13'
            GradeLevel = '7th Grade'
        }
        9  = @{
            AgeRange   = '13-14'
            GradeLevel = '8th Grade'
        }
        10 = @{
            AgeRange   = '14-15'
            GradeLevel = '9th Grade'
        }
        11 = @{
            AgeRange   = '15-16'
            GradeLevel = '10th Grade'
        }
        12 = @{
            AgeRange   = '16-17'
            GradeLevel = '11th Grade'
        }
        13 = @{
            AgeRange   = '17-18'
            GradeLevel = '12th Grade'
        }
        14 = @{
            AgeRange   = '18-22'
            GradeLevel = 'College student'
        }
    }

    hidden static [string] GetAgeRange([int]$Score) {
        $Index = [Math]::Clamp($Score, 1, 14)

        return [ValeReadability]::ScoreMapping[$Index].AgeRange
    }

    hidden static [string] GetGradeLevel([int]$Score) {
        $Index = [Math]::Clamp($Score, 1, 14)

        return [ValeReadability]::ScoreMapping[$Index].GradeLevel
    }

    hidden static [string] GetMappedScore($Score) {
        return @(
            $Score
            "(Age Range: $([ValeReadability]::GetAgeRange($Score)),"
            "Grade Level: $([ValeReadability]::GetGradeLevel($Score)))"
        ) -join ' '
    }

    static [ValeReadabilityRule[]] GetGradeLevelRules() {
        return @(
            [ValeReadabilityRule]::AutomatedReadability
            [ValeReadabilityRule]::ColemanLiau
            [ValeReadabilityRule]::FleschKincaid
            [ValeReadabilityRule]::SMOG
        )
    }

    static [ValeReadabilityRule[]] GetNumericalRules() {
        return @(
            [ValeReadabilityRule]::FleschReadingEase
            [ValeReadabilityRule]::GunningFog
            [ValeReadabilityRule]::LIX
        )
    }

    # Default Constructor
    ValeReadability() {
        $this.AddBaseDynamicMembers()
    }

    ValeReadability([ValeMetricsInfo]$Metrics) {
        $this.Metrics = $Metrics
        $this.AddBaseDynamicMembers()
    }

    [bool] TestThreshold() {
        return $this.Score -le $this.Threshold
    }

    hidden [void] AddBaseDynamicMembers() {
        $this | Add-Member -Force -MemberType ScriptProperty -Name File -Value {
            $this.Metrics.FileInfo.FullName
        }
    }

    hidden static [string] GetRoundedScore($Score) {
        return ('{0:n2}' -f $Score)
    }
}
