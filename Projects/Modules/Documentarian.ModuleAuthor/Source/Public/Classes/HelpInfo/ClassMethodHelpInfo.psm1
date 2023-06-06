# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Collections.Specialized
using module ./MethodOverloadHelpInfo.psm1

class ClassMethodHelpInfo {
    # The name of the method, shared by all overloads.
    [string] $Name
    # A short description of the method.
    [string] $Synopsis = ''
    # The list of overloads for this method with their documentation.
    [MethodOverloadHelpInfo[]] $Overloads = @()

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
        $Metadata.Add('Overloads', [OrderedDictionary[]]($this.Overloads.ToMetadataDictionary()))
        return $Metadata
    }
}
