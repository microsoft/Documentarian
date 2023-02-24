# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
class ValeRule {
	[string]$Style
	[string]$Name
  [string]$Path
  [ordered]$Properties

  ValeRule([string]$Style, [string]$Name, [string]$Path) {
    $this.Style = $Style
    $this.Name = $Name
    $this.Path = $Path
    $this.Properties = $null
  }
}
