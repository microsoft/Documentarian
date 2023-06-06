# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function New-ConfigurationJson {
  [CmdletBinding()]
  param(
    [string] $FolderPath = (Get-Location),
    [string] $Name,
    [guid]   $Guid = (New-Guid),
    [string] $CopyrightNotice,
    [string] $LicenseNotice,
    [string] $ProjectUri,
    [string] $LicenseUri
  )

  begin {
    $ShortName = ($Name -match '\.(?<ShortName>[^\.]+)$') ? $Matches.ShortName : $Name
    Write-Verbose "Short name is: $ShortName"

    $FilePath = Join-Path -Path $FolderPath -ChildPath '.DevX.jsonc'
  }

  process {
    $ManifestData = @{
      RootModule        = "$Name.psm1"
      ModuleVersion     = '0.0.1'
      Guid              = "$Guid"
      ScriptsToProcess  = 'Init.ps1'
      VariablesToExport = '*'
    }

    if ($ProjectURI) {
      $ManifestData.ProjectUri = $ProjectUri
    }
    if ($LicenseUri) {
      $ManifestData.LicenseUri = $LicenseUri
    }

    $ConfigurationData = @{
      ManifestData         = $ManifestData
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

    $Data = New-Object -TypeName ordered

    foreach ($Key in ($ConfigurationData.Keys | Sort-Object)) {
      $Value = $ConfigurationData.$Key
      if ($Value -is [hashtable]) {
        $MungedValue = New-Object -TypeName ordered
        foreach ($SubKey in ($Value.Keys | Sort-Object)) {
          $MungedValue.$SubKey = $Value.$SubKey
        }
        $Value = $MungedValue
      }
      $Data.$Key = $Value
    }

    $File = New-Item -Path $FilePath -Force

    $Data
    | ConvertTo-Json
    | Out-File -FilePath $File -Encoding utf8NoBOM -Force

    $File
  }
}
