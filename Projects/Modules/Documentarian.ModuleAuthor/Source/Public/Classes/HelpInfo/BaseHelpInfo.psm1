# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Collections.Specialized

class BaseHelpInfo {
    [OrderedDictionary] ToMetadataDictionary() {
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

            [BaseHelpInfo]::AddToMetadataDictionary($Metadata, $PropertyName, $PropertyValue)
        }

        return $Metadata
    }

    [string] ToJson() {
        return $this.ToMetadataDictionary() | ConvertTo-Json -Depth 99
    }

    hidden static [void] AddToMetadataDictionary(
        [OrderedDictionary]$metadata,
        [string]$key,
        [string]$value
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
        if ($null -ne $value) {
            $metadata.Add($key, $value.ToMetadataDictionary())
        } else {
            $metadata.Add($key, [OrderedDictionary]::new([System.StringComparer]::OrdinalIgnoreCase))
        }
    }

    hidden static [void] AddToMetadataDictionary(
        [OrderedDictionary]$metadata,
        [string]$key,
        [BaseHelpInfo[]]$values
    ) {
        if ($null -ne $values -and $values.Length -gt 0) {
            $metadata.Add($key, [OrderedDictionary[]]($values.ToMetadataDictionary()))
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