# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation

class ValidatePowerShellScriptPath : ValidateArgumentsAttribute {
  [void]  Validate([object]$arguments, [EngineIntrinsics]$engineIntrinsics) {
    $Path = $arguments

    if ([string]::IsNullOrWhiteSpace($path)) {
      throw [System.ArgumentNullException]::new()
    }

    try {
      $Item = Get-Item -Path $Path -ErrorAction Stop
    } catch [ItemNotFoundException] {
      throw [System.IO.FileNotFoundException]::new()
    }

    $MessagePrefix = 'Path must be the file path to a PowerShell file'

    $Provider = $Item.PSProvider.Name
    if ($Provider -ne 'FileSystem') {
      throw [System.ArgumentException]::new(
        "$MessagePrefix; specified provider '$Provider' is invalid."
      )
    }

    $Extension = $Item.Extension
    $ValidExtensions = @('.psd1', '.ps1', '.psm1')
    $isNotPowerShellFile = $Extension -notin $ValidExtensions
    if ($isNotPowerShellFile) {
      $Message = @(
        "Specified file '$Path' has extension '$extension',"
        'but it must be one of the following:'
              ($ValidExtensions -join ', ')
      ) -join ' '
      throw [System.ArgumentException]::new("$MessagePrefix; $Message")
    }
  }
}
