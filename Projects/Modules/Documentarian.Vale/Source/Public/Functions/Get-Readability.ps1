# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Get-Readability {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, Position = 0)]
        [SupportsWildcards()]
        [string[]]$Path,

        [Parameter(Position = 1)]
        [ValidateSet('AutomatedReadability', 'ColemanLiau', 'FleschKincaid', 'FleschReadingEase', 'GunningFog', 'LIX', 'SMOG')]
        [string]$ReadabilityRule = 'AutomatedReadability'
    )

    Get-ProseMetric -Path $Path | ForEach-Object {
        $Metric = $_
        $Readability = [PSCustomObject]@{
            Score = 0
            Message = ''
            File = $Metric.FileInfo.Name
            Metrics = $_
        }
        switch ($ReadabilityRule) {
            'AutomatedReadability' {
                $score = [int]((4.71 * ($Metric.CharacterCount / $Metric.WordCount)) + (0.5 * ($Metric.WordCount / $Metric.SentenceCount)) - 21.43)
                $grade = @(
                    "Unknown low score ($score)",
                    'Kindergarten',
                    '1st grade',
                    '2nd grade',
                    '3rd grade',
                    '4th grade',
                    '5th grade',
                    '6th grade',
                    '7th grade',
                    '8th grade',
                    '9th grade',
                    '10th grade',
                    '11th grade',
                    '12th grade',
                    'College student',
                    "Unknown high score ($score)"
                )
                $Readability.Score = $score
                $Readability.Message = "Grade level is $($grade[$score]) - try to target 8th grade."
                break
            }
            'ColemanLiau' {
                $score = (0.0588 * ($Metric.CharacterCount / $Metric.WordCount) * 100) - (0.296 * ($Metric.SentenceCount / $Metric.WordCount) * 100) - 15.8
                $Readability.Score = $score
                $Readability.Message = "Coleman-Liau Index grade level is {0:n2} - Try to keep below 9." -f $score
                break
            }
            'FleschKincaid' {
                $score = (0.39 * ($Metric.WordCount / $Metric.SentenceCount)) + (11.8 * ($Metric.SyllableCount / $Metric.WordCount)) - 15.59
                $Readability.Score = $score
                $Readability.Message = "Flesch-Kincaid grade level is {0:n2} - try to target 8th grade." -f $score
                break
            }
            'FleschReadingEase' {
                $score = 206.835 - (1.015 * ($Metric.WordCount / $Metric.SentenceCount)) - (84.6 * ($Metric.SyllableCount / $Metric.WordCount))
                $Readability.Score = $score
                $Readability.Message = "Flesch reading ease score is {0:n2} - try to keep above 70." -f $score
                break
            }
            'GunningFog' {
                $score = (0.4 * (($Metric.WordCount / $Metric.SentenceCount) + 100 * ($Metric.ComplexWordCount / $Metric.WordCount)))
                $Readability.Score = $score
                $Readability.Message = "Gunning fog index is {0:n2} - try to keep below 10." -f $score
                break
            }
            'LIX' {
                $score = ($Metric.WordCount / $Metric.SentenceCount) + (100 * ($Metric.LongWordCount / $Metric.WordCount))
                $Readability.Score = $score
                $Readability.Message = "LIX readability index is {0:n2} - try to keep below 35." -f $score
                break
            }
            'SMOG' {
                $score = 1.043 * ([math]::Sqrt(($Metric.ComplexWordCount * 30) / $Metric.SentenceCount)) + 3.1291
                $Readability.Score = $score
                $Readability.Message = "SMOG grade level is {0:n2} - try to keep below 10." -f $score
                break
            }
        }
        $Readability
    }

}
