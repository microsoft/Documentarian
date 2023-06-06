# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Collections.Specialized
using module ./AttributeHelpInfo.psm1

class ClassPropertyHelpInfo {
    # The name of the defined property.
    [string] $Name
    # The full type name of the property.
    [string] $Type
    # The list of attributes applied to the property.
    [AttributeHelpInfo[]] $Attributes = @()
    <#
        The value an instance of the class has for this property unless
        overridden by a constructor or user.
    #>
    [string] $InitialValue
    # Indicates whether the property is hidden from IntelliSense.
    [bool] $IsHidden = $false
    <#
        Indicates whether the property is available on the class instead of an
        instance of the class.
    #>
    [bool] $IsStatic = $false
    # A short description of the property.
    [string] $Synopsis = ''
    # A longer description of the property with full details.
    [string] $Description = ''

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
        $Metadata.Add('Type', $this.Type.Trim())
        if ($this.Attributes.Count -gt 0) {
            $Metadata.Add('Attributes', [OrderedDictionary[]]($this.Attributes.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Attributes', [OrderedDictionary[]]@())
        }
        if ($null -eq $this.InitialValue) {
            $Metadata.Add('InitialValue', $null)
        } else {
            $Metadata.Add('InitialValue', $this.InitialValue)
        }
        $Metadata.Add('IsHidden', $this.IsHidden)
        $Metadata.Add('IsStatic', $this.IsStatic)

        return $Metadata
    }
}
