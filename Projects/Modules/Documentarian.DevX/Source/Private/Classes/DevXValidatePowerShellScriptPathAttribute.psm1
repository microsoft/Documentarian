# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation

class DevXValidatePowerShellScriptPathAttribute : ValidateArgumentsAttribute {
  <#
    .SYNOPSIS
    Validates that the specified path is for a valid PowerShell script file.

    .DESCRIPTION
    This attribute validates that the specified path is for a valid PowerShell script file. The
    path must be a file path to a PowerShell file with one of the following extensions: `.ps1`,
    `.psm1`, or `.psd1`. The file must exist and be accessible.
  #>

  #region Static properties
  #endregion Static properties

  #region Static methods
  #endregion Static methods

  #region Instance properties
  #endregion Instance properties

  #region Instance methods

  [void]  Validate([object]$arguments, [EngineIntrinsics]$engineIntrinsics) {
    $path = $arguments

    if ([string]::IsNullOrWhiteSpace($path)) {
      throw [System.ArgumentNullException]::new()
    }

    try {
      $item = Get-Item -Path $path -ErrorAction Stop
    } catch [ItemNotFoundException] {
      throw [System.IO.FileNotFoundException]::new()
    }

    $messagePrefix = 'Path must be the file path to a PowerShell file'

    $provider = $Item.PSProvider.Name
    if ($provider -ne 'FileSystem') {
      throw [System.ArgumentException]::new(
        "$messagePrefix; specified provider '$provider' is invalid."
      )
    }

    $extension           = $Item.Extension
    $validExtensions     = @('.psd1', '.ps1', '.psm1')
    $isNotPowerShellFile = $Extension -notin $ValidExtensions

    if ($isNotPowerShellFile) {
      $errorMessage = @(
        "Specified file '$path' has extension '$extension',"
        'but it must be one of the following:'
          ($validExtensions -join ', ')
      ) -join ' '
      throw [System.ArgumentException]::new("$messagePrefix; $errorMessage")
    }
  }

  #endregion Instance methods

  #region Constructors
  #endregion Constructors
}
