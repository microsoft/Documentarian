# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Enums/ProviderFlags.psm1

class ParameterInfo {
  [string]$Name
  [string]$HelpText
  [string]$Type
  [string]$ParameterSet
  [string]$Aliases
  [bool]$Required
  [string]$Position
  [string]$Pipeline
  [bool]$Wildcard
  [bool]$Dynamic
  [bool]$FromRemaining
  [bool]$DontShow
  [ProviderFlags]$ProviderFlags

  ParameterInfo(
    [System.Management.Automation.ParameterMetadata]$param,
    [ProviderFlags]$ProviderFlags
  ) {
    $this.Name = $param.Name
    $this.HelpText = if ($null -eq $param.Attributes.HelpMessage) {
      '{{Placeholder}}'
    } else {
      $param.Attributes.HelpMessage
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
    $this.Pipeline = 'ByValue ({0}), ByName ({1})' -f $param.Attributes.ValueFromPipeline, $param.Attributes.ValueFromPipelineByPropertyName
    $this.Wildcard = $param.Attributes.TypeId.Name -contains 'SupportsWildcardsAttribute'
    $this.Dynamic = $param.IsDynamic
    $this.FromRemaining = $param.Attributes.ValueFromRemainingArguments
    $this.DontShow = $param.Attributes.DontShow
    $this.ProviderFlags = $ProviderFlags
  }

  [string]ToMarkdown() {
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
    $sbMarkdown.AppendLine("Required: $($this.Required)")
    $sbMarkdown.AppendLine("Position: $($this.Position)")
    $sbMarkdown.AppendLine('Default value: None')
    $sbMarkdown.AppendLine("Accept pipeline input: $($this.Pipeline)")
    $sbMarkdown.AppendLine("Accept wildcard characters: $($this.Wildcard)")
    <#
    $sbMarkdown.AppendLine("DontShow: $($this.DontShow)")
    $ProviderName = if ($this.ProviderFlags -eq 0xFF) {
        'All'
    } else {
        $this.ProviderFlags.ToString()
    }
    $sbMarkdown.AppendLine("Providers: $ProviderName")
    #>
    $sbMarkdown.AppendLine('```')
    $sbMarkdown.AppendLine()
    return $sbMarkdown.ToString()
  }
}
