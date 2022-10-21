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
  [SourceCategory]$Category
  [SourceScope]$Scope
  [string]$NameSpace
  [System.IO.FileInfo]$FileInfo
  [string]$RawContent
  [string]$MungedContent

  hidden [string[]]$NonLocalUsingStatements
  hidden [bool]$CheckedForLocalUsingStatements

  static [string]$MungingPattern = @(
    # This segment is to do multiline regex and capture only named groups
    '(?m)(?n)'
    # This segment captures everything until the first definition
    '(?<Prefix>(.|\s)+?(?=^(function|class|enum)))?'
    # This segment grabs the definition(s)
    '(?<Definition>(.|\s)+)'
  ) -join ''

  SourceFile([string]$ParentNameSpace, [string]$Path) {
    $this.NameSpace = Resolve-NameSpace -Path $Path -ParentNameSpace $ParentNameSpace
    $this.ResolveCategoryAndScopeFromNameSpace()
    $this.FileInfo = $Path
    $this.SetRawContent()
    $this.MungeContent()
  }

  SourceFile(
    [string]$Path
  ) {
    $this.NameSpace = Resolve-NameSpace -Path $Path
    $this.ResolveCategoryAndScopeFromNameSpace()
    $this.FileInfo = $Path
    $this.SetRawContent()
    $this.MungeContent()
  }

  [void] SetRawContent() {
    $this.RawContent = Get-Content -Path $this.FileInfo.FullName -Raw
  }

  [string[]] GetNonLocalUsingStatements() {
    if (!$this.CheckedForLocalUsingStatements) {
      $this.NonLocalUsingStatements = $this.RawContent -split '(\r\n|\n|\r)'
      | Where-Object -FilterScript { $_ -match '^(using \w+ .+|#requires -\w+ .+)' }
      | Where-Object -FilterScript { $_ -notmatch '(\\|\/)' }

      $this.CheckedForLocalUsingStatements = $true
    }
    return $this.NonLocalUsingStatements
  }

  static [string] MungeContent([string]$Content) {
    $SplitContent = $Content -split '(\r\n|\n|\r)'
    if (
      ($SplitContent -match '^(using|#requires|#region)') -and
      ($Content -match [SourceFile]::MungingPattern)
    ) {
      return $Matches.Definition.Trim()
    } else {
      return $Content.Trim()
    }
  }

  [void] MungeContent() {
    $this.MungedContent = [SourceFile]::MungeContent($this.RawContent)
  }

  [void] ResolveCategoryAndScopeFromNameSpace() {
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
}
