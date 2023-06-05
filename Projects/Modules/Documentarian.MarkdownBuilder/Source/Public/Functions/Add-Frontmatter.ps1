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
    Resolve-Path -Path "$SourceFolder/Private/Functions/Add-FrontMatterYamlKey.ps1"
    Resolve-Path -Path "$SourceFolder/Public/Functions/Add-Line.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
    . $RequiredFunction
}

#endregion RequiredFunctions

function Add-FrontMatter {
    <#
        .SYNOPSIS
        Adds front matter to a **MarkdownBuilder** object.

        .DESCRIPTION
        Adds front matter to a **MarkdownBuilder** object from a given hashtable of key-value
        pairs. If the **MarkdownBuilder** object is not specified, the function creates a new one.

        If you specify the **PassThru** parameter, the function returns the **MarkdownBuilder**
        object. If the function detects that it's called in a pipeline, it returns the
        **MarkdownBuilder** object regardless of whether you specify the **PassThru** parameter.
    #>
    [CmdletBinding()]
    [OutputType([MarkdownBuilder])]
    param(
        # The key-value pairs to add as front matter.
        [parameter(Mandatory)]
        [hashtable]$FrontMatter,

        # The format of the front matter. The only supported format is YAML.
        [ValidateSet('YAML')]
        [string] $Format = 'YAML',

        # The **MarkdownBuilder** object to add the front matter to.
        [parameter(ValueFromPipeline)]
        [MarkdownBuilder]$Builder,

        # The line ending to use for the front matter. If you don't specify a
        # line ending, the function uses the default line ending for the
        # **MarkdownBuilder** object.
        [LineEnding]$LineEnding,

        # Passes the **MarkdownBuilder** object through the pipeline.
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

        $Boundary = '---'

        if ($null -ne $LineEnding) {
            $Builder | Add-Line -LineEnding $LineEnding -Content $Boundary
            $Builder | Add-FrontMatterYamlKey -LineEnding $LineEnding -FrontMatter $FrontMatter
            $Builder | Add-Line -LineEnding $LineEnding -Content $Boundary
            $Builder | Add-Line -LineEnding $LineEnding -PassThru:$PassThru
        } else {
            $Builder | Add-Line -Content $Boundary
            $Builder | Add-FrontMatterYamlKey -FrontMatter $FrontMatter
            $Builder | Add-Line -Content $Boundary
            $Builder | Add-Line -PassThru:$PassThru
        }
    }

    end {}
}
