# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Enums/SourceCategory.psm1
using module ../Enums/SourceScope.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Private/Functions/Get-EnumRegex.ps1"
  Resolve-Path -Path "$SourceFolder/Private/Functions/Resolve-NameSpace.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

class SourceFile {
  <#
    .SYNOPSIS
    Defines a source file for module composition and development.
  #>

  #region Static properties

  <#
    .SYNOPSIS
  #>
  static
  [string]
  $CopyrightNoticePattern = '^# Copyright (.+)$'

  <#
    .SYNOPSIS
  #>
  static
  [string]
  $CopyrightNoticePatternXml = 'Copyright .+'

  <#
    .SYNOPSIS
  #>
  static
  [string]
  $LicenseNoticePattern = '^# Licensed under (.+)$'

  <#
    .SYNOPSIS
  #>
  static
  [string]
  $LicenseNoticePatternXml = 'Licensed under .+'

  <#
    .SYNOPSIS
  #>
  static
  [string]
  $MungingPrefixPattern = @(
    # This segment is to do multiline regex and capture only named groups
    '(?m)(?n)'
    # This segment captures everything until the first definition
    '(?<Prefix>(.|\s)+?(?=^(function|class|enum)))?'
    # This segment grabs the definitions
    '(?<Definition>(.|\s)+)'
  ) -join ''

  <#
    .SYNOPSIS
  #>
  static
  [string]
  $MungingNoticesPattern = @(
    # This segment is to do multiline regex and capture only named groups
    '(?m)(?n)'
    # Capture the notices so they can be stripped out.
    '(?<Notices>'
    '('
    '(' # We don't know the definite ordering for notices, so accept either
    [SourceFile]::CopyrightNoticePattern
    '|'
    [SourceFile]::LicenseNoticePattern
    ')\r?\n?'
    ')+' # Can have 1 or more notices
    ')?'   # Some projects might not have notices
    # This segment captures the rest of the file as the definition.
    '(?<Definition>(.|\s)+)'
  ) -join ''

  #endregion Static properties

  #region Static methods

  static [string] MungeContent(
    [string]
    $content
  ) {
    <#
      .SYNOPSIS
    #>

    $splitContent = $content -split '(\r\n|\n|\r)'
    if (
      ($splitContent -match '^(using|#requires|#region)') -and
      ($content -match [SourceFile]::MungingPrefixPattern)
    ) {
      return $Matches.Definition.Trim()
    } elseif ($content -match [SourceFile]::MungingNoticesPattern) {
      return $Matches.Definition.Trim()
    } else {
      return $content.Trim()
    }
  }

  static [string] GetLineEnding(
    [string]
    $content
  ) {
    <#
      .SYNOPSIS
    #>

    if ($content -match '\r\n') {
      return "`r`n"
    } else {
      return "`n"
    }
  }

  static [string[]] SplitContent(
    [string]
    $content
  ) {
    <#
      .SYNOPSIS
    #>

    return $content -split '(\r\n|\n|\r)'
  }

  static [string] FindCopyrightNotice(
    [string]
    $content
  ) {
    <#
      .SYNOPSIS
    #>

    return [SourceFile]::SplitContent($content) -match [SourceFile]::CopyrightNoticePattern
  }

  static [string] FindCopyrightNoticeXml(
    [string]
    $content
  ) {
    <#
      .SYNOPSIS
    #>

    return [SourceFile]::SplitContent($content) -match [SourceFile]::CopyrightNoticePatternXml
  }

  static [string] FindCopyrightNotice(
    [string]
    $content,

    [string]
    $pattern
  ) {
    <#
      .SYNOPSIS
    #>

    return [SourceFile]::SplitContent($content) -match $pattern
  }

  static [string] FindLicenseNotice(
    [string]
    $content
  ) {
    <#
      .SYNOPSIS
    #>

    return [SourceFile]::SplitContent($content) -match [SourceFile]::LicenseNoticePattern
  }

  static [string] FindLicenseNoticeXml(
    [string]
    $content
  ) {
    <#
      .SYNOPSIS
    #>

    return [SourceFile]::SplitContent($content) -match [SourceFile]::LicenseNoticePatternXml
  }

  static [string] FindLicenseNotice(
    [string]
    $content,

    [string]
    $pattern
  ) {
    <#
      .SYNOPSIS
    #>

    return [SourceFile]::SplitContent($content) -match $pattern
  }

  #endregion Static methods

  #region Instance properties

  <#
    .SYNOPSIS
    The category of the source file.
  #>
  [SourceCategory]
  $Category

  <#
    .SYNOPSIS
    The scope of the source file.
  #>
  [SourceScope]
  $Scope

  <#
    .SYNOPSIS
    The namespace of the source file.
  #>
  [string]
  $NameSpace

  <#
    .SYNOPSIS
    The file information for the source file.
  #>
  [System.IO.FileInfo]
  $FileInfo

  <#
    .SYNOPSIS
    The line ending for the source file.
  #>
  [string]
  $LineEnding

  <#
    .SYNOPSIS
    The list of copyright notices for the source file.
  #>
  [string[]]
  $CopyrightNotices

  <#
    .SYNOPSIS
    The list of license notices for the source file.
  #>
  [string[]]
  $LicenseNotices

  <#
    .SYNOPSIS
    The content of the source file as it exists on disk before any processing.
  #>
  [string]
  $RawContent

  <#
    .SYNOPSIS
    The content of the source file after processing.
  #>
  [string]
  $MungedContent

  <#
    .SYNOPSIS
  #>
  hidden
  [string[]]
  $NonLocalUsingStatements

  <#
    .SYNOPSIS
  #>
  hidden
  [bool]
  $CheckedForLocalUsingStatements

  #endregion Instance properties

  #region Instance methods

  [void] SetRawContent() {
    <#
      .SYNOPSIS
    #>

    $this.RawContent = Get-Content -Path $this.FileInfo.FullName -Raw
  }

  [string[]] GetNonLocalUsingStatements() {
    <#
      .SYNOPSIS
    #>

    if (!$this.CheckedForLocalUsingStatements) {
      $this.NonLocalUsingStatements = $this.RawContent -split '(\r\n|\n|\r)'
      | Where-Object -FilterScript { $_ -match '^(using \w+ .+|#requires -\w+ .+)' }
      | Where-Object -FilterScript { $_ -notmatch '(\\|\/)' }

      $this.CheckedForLocalUsingStatements = $true
    }
    return $this.NonLocalUsingStatements
  }

  [void] MungeContent() {
    <#
      .SYNOPSIS
    #>

    $this.MungedContent = [SourceFile]::MungeContent($this.RawContent)
  }

  [void] DefineLineEnding() {
    <#
      .SYNOPSIS
    #>

    $this.LineEnding = [SourceFile]::GetLineEnding($this.RawContent)
  }

  [void] DefineCopyrightNotice() {
    <#
      .SYNOPSIS
    #>

    if ($this.FileInfo.Extension -eq '.ps1xml') {
      $this.CopyrightNotices = [SourceFile]::FindCopyrightNoticeXml($this.RawContent)
    } else {
      $this.CopyrightNotices = [SourceFile]::FindCopyrightNotice($this.RawContent)
    }
  }

  [void] DefineCopyrightNotice(
    [string]
    $pattern = [SourceFile]::CopyrightNoticePattern
  ) {
    <#
      .SYNOPSIS
    #>

    $this.CopyrightNotices = [SourceFile]::FindCopyrightNotice($this.RawContent, $pattern)
  }

  [void] DefineLicenseNotice() {
    <#
      .SYNOPSIS
    #>

    if ($this.FileInfo.Extension -eq '.ps1xml') {
      $this.LicenseNotices = [SourceFile]::FindLicenseNoticeXml($this.RawContent)
    } else {
      $this.LicenseNotices = [SourceFile]::FindLicenseNotice($this.RawContent)
    }
  }

  [void] DefineLicenseNotice(
    [string]
    $pattern
  ) {
    <#
      .SYNOPSIS
    #>

    $this.LicenseNotices = [SourceFile]::FindLicenseNotice($this.RawContent, $pattern)
  }

  [void] ResolveCategoryAndScopeFromNameSpace() {
    <#
      .SYNOPSIS
    #>

    $this.NameSpace -split '\.'
    | Select-Object -First 2
    | ForEach-Object -Process {
      if ($_ -match (Get-EnumRegex -EnumType SourceScope)) {
        $this.Scope = $Matches.SourceScope
      } elseif ($_ -match (Get-EnumRegex -EnumType SourceCategory)) {
        $this.Category = $Matches.SourceCategory
      }
    }
  }

  #endregion Instance methods

  #region Constructors

  SourceFile(
    [string]
    $parentNameSpace,

    [string]
    $path
  ) {
    <#
      .SYNOPSIS
    #>

    $this.NameSpace = Resolve-NameSpace -Path $path -ParentNameSpace $parentNameSpace
    $this.ResolveCategoryAndScopeFromNameSpace()
    $this.FileInfo = $path
    $this.SetRawContent()
    $this.MungeContent()
    $this.DefineCopyrightNotice()
    $this.DefineLicenseNotice()
    $this.DefineLineEnding()
  }

  SourceFile(
    [string]
    $path
  ) {
    <#
      .SYNOPSIS
    #>

    $this.NameSpace = Resolve-NameSpace -Path $path
    $this.ResolveCategoryAndScopeFromNameSpace()
    $this.FileInfo = $path
    $this.SetRawContent()
    $this.MungeContent()
    $this.DefineCopyrightNotice()
    $this.DefineLicenseNotice()
    $this.DefineLineEnding()
  }

  #endregion Constructors
}
