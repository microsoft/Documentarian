# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Collections.Specialized
using module ./EnumValueHelpInfo.psm1
using module ./ExampleHelpInfo.psm1

class EnumHelpInfo {
    # The name of the enumeration.
    [string] $Name
    # A short description of the enumeration's purpose.
    [string] $Synopsis = ''
    # A full description of the enumeration's purpose, with details.
    [string] $Description = ''
    # The list of examples showing how you can use the enumeration.
    [ExampleHelpInfo[]] $Examples = @()
    # Additional notes about the enumeration.
    [string] $Notes = ''
    # Whether the enumeration represents bit flags.
    [boolean] $IsFlagsEnum = $false
    # The list of values defined by the enumeration with their documentation.
    [EnumValueHelpInfo[]] $Values = @()

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

        $Metadata = [OrderedDictionary]::new()

        $Metadata.Add('Name', $this.Name.Trim())
        $Metadata.Add('Synopsis', $this.Synopsis.Trim())
        $Metadata.Add('Description', $this.Description.Trim())
        if ($this.Examples.Count -gt 0) {
            $Metadata.Add('Examples', [OrderedDictionary[]]($this.Examples.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Examples', [OrderedDictionary[]]@())
        }
        $Metadata.Add('Notes', $this.Notes.Trim())
        $Metadata.Add('IsFlagsEnum', $this.IsFlagsEnum)
        $Metadata.Add('Values', [OrderedDictionary[]]($this.Values.ToMetadataDictionary()))

        return $Metadata
    }
}
