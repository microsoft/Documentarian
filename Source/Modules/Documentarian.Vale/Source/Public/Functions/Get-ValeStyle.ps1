# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ..\Classes\ValeRule.psm1
using module ..\Classes\ValeStyle.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/Get-ValeConfiguration.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Get-ValeStyle {
  [CmdletBinding()]
  param(
    [Parameter(ParameterSetName = 'ByName', Position = 0)]
    [SupportsWildcards()]
    [string]$Name,

    [Parameter(ParameterSetName = 'ByName')]
    [string]$Configuration = ${env:VALE.INI}
  )

  begin {
    $Styles = @()
    try {
      $ValeConfiguration = Get-ValeConfiguration -Path $Configuration
      if ($Name -eq '') { $Name = '*' }
      Get-ChildItem -Directory $ValeConfiguration.StylesPath -Exclude Vocab |
        Where-Object Name -Like $Name |
        ForEach-Object {
          $Styles += [ValeStyle]::new($_.Name, $_.FullName)
        }
    } catch {
      Write-Error -Message $_
    }
  }

  process {
    foreach ($style in $Styles) {
      $rulenames = Get-ChildItem -Path $style.Path -Filter '*.yml'
      $rules = @()
      foreach ($rulename in $rulenames) {
        $rule = [ValeRule]::new($style.Name, $rulename.BaseName, $rulename.FullName)
        $rule.Properties = Get-Content -Path $rulename.FullName | ConvertFrom-Yaml -Ordered
        $rules += $rule
      }
      $style.Rules = $rules
      $style
    }
  }
}
