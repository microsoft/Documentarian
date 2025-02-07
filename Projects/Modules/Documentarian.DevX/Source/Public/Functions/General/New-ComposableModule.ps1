# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/General/Copy-Template.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/General/New-ConfigurationJson.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/General/New-LoadOrderJson.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function New-ComposableModule {
  <#
    .SYNOPSIS
  #>

  [CmdletBinding()]
  param(
    [Parameter()]
    [string]
    $Name,

    [Parameter()]
    [string]
    $Path
  )

  begin {
    $Path ??= Get-Location

    $moduleFolders = @(
      @{ Path = 'Source/Private/Classes'   ; LoadOrder = $true }
      @{ Path = 'Source/Private/Enums'     ; LoadOrder = $true }
      @{ Path = 'Source/Public/Classes'    ; LoadOrder = $true }
      @{ Path = 'Source/Public/Enums'      ; LoadOrder = $true }
      @{ Path = 'Source/Private/Functions' ; GitKeep = $true }
      @{ Path = 'Source/Public/Functions'  ; GitKeep = $true }
      @{ Path = 'Source/Public/Formats'    ; GitKeep = $true }
      @{ Path = 'Source/Public/Types'      ; GitKeep = $true }
    )
  }

  process {
    $moduleFolder = Join-Path -Path $Path -ChildPath $Name

    $shortName = $Name -match '\.' ? ($Name -split '.')[-1] : $Name
    $templateParameters = @{
      TemplatePath    = 'Module'
      DestinationPath = $moduleFolder
      TemplateData    = @{
        Name      = $Name
        ShortName = $shortName
      }
    }
    Copy-Template @templateParameters

    Push-Location -Path $moduleFolder

    foreach ($folder in $moduleFolders) {
      if ($folder.LoadOrder) {
        New-LoadOrderJson -FolderPath $folder.Path
      } elseif ($folder.GitKeep) {
        if (-not (Test-Path -Path $folder.Path -PathType Container)) {
          New-Item -Path $folder.Path -ItemType Directory
        }
        $gitKeepPath = Join-Path -Path $Folder.Path -ChildPath '.gitkeep'
        Out-File -FilePath $gitKeepPath -InputObject '' -Encoding utf8NoBOM -Force
      }
    }

    New-ConfigurationJson -FolderPath $moduleFolder -Name $Name
  }

  end {
    Pop-Location
  }
}
