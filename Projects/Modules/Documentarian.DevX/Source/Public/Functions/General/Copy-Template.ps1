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

# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Copy-Template {
  [CmdletBinding()]
  param(
    [string]    $TemplatePath,
    [string]    $DestinationPath,
    [hashtable] $TemplateData,
    [switch]    $PassThru
  )

  begin {
    $TemplateFolderPath = Get-ModuleRelativePath -Path 'Templates'
  }

  process {
    $TemplatePath = Join-Path -Path $TemplateFolderPath -ChildPath $TemplatePath
    $Template = Get-Item -Path $TemplatePath

    $CopyParameters = @{
      Path        = $TemplatePath
      Destination = $DestinationPath
      PassThru    = $true
    }
    if ($Template -is [System.IO.DirectoryInfo]) {
      $CopyParameters.Container = $true
      $CopyParameters.Recurse = $true
    }

    $CopiedFiles = Copy-Item @CopyParameters

    if ($TemplateData) {
      foreach ($File in $CopiedFiles) {
        if ($Content = Get-Content -Path $File -Raw -ErrorAction SilentlyContinue) {
          foreach ($Key in $TemplateData.Keys) {
            [string]$Value = $TemplateData.$Key
            $Content = $Content -replace [regex]::Escape("[[$Key]]"), $Value
            $Content = $Content -replace [regex]::Escape("[[$Key&lower]]"), $Value.ToLowerInvariant()
            $Content = $Content -replace [regex]::Escape("[[$Key&upper]]"), $Value.ToUpperInvariant()
          }
          $Content | Out-File -FilePath $File -Encoding utf8NoBOM -Force -NoNewline
        }
      }
    }

    if ($PassThru) {
      Get-Item -Path $CopiedFiles
    }
  }
}
