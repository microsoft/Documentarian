# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Collections.Specialized

class EnumValueHelpInfo {
    # The value's label.
    [string] $Label
    # The numerical value.
    [int] $Value = 0
    # The Markdown text explaining the value's purpose.
    [string] $Description = ''
    # Whether the value is explicitly defined in the enum.
    [bool] $HasExplicitValue = $false

    [string] ToString() {
        <#
            .SYNOPSIS
            Converts an instance of **EnumValueHelpInfo** into a string.

            .DESCRIPTION
            The `ToString()` method converts an instance of the
            **EnumValueHelpInfo** class into a string with the instance's
            **Label** and **Value** on the first line,followed by the
            instance's **Description on the next line.

            .EXAMPLE
            ```powershell
            $enumValue = [EnumValueHelpInfo]@{
                Label       = 'NoCache'
                Value       = 4
                Description = 'Indicates the service should ignore caching.'
            }
            $enumValue.ToString()
            ```

            ```output
            NoCache (4):
            Indicates the service should ignore caching.
            ```
        #>

        return "$($this.Label) ($($this.Value)):`n$($this.Description)"
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

        $Metadata.Add('Label', $this.Label.Trim())
        $Metadata.Add('Value', $this.Value)
        $Metadata.Add('Description', $this.Description.Trim())

        return $Metadata
    }
}
