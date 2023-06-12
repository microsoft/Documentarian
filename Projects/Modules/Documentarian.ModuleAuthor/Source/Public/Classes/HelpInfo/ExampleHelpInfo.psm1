# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1

class ExampleHelpInfo {
    # The title for the example.
    [string] $Title = ''
    # The body text for the example.
    [string] $Body

    [OrderedDictionary] ToMetadataDictionary() {
        <#
            .SYNOPSIS
            Converts an instance of the class into a dictionary.

            .DESCRIPTION
            The `ToMetadataDictionary()` method converts an instance of the
            class into an ordered dictionary so you can export the
            documentation metadata into YAML or JSON.

            This makes it easier for you to use the data-docs model, which
            separates the content of the reference documentation from its
            presentation.
        #>

        $Metadata = [OrderedDictionary]::new([System.StringComparer]::OrdinalIgnoreCase)

        $Metadata.Add('Title', $this.Title.Trim())
        $Metadata.Add('Body', $this.Body.Trim())

        return $Metadata
    }

    static [ExampleHelpInfo[]] Resolve ([OrderedDictionary]$help) {
        if (($null -eq $help) -or ($help.Example.Count -eq 0)) {
            return @()
        }
        
        return $help.Example | ForEach-Object -Process {
            [ExampleHelpInfo]@{
                Title = $_.Value
                Body  = $_.Content.Trim()
            }
        }
    }

    static [ExampleHelpInfo[]] Resolve ([AstInfo]$astInfo) {
        $help = $astInfo.DecoratingComment.ParsedValue

        if (($null -eq $help) -or ($help.Example.Count -eq 0)) {
            return @()
        }
        
        return $help.Example | ForEach-Object -Process {
            [ExampleHelpInfo]@{
                Title = $_.Value
                Body  = $_.Content.Trim()
            }
        }
    }
}
