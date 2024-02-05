# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Collections.Specialized

class BaseHelpInfo {

    BaseHelpInfo() {}

    BaseHelpInfo([OrderedDictionary]$metadata) {
        foreach ($Property in $metadata.Keys) {
            $this.$Property = $metadata.$Property
        }
    }

    [OrderedDictionary] ToMetadataDictionary() {
        return $this.ToMetadataDictionary($false)
    }

    [OrderedDictionary] ToMetadataDictionary([bool]$AddYamlFormatting) {
        $Metadata = [OrderedDictionary]::new([System.StringComparer]::OrdinalIgnoreCase)

        foreach ($Property in $this.GetType().GetProperties()) {
            $PropertyName = $Property.Name
            $PropertyValue = $this.psobject.Properties[$PropertyName].Value

            if ($null -eq $PropertyValue) {
                if ([BaseHelpInfo]::CanPropertyBeIntentionallyNull($Property)) {
                    $Metadata.Add($PropertyName, $null)
                }
                continue
            }

            [BaseHelpInfo]::AddToMetadataDictionary(
                $Metadata,
                $PropertyName,
                $PropertyValue,
                $AddYamlFormatting
            )
        }

        if ($AddYamlFormatting -and $null -ne $this.GetType()::AddYamlFormatting) {
            return $this.GetType()::AddYamlFormatting($Metadata)
        }

        return $Metadata
    }

    [string] ToJson() {
        return $this.ToMetadataDictionary() | ConvertTo-Json -Depth 99
    }

    [string] ToYaml() {
        return $this.ToMetadataDictionary($true) | yayaml\ConvertTo-Yaml -Depth 99
    }

    hidden static [void] AddToMetadataDictionary(
        [OrderedDictionary]$metadata,
        [string]$key,
        [string]$value
    ) {
        [BaseHelpInfo]::AddToMetadataDictionary($metadata, $key, $value, $false)
    }

    hidden static [void] AddToMetadataDictionary(
        [OrderedDictionary]$metadata,
        [string]$key,
        [string]$value,
        [bool]$AddYamlFormatting
    ) {
        if ([string]::isNullOrEmpty($value)) {
            $metadata.Add($key, '')
        } else {
            $metadata.Add($key, $value)
        }
    }

    hidden static [void] AddToMetadataDictionary(
        [OrderedDictionary]$metadata,
        [string]$key,
        [string[]]$values
    ) {
        [BaseHelpInfo]::AddToMetadataDictionary($metadata, $key, $values, $false)
    }

    hidden static [void] AddToMetadataDictionary(
        [OrderedDictionary]$metadata,
        [string]$key,
        [string[]]$values,
        [bool]$AddYamlFormatting
    ) {
        if ($values.Count -gt 0) {
            $metadata.Add($key, $values)
        } else {
            $metadata.Add($key, @())
        }
    }

    hidden static [void] AddToMetadataDictionary(
        [OrderedDictionary]$metadata,
        [string]$key,
        [System.ValueType]$value
    ) {
        [BaseHelpInfo]::AddToMetadataDictionary($metadata, $key, $value, $false)
    }

    hidden static [void] AddToMetadataDictionary(
        [OrderedDictionary]$metadata,
        [string]$key,
        [System.ValueType]$value,
        [bool]$AddYamlFormatting
    ) {
        if ($null -eq $value) {
            $metadata.Add($key, $null)
        } else {
            $metadata.Add($key, $value)
        }
    }

    hidden static [void] AddToMetadataDictionary(
        [OrderedDictionary]$metadata,
        [string]$key,
        [System.ValueType[]]$values
    ) {
        [BaseHelpInfo]::AddToMetadataDictionary($metadata, $key, $values, $false)
    }

    hidden static [void] AddToMetadataDictionary(
        [OrderedDictionary]$metadata,
        [string]$key,
        [System.ValueType[]]$values,
        [bool]$AddYamlFormatting
    ) {
        if ($null -ne $values -and $values.Length -gt 0) {
            $metadata.Add($key, $values)
        } else {
            $metadata.Add($key, @())
        }
    }

    hidden static [void] AddToMetadataDictionary(
        [OrderedDictionary]$metadata,
        [string]$key,
        [BaseHelpInfo]$value
    ) {
        [BaseHelpInfo]::AddToMetadataDictionary($metadata, $key, $value, $false)
    }

    hidden static [void] AddToMetadataDictionary(
        [OrderedDictionary]$metadata,
        [string]$key,
        [BaseHelpInfo]$value,
        [bool]$AddYamlFormatting
    ) {
        if ($null -ne $value) {
            $dictionary = $value.ToMetadataDictionary($AddYamlFormatting)
            if ($AddYamlFormatting -and $null -ne $value.GetType()::AddYamlFormatting) {
                $metadata.Add($key, $value.GetType()::AddYamlFormatting($dictionary))
            } else {
                $metadata.Add($key, $dictionary)
            }
        } else {
            $metadata.Add($key, [OrderedDictionary]::new([System.StringComparer]::OrdinalIgnoreCase))
        }
    }

    hidden static [void] AddToMetadataDictionary(
        [OrderedDictionary]$metadata,
        [string]$key,
        [BaseHelpInfo[]]$values
    ) {
        [BaseHelpInfo]::AddToMetadataDictionary($metadata, $key, $values, $false)
    }

    hidden static [void] AddToMetadataDictionary(
        [OrderedDictionary]$metadata,
        [string]$key,
        [BaseHelpInfo[]]$values,
        [bool]$AddYamlFormatting
    ) {
        if ($null -ne $values -and $values.Length -gt 0) {
            $dictionaries = @()
            foreach ($value in $values) {
                $dictionary = $value.ToMetadataDictionary($AddYamlFormatting)
                if ($AddYamlFormatting -and $null -ne $value.GetType()::AddYamlFormatting) {
                    $dictionary = $value.GetType()::AddYamlFormatting($dictionary)
                }
                $dictionaries += $dictionary
            }
            $metadata.Add($key, [OrderedDictionary[]]($dictionaries))
        } else {
            $metadata.Add($key, [OrderedDictionary[]]@())
        }
    }

    hidden static [bool] CanPropertyBeIntentionallyNull(
        [System.Reflection.PropertyInfo]$property
    ) {
        $CustomAttributes = $property.CustomAttributes

        foreach ($Attribute in $CustomAttributes) {
            if ($Attribute.AttributeType.Name -eq 'AllowNullAttribute') {
                return $true
            }
        }

        return $false
    }
}
