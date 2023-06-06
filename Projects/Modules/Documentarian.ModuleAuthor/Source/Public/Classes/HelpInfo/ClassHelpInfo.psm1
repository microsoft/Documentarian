# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Collections.Specialized
using module ./AttributeHelpInfo.psm1
using module ./ClassMethodHelpInfo.psm1
using module ./ClassPropertyHelpInfo.psm1
using module ./ConstructorOverloadHelpInfo.psm1
using module ./ExampleHelpInfo.psm1

class ClassHelpInfo {
    # The name of the defined PowerShell class.
    [string]                        $Name = ''
    # A short description of the class.
    [string]                        $Synopsis = ''
    # A full description of the class, with details.
    [string]                        $Description = ''
    # A list of examples showing how you can use the class.
    [ExampleHelpInfo[]]             $Examples = @()
    # Additional information about the class.
    [string]                        $Notes = ''
    # A list of full type names for the classes this class inherits from and
    # the interfaces this class implements.
    [string[]] $BaseTypes = @()
    # A list of attributes applied to the class.
    [AttributeHelpInfo[]] $Attributes = @()
    # A list of constructor overloads for the class with their documentation.
    [ConstructorOverloadHelpInfo[]] $Constructors = @()
    # A list of methods defined by the class with their documentation.
    [ClassMethodHelpInfo[]] $Methods = @()
    # A list of properties defined by the class with their documentation.
    [ClassPropertyHelpInfo[]] $Properties = @()

    # A list of links used in your documentation. Not retrieved from source.
    [OrderedDictionary] $LinkReferences = @{}

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
        if ($this.BaseTypes.Count -gt 0) {
            $Metadata.Add('BaseTypes', [string[]]($this.BaseTypes.Trim()))
        } else {
            $Metadata.Add('BaseTypes', [string[]]@())
        }
        if ($this.Attributes.Count -gt 0) {
            $Metadata.Add('Attributes', [OrderedDictionary[]]($this.Attributes.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Attributes', [OrderedDictionary[]]@())
        }
        if ($this.Constructors.Count -gt 0) {
            $Metadata.Add('Constructors', [OrderedDictionary[]]($this.Constructors.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Constructors', [OrderedDictionary[]]@())
        }
        if ($this.Methods.Count -gt 0) {
            $Metadata.Add('Methods', [OrderedDictionary[]]($this.Methods.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Methods', [OrderedDictionary[]]@())
        }
        if ($this.Properties.Count -gt 0) {
            $Metadata.Add('Properties', [OrderedDictionary[]]($this.Properties.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Properties', [OrderedDictionary[]]@())
        }
        $Metadata.Add('LinkReferences', $this.LinkReferences)

        return $Metadata
    }
}
