# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Collections.Specialized
using module ./AttributeHelpInfo.psm1
using module ./ExampleHelpInfo.psm1
using module ./OverloadExceptionHelpInfo.psm1
using module ./OverloadParameterHelpInfo.psm1
using module ./OverloadSignature.psm1

class OverloadHelpInfo {
    # The signature for the overload, distinguishing it from other overloads.
    [OverloadSignature] $Signature
    # A short description of the overload's purpose.
    [string] $Synopsis = ''
    # A full description of the overload's purpose, with details.
    [string] $Description = ''
    # A list of examples showing how to use the overload.
    [ExampleHelpInfo[]] $Examples = @()
    # Indicates whether the overload is hidden from IntelliSense.
    [bool] $IsHidden = $false
    # A list of attributes applied to the overload with their definition.
    [AttributeHelpInfo[]] $Attributes = @()
    # A list of parameters for the overload, with their documentation.
    [OverloadParameterHelpInfo[]] $Parameters = @()
    <#
        A list of exception types the overload may return, with information
        about when and why the overload would return them.
    #>
    [OverloadExceptionHelpInfo[]] $Exceptions = @()

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

        $Metadata.Add('Signature', $this.Signature.ToMetadataDictionary())
        $Metadata.Add('Synopsis', $this.Synopsis.Trim())
        $Metadata.Add('Description', $this.Description.Trim())
        if ($this.Examples.Count -gt 0) {
            $Metadata.Add('Examples', [OrderedDictionary[]]($this.Examples.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Examples', [OrderedDictionary[]]@())
        }
        $Metadata.Add('IsHidden', $this.IsHidden)
        if ($this.Attributes.Count -gt 0) {
            $Metadata.Add('Attributes', [OrderedDictionary[]]($this.Attributes.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Attributes', [OrderedDictionary[]]@())
        }
        if ($this.Parameters.Count -gt 0) {
            $Metadata.Add('Parameters', [OrderedDictionary[]]($this.Parameters.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Parameters', [OrderedDictionary[]]@())
        }
        if ($this.Exceptions.Count -gt 0) {
            $Metadata.Add('Exceptions', [OrderedDictionary[]]($this.Exceptions.ToMetadataDictionary()))
        } else {
            $Metadata.Add('Exceptions', [OrderedDictionary[]]@())
        }

        return $Metadata
    }
}
