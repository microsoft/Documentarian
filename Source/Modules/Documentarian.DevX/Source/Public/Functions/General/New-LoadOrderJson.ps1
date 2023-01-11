# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function New-LoadOrderJson {
  [CmdletBinding()]
  param(
    [string[]]$FolderPath,
    [string]$CopyrightNotice,
    [string]$LicenseNotice
  )

  begin {
    $Content = @()
    if (![string]::IsNullOrEmpty($CopyrightNotice)) {
      $Content += "// $CopyrightNotice"
    }
    if (![string]::IsNullOrEmpty($LicenseNotice)) {
      $Content += "// $LicenseNotice"
    }
    $Content += @(
      "// Note: The items in this file are loaded in the order they're specified."
      '['
      '    // This example exists until a JSON schema is defined.'
      '    // {'
      '    //     "Name": "Foo",'
      '    //     "IgnoreForBuild": false,'
      '    //     "IgnoreForTest": false'
      '    // }'
      ']'
    )

    $Content = $Content -join "`n"
    $SharedParameters = @{
      Name     = '.LoadOrder.jsonc'
      ItemType = 'File'
      Force    = $true
    }
  }

  process {
    foreach ($Folder in $FolderPath) {
      $File = New-Item -Path $Folder @SharedParameters
      $Content | Out-File -FilePath $File -Encoding utf8NoBOM -Force
      $File
    }
  }
}
