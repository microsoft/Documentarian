# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class HelpInfoTestClassBare {
    [ValidateNotNullOrEmpty()] [string] $First
    static [int] $Second = 3
    hidden [ValidateRange(1, 5)] [int] $Third
    hidden static [string] $Fourth = 'Default value'

    [void] DoNothing() {}

    [void] DoNothing([string]$first) {}

    [void] DoNothing([string]$first, [int]$third) {}

    [string] Repeat([string]$a) {
        return ($a * 2)
    }

    hidden [string] Repeat([string]$a, [int]$b) {
        return ($a * $b)
    }

    static [string] ToUpper([string]$a) {
        if ([string]::IsNullOrEmpty($a)) {
            throw [System.ArgumentException]::new(
                "a can't be null or empty",
                'a'
            )
        }

        return $a.ToUpper()
    }
}