# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/General/Get-ModuleRelativePath.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Copy-Template {
  <#
    .SYNOPSIS
  #>

  [CmdletBinding()]
  param(
    [Parameter()]
    [string]
    $TemplatePath,

    [Parameter()]
    [string]
    $DestinationPath,

    [Parameter()]
    [hashtable]
    $TemplateData,

    [Parameter()]
    [switch]
    $PassThru
  )

  begin {
    $templateFolderPath = Get-ModuleRelativePath -Path 'Templates'
  }

  process {
    $templatePath = Join-Path -Path $templateFolderPath -ChildPath $TemplatePath
    $template = Get-Item -Path $templatePath

    $copyParameters = @{
      Path        = $TemplatePath
      Destination = $DestinationPath
      PassThru    = $true
    }
    if ($template -is [System.IO.DirectoryInfo]) {
      $copyParameters.Container = $true
      $copyParameters.Recurse = $true
    }

    $copiedFiles = Copy-Item @copyParameters

    if ($TemplateData) {
      foreach ($file in $copiedFiles) {
        if ($content = Get-Content -Path $file -Raw -ErrorAction SilentlyContinue) {
          foreach ($key in $TemplateData.Keys) {
            [string]$value = $TemplateData.$key
            $content = $content -replace [regex]::Escape("[[$key]]"), $value
            $content = $content -replace [regex]::Escape("[[$key&lower]]"), $value.ToLowerInvariant()
            $content = $content -replace [regex]::Escape("[[$key&upper]]"), $value.ToUpperInvariant()
          }

          $content | Out-File -FilePath $file -Encoding utf8NoBOM -Force -NoNewline
        }
      }
    }

    if ($PassThru) {
      Get-Item -Path $copiedFiles
    }
  }

  end {

  }
}
