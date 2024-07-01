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
  <#
    .SYNOPSIS
    Defines a source folder for module composition and development.
  #>

  #region Static properties
  #endregion Static properties

  #region Static methods

  static hidden [string[]] ValidLineEndings() {
    <#
      .SYNOPSIS
    #>

    return @("`r`n", "`r", "`n")
  }

  static hidden [bool] IsValidLineEnding(
    [string]
    $lineEnding
  ) {
    <#
      .SYNOPSIS
    #>

    return [SourceFolder]::ValidLineEndings() -contains $lineEnding
  }

  static hidden [string] InvalidLineEndingMessage(
    [string]
    $lineEnding
  ) {
    <#
      .SYNOPSIS
    #>

    $validLineEndings = [SourceFolder]::ValidLineEndings()
    | ForEach-Object -Process { "'$([regex]::Escape($_))'" }

    $validLineEndings = @(
      Join-String -InputObject $validLineEndings[0..($validLineEndings.Count - 2)] -Separator ', '
      $validLineEndings[-1]
    ) -join ', or '

    $message = @(
      "Line ending '$([regex]::Escape($lineEnding))' is not one of the expected line endings"
      "($validLineEndings)."
    ) -join ' '

    return $message
  }

  static hidden [void] CheckLineEnding(
    [string]
    $lineEnding,

    [UncommonLineEndingAction]
    $uncommonLineEndingAction
  ) {
    <#
      .SYNOPSIS
    #>

    if (![SourceFolder]::IsValidLineEnding($lineEnding)) {
      $message = [SourceFolder]::InvalidLineEndingMessage($lineEnding)

      switch ($uncommonLineEndingAction) {
        SilentlyContinue {}
        WarnAndContinue {
          Write-Warning -Message $message
        }
        ErrorAndStop {
          throw [System.ArgumentException]::new($message)
        }
        default {
          throw 'This is not handled! If you see this message, the devs goofed.'
        }
      }
    }
  }

  static hidden [void] CheckLineEnding(
    [string]
    $lineEnding
  ) {
    <#
      .SYNOPSIS
    #>

    if (![SourceFolder]::IsValidLineEnding($lineEnding)) {
      $message = @(
        "$([SourceFolder]::InvalidLineEndingMessage($lineEnding));"
        'Use a common line ending, ComposeSourceFiles() without parameters,'
        'or ComposeSourceFiles($LineEnding, $UncommonLineEndingAction) instead.'
      ) -join ' '

      throw [System.ArgumentException]::new($message)
    }
  }

  #endregion Static methods

  #region Instance properties

  <#
    .SYNOPSIS
  #>
  [SourceCategory]
  $Category

  <#
    .SYNOPSIS
  #>
  [SourceScope]
  $Scope

  <#
    .SYNOPSIS
  #>
  [string]
  $NameSpace

  <#
    .SYNOPSIS
  #>
  [System.IO.DirectoryInfo]
  $DirectoryInfo

  <#
    .SYNOPSIS
  #>
  [SourceFile[]]
  $SourceFiles

  #endregion Instance properties

  #region Instance methods

  [bool] HasOrderedFiles() {
    <#
      .SYNOPSIS
    #>

    return (
      $this.Category -eq [SourceCategory]::Enum -or
      $this.Category -eq [SourceCategory]::Class
    )
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

  [void] FindSourceFiles() {
    <#
      .SYNOPSIS
    #>

    $basePath = $this.DirectoryInfo.FullName
    $this.SourceFiles = switch ($this.HasOrderedFiles()) {
      $true {
        $loadOrderJson = Join-Path -Path $basePath -ChildPath '.LoadOrder.jsonc'

        $loadOrder = Get-Content -Path $loadOrderJson
        | Where-Object -FilterScript { $_ -notmatch '^\s*\/\/' }
        | ConvertFrom-Json

        foreach ($item in $loadOrder) {
          $itemFileName = "$($item.Name).psm1"
          $itemPath = if ([string]::IsNullOrEmpty($item.Folder)) {
            Join-Path -Path $basePath -ChildPath $itemFileName
          } else {
            Join-Path -Path $basePath -ChildPath $item.Folder -AdditionalChildPath $itemFileName
          }

          try {
            $itemPath | Resolve-Path | ForEach-Object {
              [SourceFile]::new($this.NameSpace, $_.Path)
            }
          } catch {
            $errorMessage = @(
              "Unable to resolve source file from LoadOrder at '$itemPath'"
              "from configured options: $($item | ConvertTo-Json)"
            ) -join ' '
            throw [System.IO.FileNotFoundException]::New($errorMessage, $_.Exception)
          }
        }
      }
      $false {
        Get-ChildItem -Path $basePath -Include '*.ps1*', '*.psd1' -Exclude '*.Tests.ps1' -Recurse
        | ForEach-Object -Process {
          [SourceFile]::new($this.NameSpace, $_.FullName)
        }
      }
    }
  }

  [string] ComposeSourceFiles() {
    <#
      .SYNOPSIS
    #>

    if ($this.SourceFiles.Count -eq 0) {
      return ''
    }

    $output = New-Object -TypeName System.Text.StringBuilder

    $output.AppendLine("#region    $($this.NameSpace)").AppendLine()
    $this.SourceFiles.MungedContent | ForEach-Object -Process {
      $output.AppendLine($_).AppendLine()
    }
    $output.AppendLine("#endregion $($this.NameSpace)").AppendLine()

    return $output.ToString()
  }

  [string] ComposeSourceFiles(
    [string]
    $lineEnding
  ) {
    <#
      .SYNOPSIS
    #>

    [SourceFolder]::CheckLineEnding($lineEnding)

    if ($this.SourceFiles.Count -eq 0) {
      return ''
    }

    $output = New-Object -TypeName System.Text.StringBuilder
    $output.AppendLine("#region    $($this.NameSpace)").AppendLine()
    $this.SourceFiles.MungedContent | ForEach-Object -Process {
      $output.AppendLine($_).AppendLine()
    }
    $output.AppendLine("#endregion $($this.NameSpace)").AppendLine()

    return $output.ToString() -replace [regex]::Escape([System.Environment]::NewLine), $lineEnding
  }

  [string] ComposeSourceFiles(
    [string]
    $lineEnding,

    [UncommonLineEndingAction]
    $uncommonLineEndingAction
  ) {
    <#
      .SYNOPSIS
    #>

    [SourceFolder]::CheckLineEnding($lineEnding, $uncommonLineEndingAction)

    if ($this.SourceFiles.Count -eq 0) {
      return ''
    }

    $output = New-Object -TypeName System.Text.StringBuilder
    $output.AppendLine("#region    $($this.NameSpace)").AppendLine()
    $this.SourceFiles.MungedContent | ForEach-Object -Process {
      $output.AppendLine($_).AppendLine()
    }
    $output.AppendLine("#endregion $($this.NameSpace)").AppendLine()

    return $output.ToString() -replace [regex]::Escape([System.Environment]::NewLine), $lineEnding
  }

  #endregion Instance methods

  #region Constructors

  SourceFolder(
    [string]
    $nameSpace,

    [string]
    $path
  ) {
    <#
      .SYNOPSIS
    #>

    $this.NameSpace = $nameSpace
    $this.ResolveCategoryAndScopeFromNameSpace()
    $this.DirectoryInfo = $path
    $this.FindSourceFiles()
  }

  SourceFolder(
    [SourceCategory]
    $category,

    [SourceScope]
    $scope,

    [string]
    $path
  ) {
    <#
      .SYNOPSIS
    #>

    $this.Category      = $category
    $this.Scope         = $scope
    $this.NameSpace     = Resolve-NameSpace -Category $category -Scope $scope
    $this.DirectoryInfo = $path
    $this.FindSourceFiles()
  }

  SourceFolder(
    [string]
    $path
  ) {
    <#
      .SYNOPSIS
    #>

    $this.DirectoryInfo = Resolve-Path -Path $path -ErrorAction Stop
    | Select-Object -ExpandProperty Path
    $this.NameSpace = Resolve-NameSpace -Path $this.DirectoryInfo.FullName
    $this.ResolveCategoryAndScopeFromNameSpace()
    $this.FindSourceFiles()
  }

  #endregion Constructors
}
