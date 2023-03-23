class SupportsWildcardsAttributeInfo {
    [string]$Cmdlet
    [string]$Parameter
    [string]$ParameterType
    [bool]$SupportsWildcards
    [string]$ParameterSetName
    [string]$Module

    [string] ToString () {
        return @(
            "$($this.Module)/"
            "$($this.Cmdlet), "
            "Parameter: $($this.Parameter) <"
            "$($this.ParameterType)>"
            "SupportsWildcards: $($this.SupportsWildcards)"
        ) -join ''
    }
}
