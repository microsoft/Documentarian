# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Collections.Specialized

class AttributeHelpInfo {
    # The attribute's full type name.
    [string] $Type
    # The definition of the attribute as applied in the source code.
    [string] $Definition

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

        $Metadata.Add('Type', $this.Type.Trim())
        $Metadata.Add('Definition', $this.Definition.Trim())

        return $Metadata
    }
}
