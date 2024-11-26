# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function New-ConfigurationJson {
  <#
    .SYNOPSIS
  #>

  [CmdletBinding()]
  param(
    [Parameter()]
    [string]
    $FolderPath = (Get-Location),

    [Parameter()]
    [string]
    $Name,

    [Parameter()]
    [guid]
    $Guid = (New-Guid),

    [Parameter()]
    [string]
    $CopyrightNotice,

    [Parameter()]
    [string]
    $LicenseNotice,

    [Parameter()]
    [string]
    $ProjectUri,

    [Parameter()]
    [string]
    $LicenseUri
  )

  begin {
    $shortName = ($Name -match '\.(?<ShortName>[^\.]+)$') ? $Matches.ShortName : $Name
    Write-Verbose "Short name is: $shortName"

    $filePath = Join-Path -Path $FolderPath -ChildPath '.DevX.jsonc'
  }

  process {
    $manifestData = @{
      RootModule        = "$Name.psm1"
      ModuleVersion     = '0.0.1'
      Guid              = "$Guid"
      ScriptsToProcess  = 'Init.ps1'
      VariablesToExport = '*'
    }

    if ($ProjectURI) {
      $manifestData.ProjectUri = $ProjectUri
    }
    if ($LicenseUri) {
      $manifestData.LicenseUri = $LicenseUri
    }

    $ConfigurationData = @{
      ManifestData         = $manifestData
      ModuleLineEnding     = ([string]::IsNullOrEmpty($LineEnding) ? "`n" : $LineEnding)
      ModuleName           = $Name
      ModuleVersion        = '0.0.1'
      OutputFolderPath     = './[[ManifestData.ModuleVersion]]'
      SourceFolderPath     = './Source'
      SourceInitScriptPath = './Source/Init.ps1'
      UsingModuleList      = $false
    }

    if ($CopyrightNotice) {
      $ConfigurationData.ModuleCopyrightNotice = $CopyrightNotice
    }
    if ($LicenseNotice) {
      $ConfigurationData.ModuleLicenseNotice = $LicenseNotice
    }

    $data = New-Object -TypeName ordered

    foreach ($key in ($ConfigurationData.Keys | Sort-Object)) {
      $value = $ConfigurationData.$Key
      if ($value -is [hashtable]) {
        $mungedValue = New-Object -TypeName ordered
        foreach ($subKey in ($value.Keys | Sort-Object)) {
          $mungedValue.$SubKey = $value.$subKey
        }
        $value = $mungedValue
      }
      $data.$key = $value
    }

    $file = New-Item -Path $filePath -Force

    $data
    | ConvertTo-Json
    | Out-File -FilePath $file -Encoding utf8NoBOM -Force

    $file
  }

  end {

  }
}
