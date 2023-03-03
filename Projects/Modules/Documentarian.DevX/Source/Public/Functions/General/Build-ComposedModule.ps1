# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/ModuleComposer.psm1

function Build-ComposedModule {
  [CmdletBinding(DefaultParameterSetName = 'WithConfigurationFile')]
  param(
    [string] $ProjectRootFolderPath,

    [Parameter(ParameterSetName = 'WithConfigurationFile')]
    [string] $ConfigurationFilePath,

    [Parameter(ParameterSetName = 'WithOptionValues')]
    [hashtable] $ManifestData,

    [Parameter(ParameterSetName = 'WithOptionValues')]
    [string] $ModuleCopyrightNotice,

    [Parameter(ParameterSetName = 'WithOptionValues')]
    [string] $ModuleLicenseNotice,

    [Parameter(ParameterSetName = 'WithOptionValues')]
    [string] $ModuleName,

    [Parameter(ParameterSetName = 'WithOptionValues')]
    [version] $ModuleVersion,

    [Parameter(ParameterSetName = 'WithOptionValues')]
    [string] $OutputFolderPath,

    [Parameter(ParameterSetName = 'WithOptionValues')]
    [string] $OutputInitScriptPath,

    [Parameter(ParameterSetName = 'WithOptionValues')]
    [string] $OutputManifestPath,

    [Parameter(ParameterSetName = 'WithOptionValues')]
    [string] $OutputPrivateModulePath,

    [Parameter(ParameterSetName = 'WithOptionValues')]
    [string] $OutputRootModulePath,

    [Parameter(ParameterSetName = 'WithOptionValues')]
    [string] $SourceFolderPath,

    [Parameter(ParameterSetName = 'WithOptionValues')]
    [string] $SourceInitScriptPath,

    [Parameter(ParameterSetName = 'WithOptionValues')]
    [string] $SourceManifestPath,

    [Parameter(ParameterSetName = 'WithOptionValues')]
    [string] $SourcePrivateFolderPath,

    [Parameter(ParameterSetName = 'WithOptionValues')]
    [string] $SourcePublicFolderPath
  )

  process {
    if ([string]::IsNullOrEmpty($ProjectRootFolderPath)) {
      [string]$ProjectRootFolderPath = Get-Location
    }
    Write-Verbose "Using project root folder path: $ProjectRootFolderPath"

    if ($PSCmdlet.ParameterSetName -eq 'WithConfigurationFile') {
      if ($ConfigurationFilePath) {
        Write-Verbose "Using specified configuration file path: $ConfigurationFilePath"
        $ConfigurationSettings = Get-Content -Raw -Path $ConfigurationFilePath
        | ConvertFrom-Json -AsHashtable -ErrorAction Stop
      } else {
        $ConfigurationFilePath = Join-Path -Path $ProjectRootFolderPath -ChildPath '.DevX.jsonc'
        Write-Verbose "Checking for default configuration file path: $ConfigurationFilePath"
        if (Test-Path -Path $ConfigurationFilePath) {
          $ConfigurationSettings = Get-Content -Raw -Path $ConfigurationFilePath
          | ConvertFrom-Json -AsHashtable -ErrorAction Stop
        }
      }
    } else {
      $ConfigurationSettings = @{}
      $OptionKeys = $PSBoundParameters.Keys
      | Where-Object -FilterScript { $_ -ne 'ProjectRootFolderPath' }

      foreach ($Key in $OptionKeys) {
        $ConfigurationSettings = $PSBoundParameters.$Key
      }
    }

    if ($ConfigurationSettings) {
      Write-Verbose "Composing with settings from $ConfigurationFilePath"
      [ModuleComposer]$Composer = [ModuleComposer]::New(
        $ProjectRootFolderPath,
        $ConfigurationSettings
      )
    } else {
      Write-Verbose 'Composing with default settings'
      [ModuleComposer]$Composer = [ModuleComposer]::New($ProjectRootFolderPath)
    }

    Write-Verbose "Compsing module $($Composer.ModuleName) with settings:"
    Write-Verbose "`tProjectRootFolderPath:   $($Composer.ProjectRootFolderPath)"
    Write-Verbose "`tManifestData:            $($Composer.ManifestData | ConvertTo-Json)"
    Write-Verbose "`tModuleCopyrightNotice:   $($Composer.ModuleCopyrightNotice)"
    Write-Verbose "`tModuleLicenseNotice:     $($Composer.ModuleLicenseNotice)"
    Write-Verbose "`tModuleName:              $($Composer.ModuleName)"
    Write-Verbose "`tModuleVersion:           $($Composer.ModuleVersion)"
    Write-Verbose "`tOutputFolderPath:        $($Composer.OutputFolderPath)"
    Write-Verbose "`tOutputInitScriptPath:    $($Composer.OutputInitScriptPath)"
    Write-Verbose "`tOutputManifestPath:      $($Composer.OutputManifestPath)"
    Write-Verbose "`tOutputPrivateModulePath: $($Composer.OutputPrivateModulePath)"
    Write-Verbose "`tOutputRootModulePath:    $($Composer.OutputRootModulePath)"
    Write-Verbose "`tSourceFolderPath:        $($Composer.SourceFolderPath)"
    Write-Verbose "`tSourceInitScriptPath:    $($Composer.SourceInitScriptPath)"
    Write-Verbose "`tSourceManifestPath:      $($Composer.SourceManifestPath)"
    Write-Verbose "`tSourcePrivateFolderPath: $($Composer.SourcePrivateFolderPath)"
    Write-Verbose "`tSourcePublicFolderPath:  $($Composer.SourcePublicFolderPath)"
    $Composer.ExportComposedModule()
  }
}
