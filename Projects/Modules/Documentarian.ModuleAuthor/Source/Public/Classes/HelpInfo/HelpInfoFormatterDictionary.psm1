# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ./HelpInfoFormatter.psm1

class HelpInfoFormatterDictionary : System.Collections.Specialized.OrderedDictionary {
    <#
        .SYNOPSIS
            A dictionary of HelpInfoFormatter definitions to use when formatting help info.
    #>

    HelpInfoFormatterDictionary() : base([System.StringComparer]::OrdinalIgnoreCase) {
        <#
            .SYNOPSIS
                Creates a new instance without any formatters. The dictionary isn't case sensitive.
        #>
    }
    HelpInfoFormatterDictionary([System.StringComparer]$comparer) : base($comparer) {
        <#
            .SYNOPSIS
                Creates a new instance without any formatters. The dictionary uses the specified
                comparer for keys.
        #>
    }

    HelpInfoFormatterDictionary(
        [HelpInfoFormatter]$defaultFormatter
    ) : base([System.StringComparer]::OrdinalIgnoreCase) {
        <#
            .SYNOPSIS
                Creates a new instance with a default formatter.

            .DESCRIPTION
                Defines the dictionary with a default formatter. The dictionary isn't case
                sensitive.
            
            .PARAMETER defaultFormatter
                The default formatter to use when formatting help info.
        #>

        $this.Add('Default', $defaultFormatter)
    }

    HelpInfoFormatterDictionary(
        [HelpInfoFormatter]$defaultFormatter,
        [HelpInfoFormatter]$defaultSectionFormatter
    ) : base([System.StringComparer]::OrdinalIgnoreCase) {
        <#
            .SYNOPSIS
                Creates a new instance with a default formatter and a default section formatter.

            .DESCRIPTION
                Defines the dictionary with a default formatter and a default section formatter.
                The dictionary isn't case sensitive. The section formatter is used when formatting
                a group of the same `HelpInfo` type, such as a group of `ParameterHelpInfo` or
                `ExampleHelpInfo` objects.
            
            .PARAMETER defaultFormatter
                The default formatter to use when formatting a single instance.
            
            .PARAMETER defaultSectionFormatter
                The default formatter to use when formatting a group of instances.
        #>

        $this.Add('Default', $defaultFormatter)
        $this.Add('Section', [ordered]@{
            'Default' = $defaultSectionFormatter
        })
    }

    HelpInfoFormatterDictionary(
        [System.Collections.Specialized.OrderedDictionary]$formatters
    ) : base([System.StringComparer]::OrdinalIgnoreCase) {
        <#
            .SYNOPSIS
                Creates a new instance with the specified formatters.

            .DESCRIPTION
                Defines the dictionary with the specified formatters. The dictionary isn't case
                sensitive.
            
            .PARAMETER formatters
                The formatters to use when formatting help info. Must be an ordered dictionary. If
                the dictionary doesn't contain a key named `Default`, the first formatter is used
                as the default formatter.
        #>

        [HelpInfoFormatterDictionary]::AddFormatters($this, $formatters)
    }

    HelpInfoFormatterDictionary(
        [System.Collections.Specialized.OrderedDictionary]$formatters,
        [System.Collections.Specialized.OrderedDictionary]$sectionFormatters
    ) : base([System.StringComparer]::OrdinalIgnoreCase) {
        <#
            .SYNOPSIS
                Creates a new instance with the specified formatters and section formatters.

            .DESCRIPTION
                Defines the dictionary with the specified formatters and section formatters. The
                dictionary isn't case sensitive. The section formatters are used when formatting
                a group of the same `HelpInfo` type, such as a group of `ParameterHelpInfo` or
                `ExampleHelpInfo` objects.
            
            .PARAMETER formatters
                The formatters to use when formatting a single instance. Must be an ordered
                dictionary. If the dictionary doesn't contain a key named `Default`, the first
                formatter is used as the default formatter.
            
            .PARAMETER sectionFormatters
                The formatters to use when formatting a group of instances. Must be an ordered
                dictionary. If the dictionary doesn't contain a key named `Default`, the first
                formatter is used as the default formatter.
        #>

        $this.Section = [System.Collections.Specialized.OrderedDictionary]::new()

        [HelpInfoFormatterDictionary]::AddFormatters($this, $formatters)
        [HelpInfoFormatterDictionary]::AddFormatters($this.Section, $sectionFormatters)
    }

    static hidden AddFormatters(
        [System.Collections.Specialized.OrderedDictionary]$dictionary,
        [System.Collections.Specialized.OrderedDictionary]$formatters
    ) {
        <#
            .SYNOPSIS
                Adds the specified formatters to the specified dictionary.

            .DESCRIPTION
                Adds the specified formatters to the specified dictionary. If the dictionary
                doesn't contain a key named `Default`, the first formatter is used as the default
                formatter.
            
            .PARAMETER dictionary
                The dictionary to add the formatters to. Typically either the
                HelpInfoFormatterDictionary itself or the `Section` key of the dictionary.
            
            .PARAMETER formatters
                The formatters to add to the dictionary. Must be an ordered dictionary. Every key
                must be a string, every value must be a `HelpInfoFormatter` object. If the
                dictionary doesn't contain a key named `Default`, the first formatter is used as
                the default formatter.
        #>

        if ($null -ne $formatters.Default) {
            [HelpInfoFormatterDictionary]::ValidateValue($formatters.Default)
            $dictionary.Add('Default', $formatters.Default)
        }
        foreach ($formatter in $formatters.Keys.Where{ $_ -ne 'Default' }) {
            [HelpInfoFormatterDictionary]::ValidateKeyValue(
                $formatter,
                $formatters[$formatter]
            )

            if ($null -eq $dictionary.Default) {
                $dictionary.Add('Default', $formatters[$formatter])
            }

            $dictionary.Add($formatter, $formatters[$formatter])
        }
    }

    hidden static ValidateValue([object]$value) {
        if ($value -isnot [HelpInfoFormatter]) {
            throw [System.ArgumentException]::new(
                'The values must be of type HelpInfoFormatter.'
            )
        }
    }

    hidden static ValidateKeyValue([object]$key, [object]$value) {
        if ($key -isnot [string]) {
            throw [System.ArgumentException]::new(
                'The keys must be strings.'
            )
        }
        if ($key -eq 'Section') {
            throw [System.ArgumentException]::new(
                "The key 'Section' is reserved and cannot be used."
            )
        }

        [HelpInfoFormatterDictionary]::ValidateValue($value)
    }
}
