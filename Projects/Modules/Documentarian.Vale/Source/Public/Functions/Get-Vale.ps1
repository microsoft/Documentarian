# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/ValeApplicationInfo.psm1

function Get-Vale {
  [CmdletBinding()]
  [OutputType([ValeApplicationInfo])]
  param()

  process {
    Write-Verbose 'Checking for vale in workspace...'
    $Folder = Get-Location
    do {
      $ValeCommand = Get-Command "$Folder/.vale/vale" -ErrorAction Ignore
      $Folder = Split-Path -Path $Folder -Parent
    } until (($null -ne $ValeCommand) -or ([string]::IsNullOrEmpty($Folder)))

    if ($null -eq $ValeCommand) {
      Write-Verbose 'Vale not found in workspace. Checking user scope...'
      $ValeCommand = Get-Command '~/.vale/vale' -ErrorAction Ignore
    }

    if ($null -eq $ValeCommand) {
      Write-Verbose 'Vale not found in user scope. Checking PATH...'
      $ValeCommand = Get-Command -Name vale -ErrorAction Ignore
    }

    if ($null -eq $ValeCommand) {
      $Message = @(
        "Can't find vale installed in workspace, home directory, or PATH."
        'You can use the Install-Vale command or use your package manager to install it.'
      ) -join ' '
      throw  $Message
    }

    return [ValeApplicationInfo]::new($ValeCommand)
  }
}
