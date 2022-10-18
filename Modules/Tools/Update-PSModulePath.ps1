# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
#requires -Version 7.2
Function Update-PSModulePath {
  <#
  .SYNOPSIS
    Munge the PSModulePath to include the project root if it doesn't already.
  .DESCRIPTION
    This function ensures the project root is included in the PSModulePath.
  .EXAMPLE
    Update-PSModulePath

    The command checks to see if the project root is already included in `$env:PSModulePath` and, if
    it is not, appends it to the end of the variable with the appropriate path separator for the
    operating system.
  #>

  [CmdletBinding()]
  param()

  process {
    $ProjectRoot = Split-Path -Parent -Path $PSScriptRoot
    $PathSeparator = $IsWindows ? ';' : ':'
    $PathSegments = $env:PSModulePath -split [regex]::Escape($PathSeparator)

    if ($PathSegments -notcontains $ProjectRoot) {
      $env:PSModulePath += $PathSeparator + $ProjectRoot
    }
  }
}

