# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Public/Classes/LineEnding.psm1
using module ../../Public/Classes/MarkdownBuilder.psm1

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

function Add-FrontMatterYamlKey {
    <#
        .SYNOPSIS
        Adds a set of key-value pairs to a **MarkdownBuilder** object as YAML front matter.

        .DESCRIPTION
        Adds a set of key-value pairs to a **MarkdownBuilder** object as YAML front matter. If
        the **MarkdownBuilder** object is not specified, the function creates a new one. If
        the value of a key is also a hashtable, the function calls itself recursively.
    #>
    [cmdletbinding()]
    param(
        # The key-value pairs to add as front matter.
        [hashtable] $FrontMatter,

        # The indentation level of the front matter. Only used for recursive calls.
        [int]$Indentation,

        # The **MarkdownBuilder** object to add the front matter to.
        [parameter(ValueFromPipeline)]
        [MarkdownBuilder]$Builder,

        # The line ending to use for the front matter. If you don't specify a
        # line ending, the function uses the default line ending for the
        # **MarkdownBuilder** object.
        [LineEnding]$LineEnding
    )

    begin {
        if ($null -eq $Builder) {
            $Builder = New-Builder
            if ($null -ne $LineEnding) {
                $Builder.DefaultLineEnding = $LineEnding
            }
        }

        $NumericTypes = @(
            [Byte].Name
            [Short].Name
            [Int32].Name
            [Long].Name
            [SByte].Name
            [ushort].Name
            [uint32].Name
            [ulong].Name
            [float].Name
            [double].Name
            [decimal].Name
        )
        $NewLinePattern = '(\r\n|\r|\n)'
    }

    process {
        $Indent = ' ' * $Indentation
        $AddLineParams = @{}
        if ($null -ne $LineEnding) {
            $AddLineParams.LineEnding = $LineEnding
        }
        foreach ($Key in $FrontMatter.Keys) {
            $Value = $FrontMatter.$Key
            switch ($Value.GetType().Name) {
                'String' {
                    if ($Value -match $NewLinePattern) {
                        $Builder | Add-Line @AddLineParams -Content "$Indent${Key}: |-"
                        $Value -split $NewLinePattern | ForEach-Object -Process {
                            $Builder | Add-Line @AddLineParams -Content "$Indent  $Value"
                        }
                    } else {
                        $Builder | Add-Line @AddLineParams "$Indent${Key}: $Value"
                    }
                }
                'Boolean' {
                    $Content = "$Indent${Key}: $($Value.ToString().ToLowerInvariant())"
                    $Builder | Add-Line @AddLineParams -Content $Content
                }
                $NumericTypes {
                    $Builder | Add-Line @AddLineParams "$Indent${Key}: $Value"
                }
                'Hashtable' {
                    $RecursiveParams = @{
                        Indentation = $Indentation + 2
                        FrontMatter = $Value
                    }
                    if ($null -ne $LineEnding) {
                        $RecursiveParams.LineEnding = $LineEnding
                    }

                    $Builder | Add-Line @AddLineParams "$Indent${Key}:"
                    $Builder | Add-FrontMatterYamlKey @RecursiveParams
                }
            }
        }
    }
}
