# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/LineEnding.psm1
using module ../Classes/MarkdownBuilder.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
    $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
    Resolve-Path -Path "$SourceFolder/Public/Functions/Add-Line.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
    . $RequiredFunction
}

#endregion RequiredFunctions

function Add-Heading {
    [CmdletBinding()]
    [OutputType([MarkdownBuilder])]
    param(
        [parameter(Mandatory)]
        [string]$Content,

        [ValidateRange(1, 6)]
        [int]$Level = 2,

        [parameter(ValueFromPipeline)]
        [MarkdownBuilder]$Builder,

        [LineEnding]$LineEnding,

        [switch]$PassThru
    )

    begin {
        if ($null -eq $Builder) {
            $Builder = New-Builder
            if ($null -ne $LineEnding) {
                $Builder.DefaultLineEnding = $LineEnding
            }
        }
    }

    process {
        $PipelinePosition = $PSCmdlet.MyInvocation.PipelinePosition
        $PipelineLength = $PSCmdlet.MyInvocation.PipelineLength

        if ($PipelineLength -gt 1 -and $PipelinePosition -ne $PipelineLength) {
            $PassThru = $true
        }

        $Prefix = '#' * $Level

        if ($null -ne $LineEnding) {
            $Builder |
            Add-Line -LineEnding $LineEnding -Content "$Prefix $Content" |
            Add-Line -LineEnding $LineEnding -PassThru:$PassThru
        } else {
            $Builder |
            Add-Line -Content "$Prefix $Content" |
            Add-Line -PassThru:$PassThru
        }
    }

    end {}
}
