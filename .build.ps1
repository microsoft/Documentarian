# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
#requires -Version 7.2
#requires -Module InvokeBuild

[cmdletbinding()]
param(
  [string]$SiteBaseUrl
)

task SyncVale PackageVale, {
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
}

task PackageVale {
  $ValeProjectsFolder = Get-Item -Path "$BuildRoot/Projects/Styles"
  $PackagedStylesFolder = Join-Path $BuildRoot -ChildPath 'PackagedStyles'

  if (Test-Path -Path $PackagedStylesFolder) {
    Remove-Item -Path $PackagedStylesFolder -Recurse -Force
  }
  $null = New-Item -Path $PackagedStylesFolder -ItemType Directory

  Get-ChildItem -Path $ValeProjectsFolder -Directory | ForEach-Object -Process {
    # This process is complicated because vale's requirements for 'complete' packages with
    # a configuration file and defined styles is very specific. This block:
    #
    # 1. Renames the 'Source' folder to the same as the package, because the archive *must* include
    #    the package's name as the folder in the zip that contains the config/etc
    # 2. Creates the '<PackageName>/styles/<PackageName>' folder, which is where the actual rule
    #    definitions need to go
    # 3. Moves the rule definitions into that temporary subfolder
    # 4. Creates a new zip archive for the style package
    # 5. Cleans up by putting the rules back, deleting the temp folder, and renaming Source again.
    $SourceFolder = Join-Path -Path $_.FullName -ChildPath 'Source'
    $ModdedFolder = Rename-Item -Path $SourceFolder -NewName $_.BaseName -PassThru
    $RulesFolder = Join-Path -Path $ModdedFolder -ChildPath 'Rules'
    $StylesFolder = Join-Path -Path $ModdedFolder -ChildPath 'styles'
    $SubbedFolder = Join-Path -Path $StylesFolder -ChildPath $_.BaseName
    # Rename the folder and move the files to where they need to be
    $null = New-Item -Path $SubbedFolder -ItemType Directory -Force
    Get-ChildItem -Path $RulesFolder -File
    | Move-Item -Destination $SubbedFolder
    Remove-Item -Path $RulesFolder

    # Create the zip file - we need to use the .NET method instead of the cmdlet
    # because the cmdlet ignores hidden files, which `.vale.ini` is considered
    # on unix systems.
    $ZipFilePath = Join-Path -Path $PackagedStylesFolder -ChildPath "$($_.BaseName).zip"
    [System.IO.Compression.ZipFile]::CreateFromDirectory(
      $ModdedFolder,
      $ZipFilePath,
      [System.IO.Compression.CompressionLevel]::Optimal,
      $true
    )

    # Restore the folder to previous state
    $null = New-Item -Path $RulesFolder -ItemType Directory -Force
    Move-Item -Path "$SubbedFolder/*" -Destination $RulesFolder
    Remove-Item -Path $StylesFolder -Recurse -Force
    Rename-Item -Path $ModdedFolder -NewName 'Source'
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
