# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ./SourceFolder.psm1
using module ../Enums/SourceCategory.psm1
using module ./TaskDefinition.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/Ast/Get-Ast.ps1"
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

  [string] GetUsingPrivateModuleStatement() {
    $statement = if ([string]::IsNullOrEmpty($this.OutputPrivateModulePath)) {
      ''
    } else {
      "using module ./$(Split-Path -Leaf -Path $this.OutputPrivateModulePath)"
    }

    return $statement
  }

  #region    Constructors
  ModuleComposer () {
    $this.Initialize()
  }

  ModuleComposer ([string]$ProjectRootFolderPath) {
    $this.ProjectRootFolderPath = $ProjectRootFolderPath
    $this.Initialize()
  }

  ModuleComposer(
    [string]$ProjectRootFolderPath,
    [hashtable]$ConfigurationSettings
  ) {
    $this.ProjectRootFolderPath = $ProjectRootFolderPath

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

      # Path values may be relative to the project root folder. Terminate on incorrect source path
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

      # $MungedHash.$SettingKey = $Value
      $this.$SettingKey = $Value
    }

    $this.Initialize()
  }
  #endregion Constructors

  [void] Initialize() {
    if ([string]::IsNullOrEmpty($this.ProjectRootFolderPath)) {
      $this.ProjectRootFolderPath = Get-Location
    }

    if ([string]::IsNullOrEmpty($this.ModuleName)) {
      $this.ModuleName = Split-Path -Leaf -Path $this.ProjectRootFolderPath
    }

    if ([string]::IsNullOrEmpty($this.SourceFolderPath)) {
      $this.SourceFolderPath = Join-Path -Path $this.ProjectRootFolderPath -ChildPath 'Source'
    }

    if ([string]::IsNullOrEmpty($this.SourcePrivateFolderPath)) {
      $this.SourcePrivateFolderPath = Join-Path -Path $this.SourceFolderPath -ChildPath 'Private'
    }

    if ([string]::IsNullOrEmpty($this.SourcePublicFolderPath)) {
      $this.SourcePublicFolderPath = Join-Path -Path $this.SourceFolderPath -ChildPath 'Public'
    }

    if ([string]::IsNullOrEmpty($this.SourceInitScriptPath)) {
      $this.SourceInitScriptPath = Join-Path -Path $this.SourceFolderPath -ChildPath 'Init.ps1'
    }

    if ([string]::IsNullOrEmpty($this.SourceManifestPath)) {
      $this.SourceManifestPath = Join-Path -Path $this.SourceFolderPath -ChildPath 'Manifest.psd1'
    }
    if (Test-Path -Path $this.SourceManifestPath) {
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
          # TODO: Handle hashtables?
        }
      }
    } else {
      $this.ManifestData ??= @{}
    }

    if ([string]::IsNullOrEmpty($this.SourceTemplateFolderPath)) {
      $this.SourceTemplateFolderPath = Join-Path -Path $this.SourceFolderPath -ChildPath 'Templates'
    }

    if ([string]::IsNullOrEmpty($this.ManifestData.ModuleVersion)) {
      $this.ManifestData.ModuleVersion = '0.0.1'
    }

    if ([string]::IsNullOrEmpty($this.OutputFolderPath)) {
      $OutputfolderPathParams = @{
        Path      = $this.ProjectRootFolderPath
        ChildPath = $this.ManifestData.ModuleVersion
      }
      $this.OutputFolderPath = Join-Path @OutputfolderPathParams
    }

    if ([string]::IsNullOrEmpty($this.OutputRootModulePath)) {
      $OutputRootModulePathParams = @{
        Path      = $this.OutputFolderPath
        ChildPath = "$($this.ModuleName).psm1"
      }
      $this.OutputRootModulePath = Join-Path @OutputRootModulePathParams
    }

    if ([string]::IsNullOrEmpty($this.OutputManifestPath)) {
      $OutputManifestPathParams = @{
        Path      = $this.OutputFolderPath
        ChildPath = "$($this.ModuleName).psd1"
      }
      $this.OutputManifestPath = Join-Path @OutputManifestPathParams
    }


    if ([string]::IsNullOrEmpty($this.OutputInitScriptPath)) {
      $this.OutputInitScriptPath = Join-Path -Path $this.OutputFolderPath -ChildPath 'Init.ps1'
    }

    if ([string]::IsNullOrEmpty($this.OutputTaskFolderPath)) {
      $this.OutputTaskFolderPath = Join-Path -Path $this.OutputFolderPath -ChildPath 'Tasks'
    }

    if ([string]::IsNullOrEmpty($this.OutputTemplateFolderPath)) {
      $this.OutputTemplateFolderPath = Join-Path -Path $this.OutputFolderPath -ChildPath 'Templates'
    }

    if ([string]::IsNullOrEmpty($this.OutputFormatsFilePath)) {
      $OutputFormatsFilePathParams = @{
        Path      = $this.OutputFolderPath
        ChildPath = "$($this.ModuleName).Format.ps1xml"
      }
      $this.OutputFormatsFilePath = Join-Path @OutputFormatsFilePathParams
    }

    if ([string]::IsNullOrEmpty($this.OutputTypesFilePath)) {
      $OutputTypesFilePathParams = @{
        Path      = $this.OutputFolderPath
        ChildPath = "$($this.ModuleName).Types.ps1xml"
      }
      $this.OutputTypesFilePath = Join-Path @OutputTypesFilePathParams
    }

    if ([string]::IsNullOrEmpty($this.TaskAliasPrefix)) {
      $this.TaskAliasPrefix = $this.ModuleName
    }

    $this.InitializeSourceFolders()
    $this.InitializePublicFunctions()

    if ($this.PrivateSourceFolders.Count -and [string]::IsNullOrEmpty($this.OutputPrivateModulePath)) {
      $this.OutputPrivateModulePath = $this.OutputRootModulePath -replace 'psm1$', 'Private.psm1'
    }

    $this.InitializeTaskList()

    $this.InitializeModuleLineEnding()
  }

  [void] InitializeModuleLineEnding() {
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
    }
  }

  [void] InitializeSourceFolders() {
    $SourceFinderParameters = @{
      Preset        = 'All'
      PublicFolder  = $this.SourcePublicFolderPath
      PrivateFolder = $this.SourcePrivateFolderPath
    }
    $this.SourceFolders = Get-SourceFolder @SourceFinderParameters

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
  }

  [void] InitializePublicFunctions() {
    if ($null -eq $this.SourceFolders) {
      $this.InitializeSourceFolders()
    }

    $this.PublicFunctions = $this.SourceFolders
    | Where-Object { $_.Scope -eq 'Public' -and $_.Category -eq 'Function' }
    | ForEach-Object { Split-Path -Path $_.SourceFiles.FileInfo.FullName -LeafBase }
  }

  [void] InitializeTaskList() {
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
      }
    }
  }

  [void] CleanOutputFolder() {
    if (Test-Path -Path $this.OutputFolderPath) {
      Remove-Item -Path $this.OutputFolderPath -Recurse -Force
    }
  }

  [void] CreateOutputFolder() {
    $this.CleanOutputFolder()
    New-Item -Path $this.OutputFolderPath -ItemType Directory -Force
  }

  [void] ComposePrivateModuleContent() {
    if (!([string]::IsNullOrEmpty($this.OutputPrivateModulePath))) {
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
    }
  }

  [void] ComposeRootModuleContent() {
    $ContentBuilder = New-Object -TypeName System.Text.StringBuilder

    # Add the using statement for the private module first if needed
    if (!([string]::IsNullOrEmpty($this.OutputPrivateModulePath))) {
      $null = $ContentBuilder.Append($this.GetUsingPrivateModuleStatement())
      $null = $ContentBuilder.Append($this.ModuleLineEnding)
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

    # Add the export statement
    $null = $ContentBuilder.Append('$ExportableFunctions = @(').Append($this.ModuleLineEnding)
    foreach ($PublicFunction in $this.PublicFunctions) {
      $null = $ContentBuilder.Append("  '$PublicFunction'").Append($this.ModuleLineEnding)
    }
    $null = $ContentBuilder.Append(')').Append($this.ModuleLineEnding)
    $null = $ContentBuilder.Append($this.ModuleLineEnding)
    $null = $ContentBuilder.Append('Export-ModuleMember -Alias * -Function $ExportableFunctions')
    $null = $ContentBuilder.Append($this.ModuleLineEnding)

    $this.RootModuleContent = $this.MungeComposedContent($ContentBuilder.ToString())
  }

  hidden [string] TrimNotices([string]$Content) {
    foreach ($Notice in @($this.ModuleCopyrightNotice, $this.ModuleLicenseNotice)) {
      if (![string]::IsNullOrEmpty($Notice)) {
        $Content = $Content -replace "#\s*$([regex]::escape($Notice))", ''
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
    $ContentBuilder = New-Object -TypeName System.Text.StringBuilder
    $UsingStatement = "using module ./$(Split-Path -Leaf $this.OutputRootModulePath)"

    if (
      ![string]::IsNullOrEmpty($this.SourceInitScriptPath) -and
      (Test-Path -Path $this.SourceInitScriptPath)
    ) {
      $InitAst = Get-Ast -Path $this.SourceInitScriptPath

      $InitHelp = $InitAst.Ast.GetHelpContent()?.GetCommentBlock()
      $InitHelp = $InitHelp -replace [System.Environment]::NewLine, $this.ModuleLineEnding
      $null = $ContentBuilder.Append($InitHelp).Append($this.ModuleLineEnding)

      $null = $ContentBuilder.Append($UsingStatement)
      $null = $ContentBuilder.Append(($this.ModuleLineEnding * 2))

      # Get the script content, trim the notices and comment based help.
      $Content = Get-Content -Path $this.SourceInitScriptPath -Raw
      $Content = $this.TrimNotices($Content)
      $Content = $Content -replace '<#(\s|\S)+?#>', ''
      $null = $ContentBuilder.Append($Content.Trim()).Append($this.ModuleLineEnding)
    } else {
      $null = $ContentBuilder.Append($UsingStatement)
      $null = $ContentBuilder.Append(($this.ModuleLineEnding * 2))
    }

    $this.InitScriptContent = $this.MungeComposedContent($ContentBuilder.ToString())
  }

  [void] ComposeTypeFileContent() {
    if (!([string]::IsNullOrEmpty($this.OutputTypesFilePath))) {
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
      }
    }
  }

  [void] ComposeFormatFileContent() {
    if (!([string]::IsNullOrEmpty($this.OutputFormatsFilePath))) {
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
      }
    }
  }

  [void] ExportComposedModule() {
    $this.CleanOutputFolder()
    $this.CreateOutputFolder()
    $this.ComposePrivateModuleContent()
    $this.ComposeRootModuleContent()
    $this.ComposeInitScriptContent()
    $this.ComposeFormatFileContent()
    $this.ComposeTypeFileContent()

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

    $this.InitScriptContent
    | Out-File -FilePath $this.OutputInitScriptPath -Encoding utf8 -NoNewline

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
        Write-Warning "Task Path: $TaskPath"
        $this.MungeComposedContent($Task.ComposeContent())
        | Out-File -FilePath $TaskPath -Encoding utf8 -NoNewline
      }
    }

    $ManifestParameters.Path = $this.OutputManifestPath
    $ManifestParameters.FunctionsToExport = $this.PublicFunctions
    New-ModuleManifest @ManifestParameters
  }
}
