# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
#requires -Version 7.2
#requires -Module InvokeBuild

[cmdletbinding()]
param(
  [string]$SiteBaseUrl
)

task SyncVale {
  $SourceStyleFolder = Get-Item -Path $PSScriptRoot/Source/Styles
  Get-ChildItem -Path $SourceStyleFolder -Directory | ForEach-Object -Process {
    $SubFolder = Join-Path -Path $_.FullName -ChildPath $_.BaseName
    $RulesFolder = Join-Path -Path $_.FullName -ChildPath Rules
    if (Test-Path -Path $SubFolder) {
      Remove-Item -Path $SubFolder -Recurse -Force
    }
    $null = New-Item -Path $SubFolder -ItemType Directory

    $null = Get-ChildItem $RulesFolder -File | Copy-Item -Destination $SubFolder -Force
  }

  if (Get-Command -Name vale -ErrorAction Ignore) {
    vale sync
  } elseif ($Vale = Get-Command "$PSScriptRoot/.vale/vale") {
    & $Vale sync
  } else {
    $Message = @(
      'Vale not installed;'
      "Install with a package manager or 'Install-WorkspaceVale' from Documentarian.Vale."
    ) -join ' '
    Write-Error -Message $Message
  }

  $SyncedStylesFolder = Get-Item -Path $PSScriptRoot/.vscode/styles
  Get-ChildItem -Path $SourceStyleFolder -Directory | ForEach-Object -Process {
    $SubFolder = Join-Path -Path $_.FullName -ChildPath $_.BaseName
    Remove-Item -Path $SubFolder -Recurse -Force

    $RulesFolder = Join-Path -Path $_.FullName -ChildPath 'Rules'
    $SyncedStyleFolder = Join-Path -Path $SyncedStylesFolder -ChildPath $_.BaseName

    if (Test-Path -Path $SyncedStyleFolder) {
      Remove-Item -Path $SyncedStyleFolder -Recurse -Force
    }
    $null = New-Item -Path $SyncedStyleFolder -ItemType Directory

    Get-ChildItem -Path $RulesFolder
    | Copy-Item -Destination $SyncedStyleFolder -Force -Recurse
  }
}

task PackageVale {
  $SourceStyleFolder = Get-Item -Path $BuildRoot/Source/Styles
  $PackagedStyleFolder = Join-Path $BuildRoot -ChildPath 'PackagedStyles'

  if (Test-Path -Path $PackagedStyleFolder) {
    Remove-Item -Path $PackagedStyleFolder -Recurse -Force
  }
  $null = New-Item -Path $PackagedStyleFolder -ItemType Directory

  Get-ChildItem -Path $SourceStyleFolder -Directory | ForEach-Object -Process {
    $CompressionParameters = @{
      Path            = $_.FullName
      DestinationPath = Join-Path -Path $PackagedStyleFolder -ChildPath "$($_.BaseName).zip"
      Force           = $true
    }
    Compress-Archive @CompressionParameters
  }
}

task PrepareSite PackageVale, {
  $PackagedStyleFolder = Join-Path -Path $BuildRoot -ChildPath 'PackagedStyles'
  $StyleAssetFolder = "$BuildRoot/Site/assets/vale"

  if (Test-Path -Path $StyleAssetFolder) {
    Get-ChildItem -Path $StyleAssetFolder | Remove-Item -Force -Recurse
  } else {
    New-Item -Path $StyleAssetFolder -ItemType Directory -Force
  }

  Copy-Item -Path "$PackagedStyleFolder/*.zip" -Destination $StyleAssetFolder
}

task BuildSite PrepareSite, {
  Push-Location -Path "$BuildRoot/Site"
  if ([string]::IsNullOrEmpty($SiteBaseUrl)) {
    $SiteBaseUrl = $env:DEPLOY_PRIME_URL
  }
  if ([string]::IsNullOrEmpty($SiteBaseUrl)) {
    $SiteBaseUrl = 'https://quiet-snickerdoodle-38a82c.netlify.app/'
  }
  hugo --gc --minify -b $SiteBaseUrl
  Pop-Location
}

task ServeSite PrepareSite, {
  Push-Location -Path "$BuildRoot/Site"
  hugo serve
  Pop-Location
}
