# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Collections.Specialized
using module ./OverloadHelpInfo.psm1

class MethodOverloadHelpInfo : OverloadHelpInfo {
    <#
        The full type name of the overload's output. If the overload doesn't
        return any output, this value should be `System.Void`.
    #>
    [string] $ReturnType
    <#
        Indicates whether the overload is available on the class itself instead
        of an instance of the class.
    #>
    [bool] $IsStatic = $false

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
        $Metadata.Add('ReturnType', $this.ReturnType.Trim())
        $Metadata.Add('IsHidden', $this.IsHidden)
        $Metadata.Add('IsStatic', $this.IsStatic)
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
