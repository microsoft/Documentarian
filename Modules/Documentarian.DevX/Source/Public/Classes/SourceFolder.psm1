# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Private/Enums/UncommonLineEndingAction.psm1
using module ../Enums/SourceCategory.psm1
using module ../Enums/SourceScope.psm1
using module ./SourceFile.psm1

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

class SourceFolder {
  [SourceCategory]$Category
  [SourceScope]$Scope
  [string]$NameSpace
  [System.IO.DirectoryInfo]$DirectoryInfo
  [SourceFile[]]$SourceFiles

  SourceFolder([string]$NameSpace, [string]$Path) {
    $this.NameSpace = $NameSpace
    $this.ResolveCategoryAndScopeFromNameSpace()
    $this.DirectoryInfo = $Path
    $this.FindSourceFiles()
  }

  SourceFolder([SourceCategory]$Category, [SourceScope]$Scope, [string]$Path) {
    $this.Category = $Category
    $this.Scope = $Scope
    $this.NameSpace = Resolve-NameSpace -Category $Category -Scope $Scope
    $this.DirectoryInfo = $Path
    $this.FindSourceFiles()
  }

  SourceFolder([string]$Path) {
    $this.DirectoryInfo = Resolve-Path -Path $Path -ErrorAction Stop | Select-Object -ExpandProperty Path
    $this.NameSpace = Resolve-NameSpace -Path $this.DirectoryInfo.FullName
    $this.ResolveCategoryAndScopeFromNameSpace()
    $this.FindSourceFiles()
  }

  [bool] HasOrderedFiles() {
    return $this.Category -eq [SourceCategory]::Enum -or $this.Category -eq [SourceCategory]::Class
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

  [void] FindSourceFiles() {
    $this.SourceFiles = switch ($this.HasOrderedFiles()) {
      $true {
        $LoadOrderJson = Join-Path -Path $this.DirectoryInfo.FullName -ChildPath '.LoadOrder.jsonc'

        $LoadOrder = Get-Content -Path $LoadOrderJson
        | Where-Object -FilterScript { $_ -notmatch '^\s*\/\/' }
        | ConvertFrom-Json

        foreach ($Item in $LoadOrder) {
          Join-Path -Path $this.DirectoryInfo.FullName -ChildPath "$($Item.Name).psm1"
          | Resolve-Path
          | ForEach-Object {
            [SourceFile]::new($this.NameSpace, $_.Path)
          }
        }
      }
      $false {
        Get-ChildItem -Path $this.DirectoryInfo.FullName -Include '*.ps1' -Exclude '*.Tests.ps1' -Recurse
        | ForEach-Object -Process {
          [SourceFile]::new($this.NameSpace, $_.FullName)
        }
      }
    }
  }

  [string] ComposeSourceFiles() {
    if ($this.SourceFiles.Count -eq 0) {
      return ''
    }

    $Output = New-Object -TypeName System.Text.StringBuilder

    $Output.AppendLine("#region    $($this.NameSpace)").AppendLine()
    $this.SourceFiles.MungedContent | ForEach-Object -Process {
      $Output.AppendLine($_).AppendLine()
    }
    $Output.AppendLine("#endregion $($this.NameSpace)").AppendLine()

    return $Output.ToString()
  }

  [string] ComposeSourceFiles([string]$LineEnding) {
    [SourceFolder]::CheckLineEnding($LineEnding)

    if ($this.SourceFiles.Count -eq 0) {
      return ''
    }

    $Output = New-Object -TypeName System.Text.StringBuilder
    $Output.AppendLine("#region    $($this.NameSpace)").AppendLine()
    $this.SourceFiles.MungedContent | ForEach-Object -Process {
      $Output.AppendLine($_).AppendLine()
    }
    $Output.AppendLine("#endregion $($this.NameSpace)").AppendLine()

    return $Output.ToString() -replace [regex]::Escape([System.Environment]::NewLine), $LineEnding
  }

  [string] ComposeSourceFiles(
    [string]$LineEnding,
    [UncommonLineEndingAction]$UncommonLineEndingAction
  ) {
    [SourceFolder]::CheckLineEnding($LineEnding, $UncommonLineEndingAction)

    if ($this.SourceFiles.Count -eq 0) {
      return ''
    }

    $Output = New-Object -TypeName System.Text.StringBuilder
    $Output.AppendLine("#region    $($this.NameSpace)").AppendLine()
    $this.SourceFiles.MungedContent | ForEach-Object -Process {
      $Output.AppendLine($_).AppendLine()
    }
    $Output.AppendLine("#endregion $($this.NameSpace)").AppendLine()

    return $Output.ToString() -replace [regex]::Escape([System.Environment]::NewLine), $LineEnding
  }

  static hidden [string[]] ValidLineEndings() {
    return @("`r`n", "`r", "`n")
  }

  static hidden [bool] IsValidLineEnding([string]$LineEnding) {
    return [SourceFolder]::ValidLineEndings() -contains $LineEnding
  }

  static hidden [string] InvalidLineEndingMessage([string]$LineEnding) {
    $ValidLineEndings = [SourceFolder]::ValidLineEndings()
    | ForEach-Object -Process { "'$([regex]::Escape($_))'" }

    $ValidLineEndings = @(
      Join-String -InputObject $ValidLineEndings[0..($ValidLineEndings.Count - 2)] -Separator ', '
      $ValidLineEndings[-1]
    ) -join ', or '

    $Message = @(
      "Line ending '$([regex]::Escape($LineEnding))' is not one of the expected line endings"
      "($ValidLineEndings)."
    ) -join ' '

    return $Message
  }

  static hidden [void] CheckLineEnding(
    [string]$LineEnding,
    [UncommonLineEndingAction]$UncommonLineEndingAction
  ) {
    if (![SourceFolder]::IsValidLineEnding($LineEnding)) {
      $Message = [SourceFolder]::InvalidLineEndingMessage($LineEnding)

      switch ($UncommonLineEndingAction) {
        SilentlyContinue {}
        WarnAndContinue {
          Write-Warning -Message $Message
        }
        ErrorAndStop {
          throw [System.ArgumentException]::new($Message)
        }
        default {
          throw 'This is not handled! If you see this message, the devs goofed.'
        }
      }
    }
  }

  static hidden [void] CheckLineEnding([string]$LineEnding) {
    if (![SourceFolder]::IsValidLineEnding($LineEnding)) {
      $Message = @(
        "$([SourceFolder]::InvalidLineEndingMessage($LineEnding));"
        'Use a common line ending, ComposeSourceFiles() without parameters,'
        'or ComposeSourceFiles($LineEnding, $UncommonLineEndingAction) instead.'
      ) -join ' '

      throw [System.ArgumentException]::new($Message)
    }
  }
}
