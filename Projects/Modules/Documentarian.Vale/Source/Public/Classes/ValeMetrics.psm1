# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module .\ValeMetricHeadingCount.psm1

class ValeMetrics {
    [System.IO.FileInfo]     $FileInfo
    [int]                    $CharacterCount
    [int]                    $ComplexWordCount
    [ValeMetricHeadingCount] $HeadingCounts
    [int]                    $ListBlockCount
    [int]                    $LongWordCount
    [int]                    $ParagraphCount
    [int]                    $PolysyllabicWordCount
    [int]                    $SentenceCount
    [int]                    $SyllableCount
    [int]                    $WordCount

    # Default Constructor
    ValeMetrics() {
        $this.HeadingCounts = [ValeMetricHeadingCount]::new()
    }

    # From PSCustomObject, as with Invoke-Vale
    ValeMetrics([pscustomobject]$Info) {
        $this.SetFromMetricInfo($Info)
    }

    # From PSCustomObject with known file info
    ValeMetrics([pscustomobject]$Info, [System.IO.FileInfo]$File) {
        $this.SetFromMetricInfo($Info)
        $this.FileInfo = $File
    }

    # Reusable method for converting from JSON properties to class properties
    [void] SetFromMetricInfo([pscustomobject]$Info) {
        $this.HeadingCounts = [ValeMetricHeadingCount]::new()
        $this.CharacterCount = $Info.characters
        $this.ComplexWordCount = $info.complex_words
        $this.HeadingCounts.H1 = $info.heading_h1
        $this.HeadingCounts.H2 = $info.heading_h2
        $this.HeadingCounts.H3 = $info.heading_h3
        $this.HeadingCounts.H4 = $info.heading_h4
        $this.HeadingCounts.H5 = $info.heading_h5
        $this.HeadingCounts.H6 = $info.heading_h6
        $this.ListBlockCount = $info.list
        $this.LongWordCount = $info.long_words
        $this.ParagraphCount = $info.paragraphs
        $this.PolysyllabicWordCount = $info.polysyllabic_words
        $this.SentenceCount = $info.sentences
        $this.SyllableCount = $info.syllables
        $this.WordCount = $info.words
    }
}
