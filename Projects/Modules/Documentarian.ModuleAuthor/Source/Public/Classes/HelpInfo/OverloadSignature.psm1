# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Collections.Specialized

class OverloadSignature {
    <#
        The full signature for the overload, including the type and name of
        every parameter.
    #>
    [string] $Full
    <#
        The short signature for the overload, including only the type names for
        every parameter.
    #>
    [string] $TypeOnly

    [string] ToString() {
        <#
            .SYNOPSIS
            Returns a string representing the full signature.

            .DESCRIPTION
            Returns a string representing the full signature. This is a
            convenience method instead of requiring you to access the **Full**
            property directly.

            This method is automatically called when an **OverloadSignature**
            is interpolated into a string.
        #>
        return $this.Full
    }

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

        $Metadata.Add('Full', $this.Full.Trim())
        $Metadata.Add('TypeOnly', $this.TypeOnly.Trim())

        return $Metadata
    }
}
