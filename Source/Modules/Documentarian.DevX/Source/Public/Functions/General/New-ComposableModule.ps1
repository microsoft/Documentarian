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
  [CmdletBinding()]
  param(
    [string]$Name,
    [string]$Path
  )

  begin {
    $Path ??= Get-Location

    $ModuleFolders = @(
      @{ Path = 'Source/Private/Classes'   ; LoadOrder = $true }
      @{ Path = 'Source/Private/Enums'     ; LoadOrder = $true }
      @{ Path = 'Source/Public/Classes'    ; LoadOrder = $true }
      @{ Path = 'Source/Public/Enums'      ; LoadOrder = $true }
      @{ Path = 'Source/Private/Functions' ; GitKeep = $true }
      @{ Path = 'Source/Public/Functions'  ; GitKeep = $true }
    )
  }

  process {
    $ModuleFolder = Join-Path -Path $Path -ChildPath $Name

    $ShortName = $Name -match '\.' ? ($Name -split '.')[-1] : $Name
    $TemplateParameters = @{
      TemplatePath    = 'Module'
      DestinationPath = $ModuleFolder
      TemplateData    = @{
        Name      = $Name
        ShortName = $ShortName
      }
    }
    Copy-Template @TemplateParameters

    Push-Location -Path $ModuleFolder

    foreach ($Folder in $ModuleFolders) {
      if ($Folder.LoadOrder) {
        New-LoadOrderJson -FolderPath $Folder.Path
      } elseif ($Folder.GitKeep) {
        if (!(Test-Path -Path $Folder.Path -PathType Container)) {
          New-Item -Path $Folder.Path -ItemType Directory
        }
        $GitKeepPath = Join-Path -Path $Folder.Path -ChildPath '.gitkeep'
        Out-File -FilePath $GitKeepPath -InputObject '' -Encoding utf8NoBOM -Force
      }
    }

    New-ConfigurationJson -FolderPath $ModuleFolder -Name $Name
  }

  End {
    Pop-Location
  }
}
