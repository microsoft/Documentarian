# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function New-LoadOrderJson {
  <#
    .SYNOPSIS
  #>

  [CmdletBinding()]
  param(
    [Parameter()]
    [string[]]
    $FolderPath,

    [Parameter()]
    [string]
    $CopyrightNotice,

    [Parameter()]
    [string]
    $LicenseNotice
  )

  begin {
    $content = @()
    if (-not [string]::IsNullOrEmpty($CopyrightNotice)) {
      $content += "// $CopyrightNotice"
    }
    if (-not [string]::IsNullOrEmpty($LicenseNotice)) {
      $content += "// $LicenseNotice"
    }
    $content += @(
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
    $content = $content -join "`n"

    $sharedParameters = @{
      Name     = '.LoadOrder.jsonc'
      ItemType = 'File'
      Force    = $true
    }
  }

  process {
    foreach ($folder in $FolderPath) {
      $file = New-Item -Path $folder @SharedParameters

      $content | Out-File -FilePath $file -Encoding utf8NoBOM -Force

      $file
    }
  }

  end {

  }
}
