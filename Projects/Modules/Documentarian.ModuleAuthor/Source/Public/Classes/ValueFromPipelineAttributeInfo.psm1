class ValueFromPipelineAttributeInfo {
    [string]$Cmdlet
    [string]$Parameter
    [string]$ParameterType
    [string]$ValueFromPipeline
    [string]$ParameterSetName
    [string]$Module

    [string] ToString () {
        return @(
            "$($this.Module)/"
            "$($this.Cmdlet), "
            "Parameter: $($this.Parameter) <"
            "$($this.ParameterType)>, "
            "ValueFromPipeline: $($this.ValueFromPipeline)"
        ) -join ''
    }
}
