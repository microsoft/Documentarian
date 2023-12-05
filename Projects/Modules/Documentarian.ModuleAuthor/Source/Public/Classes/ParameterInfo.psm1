# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Enums/ProviderFlags.psm1

class ParameterInfo {
  # The name of the parameter
  [string] $Name
  # The parameter's help description.
  [string] $HelpText
  # The parameter's full type name.
  [string] $Type
  # The comma-separated list of parameter sets the parameter belongs to.
  [string] $ParameterSet
  # The comma-separated list of aliases for the parameter.
  [string] $Aliases
  # Whether the parameter is mandatory.
  [bool[]] $Required
  # The position of the parameter in each parameter set.
  [string[]] $Position
  # Whether and how the parameter accepts pipeline input by parameter set.
  [string[]] $Pipeline
  # Whether the parameter supports wildcard characters.
  [bool] $Wildcard
  # Whether the parameter is a dynamic parameter.
  [bool] $Dynamic
  # Whether the parameter accepts values from remaining arguments.
  [bool[]] $FromRemaining
  # Whether the parameter should be hidden from the user.
  [bool[]] $DontShow
  # The default value of the parameter by parameter set.
  [string[]] $DefaultValue
  # Whether the parameter is a credential parameter.
  [bool[]] $IsCredential
  # Whether the parameter is obsolete.
  [psobject] $IsObsolete
  # The provider flags for the parameter, indicating which providers it's
  # valid for.
  [ProviderFlags] $ProviderFlags

  ParameterInfo(
    [System.Management.Automation.ParameterMetadata]$param,
    [ProviderFlags]$ProviderFlags
  ) {
    $this.Name = $param.Name
    $this.HelpText = $param.Attributes.HelpMessage | Select-Object -First 1
    if ($this.HelpText.Length -eq 0) {
      $this.HelpText = '{{Placeholder}}'
    }
    $this.Type = $param.ParameterType.FullName
    $this.ParameterSet = if ($param.Attributes.ParameterSetName -eq '__AllParameterSets') {
      '(All)'
    } else {
      $param.Attributes.ParameterSetName -join ', '
    }
    $this.Aliases = $param.Aliases -join ', '
    $this.Required = $param.Attributes.Mandatory
    $this.Position = if ($param.Attributes.Position -lt 0) {
      'Named'
    } else {
      $param.Attributes.Position
    }
    $this.Pipeline = 'ByValue ({0}), ByName ({1})' -f ($param.Attributes.ValueFromPipeline -join ','),
      ($param.Attributes.ValueFromPipelineByPropertyName -join ',')
    $this.Wildcard = $param.Attributes.TypeId.Name -contains 'SupportsWildcardsAttribute'
    $this.Dynamic = $param.IsDynamic
    $this.FromRemaining = $param.Attributes.ValueFromRemainingArguments
    $this.DontShow = $param.Attributes.DontShow
    if ($param.Attributes.TypeId.Name -contains 'PSDefaultValueAttribute') {
      $this.DefaultValue = $param.Attributes.Help -join ', '
    } else {
      $this.DefaultValue = 'None'
    }
    if ($param.Attributes.TypeId.Name -contains 'CredentialAttribute') {
      $this.IsCredential = $true
    } else {
      $this.IsCredential = $false
    }
    if ($param.Attributes.TypeId.Name -contains 'ObsoleteAttribute') {
      $this.IsObsolete = [pscustomobject]@{
        Message = $param.Attributes.Message
        IsError = $param.Attributes.IsError
      }
    } else {
      $this.IsObsolete = $false
    }
    $this.ProviderFlags = $ProviderFlags
  }

  [string]ToMarkdown([bool]$showAll) {
    <#
      .SYNOPSIS
        Converts the parameter info to a Markdown section.
      .DESCRIPTION
        Converts the parameter info to a Markdown section as expected by the
        **PlatyPS** module. It includes an H3 for the parameter (with the
        leading hyphen), the parameter's help text, and a YAML code block
        containing the parameter's metadata.

        When the $showAll parameter is $true, the parameter's non-PlatyPS
        compliant metadata is included.

      .PARAMETER showAll
        Whether to include the parameter's non-PlatyPS compliant metadata.
    #>

    $builder = New-Builder
    $Builder | Add-Heading -Level 3 -Content $this.Name
    $Builder | Add-Line -Content $this.HelpText
    $Builder | Start-CodeFence -Language yaml
    $Builder | Add-Line -Content "Type: $($this.Type)"
    $Builder | Add-Line -Content "Parameter Sets: $($this.ParameterSet)"
    $Builder | Add-Line -Content "Aliases: $($this.Aliases)"
    $Builder | Add-Line -Content "Required: $($this.Required -join ', ')"
    $Builder | Add-Line -Content "Position: $($this.Position -join ', ')"
    if ($this.Type -eq 'System.Management.Automation.SwitchParameter') {
      $Builder | Add-Line -Content 'Default value: False'
    } else {
      $Builder | Add-Line -Content "Default value: $($this.DefaultValue)"
    }
    $Builder | Add-Line -Content "Accept pipeline input: $($this.Pipeline)"
    $Builder | Add-Line -Content "Accept wildcard characters: $($this.Wildcard)"
    if ($showAll) {
      $Builder | Add-Line -Content "Dynamic: $($this.Dynamic)"
      if ($this.Dynamic -and $this.ProviderFlags) {
        $ProviderName = if ($this.ProviderFlags -eq 0xFF) {
          'All'
        } else {
          $this.ProviderFlags.ToString()
        }
        $Builder | Add-Line -Content "Providers: $ProviderName"
      }
      $Builder | Add-Line -Content "Values from remaining args: $($this.FromRemaining -join ', ')"
      $Builder | Add-Line -Content "Do not show: $($this.DontShow -join ', ')"
      $Builder | Add-Line -Content "Is credential: $($this.IsCredential)"
      if ($this.IsObsolete -ne $false) {
        $Builder | Add-Line -Content 'Is obsolete: True'
        $Builder | Add-Line -Content "  - Message: $($this.IsObsolete.Message)"
        $Builder | Add-Line -Content "  - IsError: $($this.IsObsolete.IsError)"
      } else {
        $Builder | Add-Line -Content 'Is obsolete: False'
      }
    }
    $Builder | Stop-CodeFence
    $Builder | Add-Line

    return $Builder.ToString()
  }
}
