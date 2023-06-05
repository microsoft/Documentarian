# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Enums/ProviderFlags.psm1

class ParameterInfo {
  [string]$Name
  [string]$HelpText
  [string]$Type
  [string]$ParameterSet
  [string]$Aliases
  [bool[]]$Required
  [string[]]$Position
  [string[]]$Pipeline
  [bool]$Wildcard
  [bool]$Dynamic
  [bool[]]$FromRemaining
  [bool[]]$DontShow
  [string[]]$DefaultValue
  [bool[]]$IsCredential
  [psobject]$IsObsolete
  [ProviderFlags]$ProviderFlags

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
    $sbMarkdown = [System.Text.StringBuilder]::new()
    $sbMarkdown.AppendLine("### -$($this.Name)")
    $sbMarkdown.AppendLine()
    $sbMarkdown.AppendLine($this.HelpText)
    $sbMarkdown.AppendLine()
    $sbMarkdown.AppendLine('```yaml')
    $sbMarkdown.AppendLine("Type: $($this.Type)")
    $sbMarkdown.AppendLine("Parameter Sets: $($this.ParameterSet)")
    $sbMarkdown.AppendLine("Aliases: $($this.Aliases)")
    $sbMarkdown.AppendLine()
    $sbMarkdown.AppendLine("Required: $($this.Required -join ', ')")
    $sbMarkdown.AppendLine("Position: $($this.Position -join ', ')")
    if ($this.Type -is [System.Management.Automation.SwitchParameter]) {
      $sbMarkdown.AppendLine('Default value: False')
    } else {
      $sbMarkdown.AppendLine("Default value: $($this.DefaultValue)")
    }
    $sbMarkdown.AppendLine("Accept pipeline input: $($this.Pipeline)")
    $sbMarkdown.AppendLine("Accept wildcard characters: $($this.Wildcard)")
    if ($showAll) {
      $sbMarkdown.AppendLine("Dynamic: $($this.Dynamic)")
      if ($this.Dynamic -and $this.ProviderFlags) {
        $ProviderName = if ($this.ProviderFlags -eq 0xFF) {
          'All'
        } else {
          $this.ProviderFlags.ToString()
        }
        $sbMarkdown.AppendLine("Providers: $ProviderName")
      }
      $sbMarkdown.AppendLine("Values from remaining args: $($this.FromRemaining -join ', ')")
      $sbMarkdown.AppendLine("Do not show: $($this.DontShow -join ', ')")
      $sbMarkdown.AppendLine("Is credential: $($this.IsCredential)")
      if ($this.IsObsolete -ne $false) {
        $sbMarkdown.AppendLine('Is obsolete: True')
        $sbMarkdown.AppendLine("  - Message: $($this.IsObsolete.Message)")
        $sbMarkdown.AppendLine("  - IsError: $($this.IsObsolete.IsError)")
      } else {
        $sbMarkdown.AppendLine('Is obsolete: False')
      }
    }
    $sbMarkdown.AppendLine('```')
    $sbMarkdown.AppendLine()
    return $sbMarkdown.ToString()
  }
}
