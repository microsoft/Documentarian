# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Private/Enums/ClassLogLevels.psm1
using module ../Enums/SourceCategory.psm1
using module ../Enums/SourceScope.psm1
using module ./SourceFile.psm1
using module ./SourceFolder.psm1
using module ./TaskDefinition.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Private/Functions/Get-Ast.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/General/Get-SourceFolder.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

class ModuleComposer {
  #region Configurable Settings

  [string]    $ProjectRootFolderPath
  [hashtable] $ManifestData
  [string]    $ModuleCopyrightNotice
  [string]    $ModuleLicenseNotice
  [string]    $ModuleLineEnding
  [string]    $ModuleName
  [version]   $ModuleVersion
  [string]    $OutputFolderPath
  [string]    $OutputFormatsFilePath
  [string]    $OutputInitScriptPath
  [string]    $OutputManifestPath
  [string]    $OutputPrivateModulePath
  [string]    $OutputRootModulePath
  [string]    $OutputTaskFolderPath
  [string]    $OutputTemplateFolderPath
  [string]    $OutputTypesFilePath
  [string]    $OutputDocumentationFolderPath
  [string]    $DocumentationFolderPath
  [string]    $SourceFolderPath
  [string]    $SourceInitScriptPath
  [string]    $SourceFormatFolderPath
  [string]    $SourceManifestPath
  [string]    $SourcePrivateFolderPath
  [string]    $SourcePublicFolderPath
  [string]    $SourceTaskFolderPath
  [string]    $SourceTemplateFolderPath
  [string]    $SourceTypeFolderPath
  [string]    $TaskAliasPrefix
  [string[]]  $UsingModuleList

  #endregion Configurable Settings

  #region Module Source Properties

  [SourceFolder[]]$SourceFolders
  [SourceFolder[]]$PrivateSourceFolders
  [SourceFolder[]]$PublicSourceFolders
  [string[]]$PublicFunctions
  [TaskDefinition[]]$TaskList

  #endregion Module Source Properties

  #region Composed Module Content Properties

  [string]$InitScriptContent
  [string]$FormatContent
  [string]$PrivateModuleContent
  [string]$RootModuleContent
  [string]$TypeContent

  #endregion Composed Module Content Properties

  #region    Logging
  hidden [ClassLogLevels] $LogLevel = [ClassLogLevels]::None
  hidden [System.Management.Automation.ActionPreference] VerbosePreference() {
    if ($this.LogLevel -gt [ClassLogLevels]::None) {
      return [System.Management.Automation.ActionPreference]::Continue
    } else {
      return [System.Management.Automation.ActionPreference]::SilentlyContinue
    }
  }
  hidden [System.Management.Automation.ActionPreference] DebugPreference() {
    if ($this.LogLevel -eq [ClassLogLevels]::Detailed) {
      return [System.Management.Automation.ActionPreference]::Continue
    } else {
      return [System.Management.Automation.ActionPreference]::SilentlyContinue
    }
  }
  #endregion Logging

  [string] GetUsingPrivateModuleStatement() {
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()
    $statement = if ([string]::IsNullOrEmpty($this.OutputPrivateModulePath)) {
      ''
    } else {
      "using module .\$(Split-Path -Leaf -Path $this.OutputPrivateModulePath)"
    }

    return $statement
  }

  #region    Constructors
  ModuleComposer () {
    $this.Initialize()
  }

  hidden ModuleComposer([ClassLogLevels]$LogLevel) {
    $this.LogLevel = $LogLevel
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()
    Write-Verbose 'Constructing ModuleComposer...'
    $this.Initialize()
  }

  ModuleComposer ([string]$ProjectRootFolderPath) {
    $this.ProjectRootFolderPath = $ProjectRootFolderPath
    $this.Initialize()
  }

  hidden ModuleComposer ([string]$ProjectRootFolderPath, [ClassLogLevels]$LogLevel) {
    $this.LogLevel = $LogLevel
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()
    Write-Verbose 'Constructing ModuleComposer...'
    $this.ProjectRootFolderPath = $ProjectRootFolderPath
    Write-Debug "Set project root path to $ProjectRootFolderPath"
    $this.Initialize()
  }

  ModuleComposer(
    [string]$ProjectRootFolderPath,
    [hashtable]$ConfigurationSettings
  ) {
    $this.ProjectRootFolderPath = $ProjectRootFolderPath
    $this.ProcessConfigurationSettings($ConfigurationSettings)
    $this.Initialize()
  }

  hidden ModuleComposer(
    [string]$ProjectRootFolderPath,
    [hashtable]$ConfigurationSettings,
    [ClassLogLevels]$LogLevel
  ) {
    $this.LogLevel = $LogLevel
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()
    Write-Verbose 'Constructing ModuleComposer...'
    $this.ProjectRootFolderPath = $ProjectRootFolderPath
    Write-Debug "Set project root path to $ProjectRootFolderPath"
    $this.ProcessConfigurationSettings($ConfigurationSettings)
    $this.Initialize()
    Write-Verbose 'Constructed ModuleComposer.'
  }
  #endregion Constructors

  [void] ProcessConfigurationSettings([hashtable]$ConfigurationSettings) {
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()
    Write-Verbose 'Processing configuration settings...'

    foreach ($SettingKey in $ConfigurationSettings.Keys) {
      $Value = $ConfigurationSettings.$SettingKey

      # String values can reference other setting keys wrapped in double square braces.
      if ($Value -is [string]) {
        while ($Value -match '\[\[(?<KeyName>\S+)\]\]') {
          $ReplacementKey = $Matches.KeyName
          $ReplacementValue = $ConfigurationSettings
          foreach ($DotPathSegment in ($ReplacementKey -split '\.')) {
            $ReplacementValue = $ReplacementValue.$DotPathSegment
          }
          if ($ReplacementValue) {
            $Value = $Value -replace "\[\[$ReplacementKey\]\]", $ReplacementValue
          } else {
            $ErrorMessage = @(
              "Specified setting reference value [[$ReplacementKey]] for setting $SettingKey,"
              "but it didn't resolve to a non-null value. Is the $ReplacementKey setting"
              'defined in .devx.jsonc?'
            ) -join ' '
            throw $ErrorMessage
          }
        }
      }

      # Path values may be relative to the project root folder. Throw on incorrect source path
      # values but not missing output paths, as the output folder may not exist yet.
      if ($SettingKey -match 'Path$') {
        try {
          Push-Location -Path $this.ProjectRootFolderPath
          $Value = Resolve-Path -Path $Value -ErrorAction Stop
        } catch {
          if ($SettingKey -match '^Output') {
            $Value = $_.TargetObject
          } else {
            throw $_
          }
        } finally {
          Pop-Location
        }
      }

      # For UsingModuleList, authors can specify a list of module names or a boolean value. If
      # the value is `$true`, then the module uses types from all modules in the required modules
      # list. If the value is `$false`, then the module doesn't need types from any other modules.
      # If the value is a list of module names, then the module uses types from those modules.
      if ($SettingKey -eq 'UsingModuleList') {
        if ($true -eq $Value) {
          $RequiredModules = $ConfigurationSettings.ManifestData.RequiredModules
          $Value = $null -eq $RequiredModules ? @() : $RequiredModules
        } elseif ($false -eq $Value) {
          $Value = @()
        }
      }

      # $MungedHash.$SettingKey = $Value
      $this.$SettingKey = $Value
    }
    Write-Verbose 'Processed configuration settings.'
  }

  [void] Initialize() {
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()
    Write-Verbose 'Initializing...'
    if ([string]::IsNullOrEmpty($this.ProjectRootFolderPath)) {
      $this.ProjectRootFolderPath = Get-Location
      Write-Debug "Set project root path to $($this.ProjectRootFolderPath)"
    }

    if ([string]::IsNullOrEmpty($this.ModuleName)) {
      $this.ModuleName = Split-Path -Leaf -Path $this.ProjectRootFolderPath
      Write-Debug "Set module name to $($this.ModuleName)"
    }

    if ([string]::IsNullOrEmpty($this.DocumentationFolderPath)) {
      $this.DocumentationFolderPath = Join-Path -Path $this.ProjectRootFolderPath -ChildPath 'Documentation'
      Write-Debug "Set documentation folder path to $($this.DocumentationFolderPath)"
    }

    if ([string]::IsNullOrEmpty($this.SourceFolderPath)) {
      $this.SourceFolderPath = Join-Path -Path $this.ProjectRootFolderPath -ChildPath 'Source'
      Write-Debug "Set source folder path to $($this.SourceFolderPath)"
    }

    if ([string]::IsNullOrEmpty($this.SourcePrivateFolderPath)) {
      $this.SourcePrivateFolderPath = Join-Path -Path $this.SourceFolderPath -ChildPath 'Private'
      Write-Debug "Set source private folder path to $($this.SourcePrivateFolderPath)"
    }

    if ([string]::IsNullOrEmpty($this.SourcePublicFolderPath)) {
      $this.SourcePublicFolderPath = Join-Path -Path $this.SourceFolderPath -ChildPath 'Public'
      Write-Debug "Set source public folder path to $($this.SourcePublicFolderPath)"
    }

    if ([string]::IsNullOrEmpty($this.SourceInitScriptPath)) {
      $this.SourceInitScriptPath = Join-Path -Path $this.SourceFolderPath -ChildPath 'Init.ps1'
      Write-Debug "Set source init script path to $($this.SourceInitScriptPath)"
    }

    if ([string]::IsNullOrEmpty($this.SourceManifestPath)) {
      $this.SourceManifestPath = Join-Path -Path $this.SourceFolderPath -ChildPath 'Manifest.psd1'
      Write-Debug "Set source manifest path to $($this.SourceManifestPath)"
    }
    if (Test-Path -Path $this.SourceManifestPath) {
      Write-Debug 'Loading manifest data from source manifest file...'
      $ManifestFileData = Import-PowerShellDataFile -Path $this.SourceManifestPath
      if ($null -eq $this.ManifestData) {
        $this.ManifestData = $ManifestFileData
      } else {
        foreach ($Key in $ManifestFileData.Keys) {
          if ($Key -notin $this.ManifestData.Keys) {
            $this.ManifestData.$Key = $ManifestFileData.$Key
          } elseif ($ManifestFileData.$Key.GetType().BaseType.Name -eq 'Array') {
            $this.ManifestData.$Key = $ManifestFileData.$key + $this.ManifestData.$Key
            | Select-Object -Unique
          }
          # Should we consider Handling hashtables?
        }
      }
      Write-Debug 'Loaded manifest data from source manifest file.'
    } else {
      $this.ManifestData ??= @{}
    }

    if ([string]::IsNullOrEmpty($this.SourceTemplateFolderPath)) {
      $this.SourceTemplateFolderPath = Join-Path -Path $this.SourceFolderPath -ChildPath 'Templates'
      Write-Debug "Set source template folder path to $($this.SourceTemplateFolderPath)"
    }

    if ([string]::IsNullOrEmpty($this.ManifestData.ModuleVersion)) {
      $this.ManifestData.ModuleVersion = '0.0.1'
      Write-Debug "Set module version to $($this.ManifestData.ModuleVersion)"
    }

    if ([string]::IsNullOrEmpty($this.OutputFolderPath)) {
      $OutputfolderPathParams = @{
        Path      = $this.ProjectRootFolderPath
        ChildPath = $this.ManifestData.ModuleVersion
      }
      $this.OutputFolderPath = Join-Path @OutputfolderPathParams
      Write-Debug "Set output folder path to $($this.OutputFolderPath)"
    }

    if ([string]::IsNullOrEmpty($this.OutputRootModulePath)) {
      $OutputRootModulePathParams = @{
        Path      = $this.OutputFolderPath
        ChildPath = "$($this.ModuleName).psm1"
      }
      $this.OutputRootModulePath = Join-Path @OutputRootModulePathParams
      Write-Debug "Set output root module path to $($this.OutputRootModulePath)"
    }

    if ([string]::IsNullOrEmpty($this.OutputManifestPath)) {
      $OutputManifestPathParams = @{
        Path      = $this.OutputFolderPath
        ChildPath = "$($this.ModuleName).psd1"
      }
      $this.OutputManifestPath = Join-Path @OutputManifestPathParams
      Write-Debug "Set output manifest path to $($this.OutputManifestPath)"
    }


    if ([string]::IsNullOrEmpty($this.OutputInitScriptPath)) {
      $this.OutputInitScriptPath = Join-Path -Path $this.OutputFolderPath -ChildPath 'Init.ps1'
      Write-Debug "Set output init script path to $($this.OutputInitScriptPath)"
    }

    if ([string]::IsNullOrEmpty($this.OutputTaskFolderPath)) {
      $this.OutputTaskFolderPath = Join-Path -Path $this.OutputFolderPath -ChildPath 'Tasks'
      Write-Debug "Set output task folder path to $($this.OutputTaskFolderPath)"
    }

    if ([string]::IsNullOrEmpty($this.OutputTemplateFolderPath)) {
      $this.OutputTemplateFolderPath = Join-Path -Path $this.OutputFolderPath -ChildPath 'Templates'
      Write-Debug "Set output template folder path to $($this.OutputTemplateFolderPath)"
    }

    if ([string]::IsNullOrEmpty($this.OutputDocumentationFolderPath)) {
      $this.OutputDocumentationFolderPath = Join-Path -Path $this.OutputFolderPath -ChildPath 'en-US'
      Write-Debug "Set output documentation folder path to $($this.OutputDocumentationFolderPath)"
    }

    if ([string]::IsNullOrEmpty($this.OutputFormatsFilePath)) {
      $OutputFormatsFilePathParams = @{
        Path      = $this.OutputFolderPath
        ChildPath = "$($this.ModuleName).Format.ps1xml"
      }
      $this.OutputFormatsFilePath = Join-Path @OutputFormatsFilePathParams
      Write-Debug "Set output formats file path to $($this.OutputFormatsFilePath)"
    }

    if ([string]::IsNullOrEmpty($this.OutputTypesFilePath)) {
      $OutputTypesFilePathParams = @{
        Path      = $this.OutputFolderPath
        ChildPath = "$($this.ModuleName).Types.ps1xml"
      }
      $this.OutputTypesFilePath = Join-Path @OutputTypesFilePathParams
      Write-Debug "Set output types file path to $($this.OutputTypesFilePath)"
    }

    if ([string]::IsNullOrEmpty($this.TaskAliasPrefix)) {
      $this.TaskAliasPrefix = $this.ModuleName
      Write-Debug "Set task alias prefix to $($this.TaskAliasPrefix)"
    }

    $this.InitializeSourceFolders()
    $this.InitializePublicFunctions()

    if ($this.PrivateSourceFolders.Count -and [string]::IsNullOrEmpty($this.OutputPrivateModulePath)) {
      $this.OutputPrivateModulePath = $this.OutputRootModulePath -replace 'psm1$', 'Private.psm1'
    }

    $this.InitializeTaskList()

    $this.InitializeModuleLineEnding()
    Write-Verbose 'Initialized.'
  }

  [void] InitializeModuleLineEnding() {
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()
    if ([string]::IsNullOrEmpty($this.ModuleLineEnding)) {
      $LineEndings = $this.SourceFolders
      | Select-Object -ExpandProperty SourceFiles
      | Select-Object -ExpandProperty LineEnding -Unique

      if ($LineEndings.Count -eq 1) {
        $this.ModuleLineEnding = $LineEndings[0]
      } else {
        Write-Verbose 'Inconsistent line endings in module, using OS preference instead.'
        $this.ModuleLineEnding = [System.Environment]::NewLine
      }
      Write-Debug "Set module line ending to $($this.ModuleLineEnding)"
    }
  }

  [void] InitializeSourceFolders() {
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()
    Write-Verbose 'Initializing source folders...'
    $SourceFinderParameters = @{
      Preset        = 'All'
      PublicFolder  = $this.SourcePublicFolderPath
      PrivateFolder = $this.SourcePrivateFolderPath
    }
    Write-Debug "Finding source folders with: $($SourceFinderParameters | ConvertTo-Json)"
    $VerbosePreference = 'Continue'
    $this.SourceFolders = Get-SourceFolder @SourceFinderParameters
    Write-Debug 'Found source folders.'

    $this.PrivateSourceFolders = $this.SourceFolders
    | Where-Object -FilterScript {
      ($_.Category -ne 'Function') -and
      ($_.Scope -eq 'Private') -and
      ($_.SourceFiles.Count -gt 0)
    }

    $this.PublicSourceFolders = $this.SourceFolders
    | Where-Object -FilterScript {
      ($_.DirectoryInfo.FullName -notin $this.PrivateSourceFolders.DirectoryInfo.FullName) -and
      ($_.SourceFiles.Count -gt 0)
    }

    $this.SourceFolders
    | Where-Object -FilterScript { $_.SourceFiles.Count -gt 0 }
    | Where-Object -FilterScript { ($_.Category -eq 'Function') -and ($_.Scope -eq 'Private') }
    | ForEach-Object {
      $this.PrivateSourceFolders += $_
    }

    Write-Verbose 'Initialized source folders.'
  }

  [void] InitializePublicFunctions() {
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()
    if ($null -eq $this.SourceFolders) {
      $this.InitializeSourceFolders()
    }
    Write-Verbose 'Initializing public functions...'

    $this.PublicFunctions = $this.SourceFolders
    | Where-Object { $_.Scope -eq 'Public' -and $_.Category -eq 'Function' }
    | ForEach-Object { Split-Path -Path $_.SourceFiles.FileInfo.FullName -LeafBase }

    Write-Verbose 'Initialized public functions.'
  }

  [void] InitializeTaskList() {
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()
    Write-Verbose 'Initializing task list...'

    $TaskSourceFolder = $this.SourceFolders | Where-Object { $_.Category -eq 'Task' }
    if ($TaskSourceFolder.SourceFiles.Count -gt 0) {
      $TaskSourceFolderPath = $TaskSourceFolder.DirectoryInfo.FullName
      $TaskListPath = Join-Path -Path $TaskSourceFolderPath -ChildPath '.TaskList.jsonc'
      try {
        $TaskListSettings = Get-Content -Path $TaskListPath -Raw -ErrorAction Stop
        | ConvertFrom-Json -ErrorAction Stop
      } catch {
        throw "Unable to retrieve task list settings from '$TaskListPath' - does it exist? Is it valid?"
      }
      foreach ($TaskInfo in $TaskListSettings) {
        $this.TaskList += [TaskDefinition]@{
          Name        = $TaskInfo.Name
          SourceFiles = $TaskSourceFolder.SourceFiles | Where-Object -FilterScript {
            $_.FileInfo.BaseName -in $TaskInfo.Include
          }
        }
        Write-Debug "Added task '$($TaskInfo.Name)' to task list."
      }
    }

    Write-Verbose 'Initialized task list.'
  }

  [void] CleanOutputFolder() {
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()

    Write-Verbose 'Cleaning output folder...'

    if (Test-Path -Path $this.OutputFolderPath) {
      Write-Debug "Removing output folder at '$($this.OutputFolderPath)'..."
      Remove-Item -Path $this.OutputFolderPath -Recurse -Force
    }

    Write-Verbose 'Cleaned output folder.'
  }

  [void] CreateOutputFolder() {
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()
    $this.CleanOutputFolder()
    Write-Verbose 'Creating output folder...'
    New-Item -Path $this.OutputFolderPath -ItemType Directory -Force
    Write-Debug "Created output folder at '$($this.OutputFolderPath)'."
    Write-Verbose 'Created output folder.'
  }

  [void] ComposePrivateModuleContent() {
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()
    if (!([string]::IsNullOrEmpty($this.OutputPrivateModulePath))) {
      Write-Verbose 'Composing private module content...'
      $ContentBuilder = New-Object -TypeName System.Text.StringBuilder

      $this.PrivateSourceFolders.SourceFiles.GetNonLocalUsingStatements()
      | Select-Object -Unique
      | ForEach-Object -Process {
        $null = $ContentBuilder.Append($_)
        $null = $ContentBuilder.Append($this.ModuleLineEnding)
      }

      $this.PrivateSourceFolders
      | ForEach-Object {
        $null = $ContentBuilder.Append($_.ComposeSourceFiles().trim())
        $null = $ContentBuilder.Append($this.ModuleLineEnding)
        $null = $ContentBuilder.Append($this.ModuleLineEnding)
      }

      $this.PrivateModuleContent = $this.MungeComposedContent($ContentBuilder.ToString())
      Write-Verbose 'Composed private module content.'
    }
  }

  [void] ComposeRootModuleContent() {
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()
    Write-Verbose 'Composing root module content...'
    $ContentBuilder = New-Object -TypeName System.Text.StringBuilder

    # Add the using statement for the private module first if needed
    if (!([string]::IsNullOrEmpty($this.OutputPrivateModulePath))) {
      $null = $ContentBuilder.Append($this.GetUsingPrivateModuleStatement())
      $null = $ContentBuilder.Append($this.ModuleLineEnding)
    }

    # Add types from other modules if configured to do so.
    if ($this.UsingModuleList.Count -gt 0) {
      $this.UsingModuleList | ForEach-Object -Process {
        $null = $ContentBuilder.Append("using module $_")
        $null = $ContentBuilder.Append($this.ModuleLineEnding)
      }
    }

    # Add non-local using statements before source definitions
    $this.PublicSourceFolders.SourceFiles.GetNonLocalUsingStatements()
    | Select-Object -Unique
    | ForEach-Object -Process {
      $null = $ContentBuilder.Append($_)
      $null = $ContentBuilder.Append($this.ModuleLineEnding)
    }

    $null = $ContentBuilder.Append($this.ModuleLineEnding)

    # Add source definitions
    $this.PublicSourceFolders
    | Where-Object -FilterScript {
      $_.Category -notin @(
        [SourceCategory]::ArgumentCompleter
        [SourceCategory]::Format
        [SourceCategory]::Task
        [SourceCategory]::Type
      )
    }
    | ForEach-Object {
      $Source = $_.ComposeSourceFiles().trim()
      $null = $ContentBuilder.Append($Source)
      $null = $ContentBuilder.Append($this.ModuleLineEnding)
      $null = $ContentBuilder.Append($this.ModuleLineEnding)
    }

    # Handle Task List
    if ($this.TaskList.Count -gt 0) {
      foreach ($Task in $this.TaskList) {
        $TaskName = $Task.GetTaskName($this.TaskAliasPrefix)
        $TaskPath = $Task.GetTaskPath($this.TaskAliasPrefix)

        $ContentBuilder.Append("Set-Alias -Name $TaskName -Value $TaskPath")
        $ContentBuilder.Append($this.ModuleLineEnding)
      }
      $ContentBuilder.Append($this.ModuleLineEnding)
    }

    # Add type accelerators for the public enums and classes
    $ContentBuilder.Append(
      '# Define the types to export with type accelerators.'
    ).Append($this.ModuleLineEnding)
    $ContentBuilder.Append('$ExportableTypes =@(').Append($this.ModuleLineEnding)
    foreach ($PublicEnum in $this.GetPublicEnumSourceFiles()) {
      $EnumType = $this.GetDefinedTypeName($PublicEnum)
      $ContentBuilder.Append("    $EnumType").Append($this.ModuleLineEnding)
    }
    foreach ($PublicClass in $this.GetPublicClassSourceFiles()) {
      $ClassType = $this.GetDefinedTypeName($PublicClass)
      $ContentBuilder.Append("    $ClassType").Append($this.ModuleLineEnding)
    }
    $ContentBuilder.Append(')').Append($this.ModuleLineEnding)
    $ContentBuilder.Append($this.ModuleLineEnding)
    $ContentBuilder.Append(
      '# Get the internal TypeAccelerators class to use its static methods.'
    ).Append($this.ModuleLineEnding).Append(
      '$TypeAcceleratorsClass = [psobject].Assembly.GetType('
    ).Append($this.ModuleLineEnding).Append(
      "'System.Management.Automation.TypeAccelerators'"
    ).Append($this.ModuleLineEnding).Append(
      ')'
    ).Append($this.ModuleLineEnding).Append(
      '# Ensure none of the types would clobber an existing type accelerator.'
    ).Append($this.ModuleLineEnding).Append(
      '# If a type accelerator with the same name exists, throw an exception.'
    ).Append($this.ModuleLineEnding).Append(
      '$ExistingTypeAccelerators = $TypeAcceleratorsClass::Get'
    ).Append($this.ModuleLineEnding).Append(
      'foreach ($Type in $ExportableTypes) {'
    ).Append($this.ModuleLineEnding).Append(
      '    if ($Type -in $ExistingTypeAccelerators.Keys) {'
    ).Append($this.ModuleLineEnding).Append(
      '        $Message = @('
    ).Append($this.ModuleLineEnding).Append(
      "            `"Unable to register type accelerator '`$(`$Type.FullName)'`""
    ).Append($this.ModuleLineEnding).Append(
      "            'Accelerator already exists'"
    ).Append($this.ModuleLineEnding).Append(
      "        ) -join ' '"
    ).Append($this.ModuleLineEnding).Append($this.ModuleLineEnding).Append(
      '        throw [System.Management.Automation.ErrorRecord]::new('
    ).Append($this.ModuleLineEnding).Append(
      '            [System.InvalidOperationException]::new($Message),'
    ).Append($this.ModuleLineEnding).Append(
      "            'TypeAcceleratorAlreadyExists',"
    ).Append($this.ModuleLineEnding).Append(
      '            [System.Management.Automation.ErrorCategory]::InvalidOperation,'
    ).Append($this.ModuleLineEnding).Append(
      '            $Type.FullName'
    ).Append($this.ModuleLineEnding).Append(
      '        )'
    ).Append($this.ModuleLineEnding).Append(
      '    }'
    ).Append($this.ModuleLineEnding).Append(
      '}'
    ).Append($this.ModuleLineEnding).Append($this.ModuleLineEnding).Append(
      '# Add the type accelerators for every exportable type.'
    ).Append($this.ModuleLineEnding).Append(
      'foreach ($Type in $ExportableTypes) {'
    ).Append($this.ModuleLineEnding).Append(
      '    Write-Verbose "Registering type accelerator for [$Type]"'
    ).Append($this.ModuleLineEnding).Append(
      '    $TypeAcceleratorsClass::Add($Type.FullName, $Type)'
    ).Append($this.ModuleLineEnding).Append(
      '}'
    ).Append($this.ModuleLineEnding).Append(
      '# Remove type accelerators when the module is removed.'
    ).Append($this.ModuleLineEnding).Append(
      '$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {'
    ).Append($this.ModuleLineEnding).Append(
      '    foreach ($Type in $ExportableTypes) {'
    ).Append($this.ModuleLineEnding).Append(
      '        Write-Verbose "Unregistering type accelerator for [$Type]"'
    ).Append($this.ModuleLineEnding).Append(
      '        $null = $TypeAcceleratorsClass::Remove($Type.FullName)'
    ).Append($this.ModuleLineEnding).Append(
      '    }'
    ).Append($this.ModuleLineEnding).Append(
      '}.GetNewClosure()'
    ).Append($this.ModuleLineEnding).Append($this.ModuleLineEnding)

    # Register argument completers
    $ArgumentCompleters = $this.GetArgumentCompleterSourceFiles()
    if ($ArgumentCompleters.Count -gt 0) {
      $ContentBuilder.Append($this.ModuleLineEnding).Append(
        '# Define the set of argument completers to register.'
      ).Append($this.ModuleLineEnding).Append(
        '$ArgumentCompleters = @('
      ).Append($this.ModuleLineEnding)

      foreach ($ArgumentCompleter in $ArgumentCompleters) {
        $HashTableLines = $ArgumentCompleter.MungedContent -split '\r?\n'
        foreach ($Line in $HashTableLines) {
          $ContentBuilder.Append("    $Line").Append($this.ModuleLineEnding)
        }
      }
      $ContentBuilder.Append(')').Append($this.ModuleLineEnding).Append(
        '# Register the argument completers.'
      ).Append($this.ModuleLineEnding).Append(
        'foreach ($ArgumentCompleter in $ArgumentCompleters) {'
      ).Append($this.ModuleLineEnding).Append(
        '    Register-ArgumentCompleter @ArgumentCompleter'
      ).Append($this.ModuleLineEnding).Append(
        '}'
      ).Append($this.ModuleLineEnding).Append($this.ModuleLineEnding)
    }

    # Add the export statement
    $null = $ContentBuilder.Append('$ExportableFunctions = @(').Append($this.ModuleLineEnding)
    foreach ($PublicFunction in $this.PublicFunctions) {
      $null = $ContentBuilder.Append("  '$PublicFunction'").Append($this.ModuleLineEnding)
    }
    $null = $ContentBuilder.Append(')').Append($this.ModuleLineEnding)
    $null = $ContentBuilder.Append($this.ModuleLineEnding)
    $null = $ContentBuilder.Append('Export-ModuleMember -Alias * -Function $ExportableFunctions')
    $null = $ContentBuilder.Append($this.ModuleLineEnding)

    # Handle Task List
    if ($this.TaskList.Count -gt 0) {
      foreach ($Task in $this.TaskList) {
        $TaskName = $Task.GetTaskName($this.TaskAliasPrefix)
        $TaskPath = $Task.GetTaskPath($this.TaskAliasPrefix)

        $ContentBuilder.Append("Set-Alias -Name $TaskName -Value $TaskPath")
        $ContentBuilder.Append($this.ModuleLineEnding)
      }
      $ContentBuilder.Append($this.ModuleLineEnding)
    }

    $this.RootModuleContent = $this.MungeComposedContent($ContentBuilder.ToString())
    Write-Verbose 'Composed root module content.'
  }

  [SourceFolder[]] GetSourceFolder([SourceScope]$Scope) {
    return $this.SourceFolders | Where-Object -FilterScript {
      $_.Scope -eq $Scope
    }
  }

  [string] GetDefinedTypeName([SourceFile]$sourceFile) {
    # Replace with AST Lookup later
    $TypeName = $sourceFile.FileInfo.BaseName
    return "[$TypeName]"
  }

  [SourceFolder[]] GetSourceFolder([SourceCategory[]]$Category) {
    return $this.SourceFolders | Where-Object -FilterScript {
      $_.Category -in $Category
    }
  }

  [SourceFolder[]] GetSourceFolder([SourceScope]$Scope, [SourceCategory[]]$Category) {
    return $this.SourceFolders | Where-Object -FilterScript {
      ($_.Scope -eq $Scope) -and ($_.Category -in $Category)
    }
  }

  [SourceFile[]] GetPublicEnumSourceFiles() {
    return $this.GetSourceFolder(
      [SourceScope]::Public,
      [SourceCategory]::Enum
    ).SourceFiles
  }

  [SourceFile[]] GetPublicClassSourceFiles() {
    return $this.GetSourceFolder(
      [SourceScope]::Public,
      [SourceCategory]::Class
    ).SourceFiles
  }

  [SourceFile[]] GetArgumentCompleterSourceFiles() {
    return $this.GetSourceFolder(
      [SourceScope]::Public,
      [SourceCategory]::ArgumentCompleter
    ).SourceFiles
  }

  hidden [string] TrimNotices([string]$Content) {
    foreach ($Notice in @($this.ModuleCopyrightNotice, $this.ModuleLicenseNotice)) {
      if (![string]::IsNullOrEmpty($Notice)) {
        $NoticeRegex = [regex]::escape($Notice)
        $Content = $Content -replace "#\s*$NoticeRegex", ''
      }
    }
    return $Content.trim()
  }

  hidden [string] MungeComposedContent([string]$Content) {
    # Remove the module notices from the file. These global notices only need to
    # be listed once at the top of the file.
    $MungedContent = $this.TrimNotices($content)

    # Munge non-standard newlines in case they slipped through.
    $MungedContent = $MungedContent -replace '(\r\n|\r|\n)', $this.ModuleLineEnding

    # Insert the notices before the munged content.
    $MungedContent = @(
      "# $($this.ModuleCopyrightNotice)"
      "# $($this.ModuleLicenseNotice)"
      ''
      $MungedContent
    ) -join $this.ModuleLineEnding

    # Limit consecutive newlines to two.
    $MungeExtraNewlinesPattern = "($([regex]::escape($this.ModuleLineEnding))){2,}"
    $ReplacementLineBreak = $this.ModuleLineEnding * 2
    $MungedContent = $MungedContent -replace $MungeExtraNewlinesPattern, $ReplacementLineBreak

    # Trim any extra lines that slipped through and end with a final newline.
    $MungedContent = $MungedContent.Trim() + $this.ModuleLineEnding

    return $MungedContent
  }

  [void] ComposeInitScriptContent() {
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()
    Write-Verbose 'Composing init script content...'

    $ContentBuilder = New-Object -TypeName System.Text.StringBuilder

    $UsingStatements = @()
    if ($this.UsingModuleList.Count -gt 0) {
      $this.UsingModuleList | ForEach-Object {
        $UsingStatements += "using module $_"
      }
    }

    # Always add a using statement for this module.
    # $UsingStatements += "using module .\$(Split-Path -Leaf $this.OutputRootModulePath)"

    if (
      ![string]::IsNullOrEmpty($this.SourceInitScriptPath) -and
      (Test-Path -Path $this.SourceInitScriptPath)
    ) {
      $InitAst = Get-Ast -Path $this.SourceInitScriptPath
      $HasCode = (
        $InitAst.Ast.BeginBlock.Statements.Count -gt 0 -or
        $InitAst.Ast.ProcessBlock.Statements.Count -gt 0 -or
        $InitAst.Ast.EndBlock.Statements.Count -gt 0 -or
        $InitAst.Ast.CleanBlock.Statements.Count -gt 0 -or
        $InitAst.Ast.DynamicParamBlock -or
        $InitAst.Ast.ParamBlock
      )

      if (-not $HasCode) {
        Write-Debug 'Init script has no code, removing from ScriptsToProcess and skipping.'
        $ScriptsToProcess = $this.ManifestData.ScriptsToProcess
        if ($ScriptsToProcess -is [string]) {
          $ScriptsToProcess = @($ScriptsToProcess)
        }
        $ScriptsToProcess = $ScriptsToProcess | Where-Object -FilterScript {
          $_ -ne 'Init.ps1'
        }
        $this.ManifestData.ScriptsToProcess = $ScriptsToProcess

        return
      }

      $InitHelp = $InitAst.Ast.GetHelpContent()?.GetCommentBlock()
      $InitHelp = $InitHelp -replace [System.Environment]::NewLine, $this.ModuleLineEnding
      $null = $ContentBuilder.Append($InitHelp).Append($this.ModuleLineEnding)

      $UsingStatements | ForEach-Object -Process {
        $null = $ContentBuilder.Append($_)
        $null = $ContentBuilder.Append($this.ModuleLineEnding)
      }
      $null = $ContentBuilder.Append(($this.ModuleLineEnding))

      # Get the script content, trim the notices and comment based help.
      $Content = Get-Content -Path $this.SourceInitScriptPath -Raw
      $Content = $this.TrimNotices($Content)
      $Content = $Content -replace '<#(\s|\S)+?#>', ''
      $null = $ContentBuilder.Append($Content.Trim()).Append($this.ModuleLineEnding)
    } else {
      $UsingStatements | ForEach-Object -Process {
        $null = $ContentBuilder.Append($_)
        $null = $ContentBuilder.Append($this.ModuleLineEnding)
      }
      $null = $ContentBuilder.Append(($this.ModuleLineEnding))
    }

    $this.InitScriptContent = $this.MungeComposedContent($ContentBuilder.ToString())
    Write-Verbose 'Composed init script content.'
  }

  [void] ComposeTypeFileContent() {
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()
    if (!([string]::IsNullOrEmpty($this.OutputTypesFilePath))) {
      Write-Debug 'Checking if type files need composing...'
      [string[]]$Types = $this.PublicSourceFolders.SourceFiles
      | Where-Object { $_.Category -eq 'Type' }
      | ForEach-Object {
        $TypeXML = ([xml]$_.RawContent).Types.Type.OuterXML
        if ($null -ne $TypeXML) {
          [System.Xml.Linq.XElement]::Parse($TypeXML).ToString() -split '\r?\n'
          | ForEach-Object -Process { "    $_" }
          | Join-String -Separator $this.ModuleLineEnding
        }
      }

      if ($Types.Count -gt 0) {
        Write-Verbose 'Composing type file content...'
        $this.TypeContent = @(
          '<?xml version="1.0" encoding="utf-8"?>'
          '<!--'
          '    Copyright (c) Microsoft Corporation.'
          '    Licensed under the MIT License.'
          '-->'
          '<Types>'
          $Types
          '</Types>'
        ) -join $this.ModuleLineEnding
        Write-Verbose 'Composed type file content.'
      } else {
        Write-Debug 'No type files found.'
      }
    }
  }

  [void] ComposeFormatFileContent() {
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()

    if (!([string]::IsNullOrEmpty($this.OutputFormatsFilePath))) {
      Write-Debug 'Checking if format files need composing...'
      [string[]]$Views = $this.PublicSourceFolders.SourceFiles
      | Where-Object { $_.Category -eq 'Format' }
      | ForEach-Object {
        $ViewXml = ([xml]$_.RawContent).Configuration.ViewDefinitions.View.OuterXML
        foreach ($View in $ViewXml) {
          [System.Xml.Linq.XElement]::Parse($View).ToString() -split '\r?\n'
          | ForEach-Object -Process { "        $_" }
          | Join-String -Separator $this.ModuleLineEnding
        }
      }

      if ($Views.Count -gt 0) {
        Write-Verbose 'Composing format file content...'
        $this.FormatContent = @(
          '<?xml version="1.0" encoding="utf-8"?>'
          '<!--'
          "    $($this.ModuleCopyrightNotice)"
          "    $($this.ModuleLicenseNotice)"
          '-->'
          '<Configuration>'
          '    <ViewDefinitions>'
          $Views
          '    </ViewDefinitions>'
          '</Configuration>'
        ) -join $this.ModuleLineEnding
        Write-Verbose 'Composed format file content.'
      } else {
        Write-Debug 'No format files found.'
      }
    }
  }

  [void] ComposeDocumentation() {
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()
    Write-Verbose 'Composing documentation...'
    $ReferenceFolderJoinParams = @{
      Path                = $this.DocumentationFolderPath
      ChildPath           = 'reference'
      AdditionalChildPath = 'cmdlets'
    }
    $ReferenceFolder = Join-Path @ReferenceFolderJoinParams
    $TempIndexName = "$($this.ModuleName).md"

    $Index = Rename-Item -Path "$ReferenceFolder/_index.md" -NewName $TempIndexName -PassThru

    New-ExternalHelp -Path $ReferenceFolder -OutputPath $this.OutputDocumentationFolderPath -Force

    Rename-Item $Index -NewName '_index.md'
    Write-Verbose 'Composed documentation.'
  }

  [void] ExportComposedModule() {
    $VerbosePreference = $this.VerbosePreference()
    $DebugPreference = $this.DebugPreference()

    $this.CreateOutputFolder()
    $this.ComposePrivateModuleContent()
    $this.ComposeRootModuleContent()
    $this.ComposeInitScriptContent()
    $this.ComposeFormatFileContent()
    $this.ComposeTypeFileContent()
    $this.ComposeDocumentation()

    Write-Verbose 'Exporting composed module...'
    $ManifestParameters = $this.ManifestData

    if ($TemplateFolder = Get-Item -Path $this.SourceTemplateFolderPath -ErrorAction SilentlyContinue) {
      Copy-Item -Path $TemplateFolder -Destination $this.OutputFolderPath -Container -Recurse
    }

    if ($this.PrivateModuleContent) {
      $this.PrivateModuleContent
      | Out-File -FilePath $this.OutputPrivateModulePath -Encoding utf8 -NoNewline
    }

    $this.RootModuleContent
    | Out-File -FilePath $this.OutputRootModulePath -Encoding utf8 -NoNewline

    if (![string]::IsNullOrEmpty($this.InitScriptContent)) {
      $this.InitScriptContent
      | Out-File -FilePath $this.OutputInitScriptPath -Encoding utf8 -NoNewline
    }

    if ($this.TypeContent) {
      $this.TypeContent
      | Out-File -FilePath $this.OutputTypesFilePath -Encoding utf8 -NoNewline

      $ManifestParameters.TypesToProcess = Split-Path -Leaf $this.OutputTypesFilePath
    }

    if ($this.FormatContent) {
      $this.FormatContent
      | Out-File -FilePath $this.OutputFormatsFilePath -Encoding utf8 -NoNewline

      $ManifestParameters.FormatsToProcess = Split-Path -Leaf $this.OutputFormatsFilePath
    }

    if ($this.TaskList.Count -gt 0) {
      if (-not(Test-Path -Path $this.OutputTaskFolderPath)) {
        New-Item -Path $this.OutputTaskFolderPath -ItemType Directory -Force
      }

      foreach ($Task in $this.TaskList) {
        $TaskPath = $Task.GetTaskPath($this.TaskAliasPrefix) -replace '\$PSScriptRoot', $this.OutputFolderPath
        Write-Debug "Created task '$($Task.Name) at '$TaskPath'"
        $this.MungeComposedContent($Task.ComposeContent())
        | Out-File -FilePath $TaskPath -Encoding utf8 -NoNewline
      }
    }

    $ManifestParameters.Path = $this.OutputManifestPath
    $ManifestParameters.FunctionsToExport = $this.PublicFunctions
    New-ModuleManifest @ManifestParameters
    Write-Verbose 'Exported composed module.'
  }
}
