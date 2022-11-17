# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ./SourceFile.psm1

class SourceReference {
  [SourceFile]$SourceFile
  [SourceFile[]]$LocalReferences
  [string[]]$NonLocalReferences
  [string[]]$ReferencePreamble

  SourceReference([SourceFile]$SourceFile) {
    $this.SourceFile = $SourceFile
    $this.DiscoverNonLocalReferences()
    $this.ReferencePreamble = $this.ResolveReferencePreamble()
  }

  SourceReference([SourceFile]$SourceFile, [SourceFile[]]$LocalReferences) {
    $this.SourceFile = $SourceFile
    $this.DiscoverNonLocalReferences()
    $this.LocalReferences = $LocalReferences | Sort-Object -Unique -Property NameSpace, FileInfo
    $this.ReferencePreamble = $this.ResolveReferencePreamble()
  }

  [void] DiscoverNonLocalReferences() {
    if (!$this.NonLocalReferences) {
      $this.NonLocalReferences = $this.SourceFile.GetNonLocalUsingStatements()
    }
  }

  hidden [void] WriteMungedContentWithReferencePreamble() {
    $LineEnding = [System.Environment]::NewLine

    if ($this.ReferencePreamble.Count) {
      @(
        $this.ReferencePreamble
        ''
        $this.SourceFile.MungedContent
      ) | Join-String -Separator $LineEnding | Set-Content -Path $this.SourceFile.FileInfo.FullName
    }
  }

  hidden [void] WriteMungedContentWithReferencePreamble([string]$LineEnding) {
    if ($this.ReferencePreamble.Count) {
      @(
        $this.ReferencePreamble
        ''
        $this.SourceFile.MungedContent
      ) | Join-String -Separator $LineEnding | Set-Content -Path $this.SourceFile.FileInfo.FullName
    }
  }

  [void] ResolveAndSetReferencePreamble() {
    $this.ReferencePreamble = $this.ResolveReferencePreamble()
    $this.WriteMungedContentWithReferencePreamble()
  }

  [void] SetReferencePreamble() {
    $this.WriteMungedContentWithReferencePreamble()
  }

  [string[]] ResolveReferencePreamble() {
    $Lines = [string[]]@()

    $this.DiscoverNonLocalReferences()

    if ($this.NonLocalReferences.Count) {
      $Lines += $this.NonLocalReferences
    }

    try {
      Push-Location -Path (Split-Path -Parent -Path $this.SourceFile.FileInfo.FullName)

      $Lines += $this.LocalReferences
      | Where-Object -FilterScript {
        $_.Category.ToString() -ne 'Function' -and
        $_.FileInfo.BaseName -ne $this.SourceFile.FileInfo.BaseName
      } | Sort-Object -Property @(
        @{ Expression = 'Category' ; Descending = $true }
        @{ Expression = 'Scope' ; Descending = $false }
      ) | ForEach-Object {
        "using module $((Resolve-Path -Relative -Path $_.FileInfo.FullName) -replace '\\', '/')"
      }

      $CommandReferences = $this.LocalReferences
      | Where-Object -FilterScript {
        $_.Category.ToString() -eq 'Function' -and
        $_.FileInfo.BaseName -ne $this.SourceFile.FileInfo.BaseName
      } | Sort-Object -Property @(
        @{ Expression = 'Category' ; Descending = $true }
        @{ Expression = 'Scope' ; Descending = $false }
      )

      if ($CommandReferences) {
        # Make sure there's a line between requires/using statements and dot-sourcing
        if ($Lines) {
          $Lines += ''
        }

        $Lines += @(
          '#region    RequiredFunctions'
          ''
          '$SourceFolder = $PSScriptRoot'
          "while ('Source' -ne (Split-Path -Leaf `$SourceFolder)) {"
          '  $SourceFolder = Split-Path -Parent -Path $SourceFolder'
          '}'
          '$RequiredFunctions = @('
          $CommandReferences | ForEach-Object -Process {
            $FilePath = $_.FileInfo.FullName
            if ($FilePath -match '(\\|\/)Source(\\|\/)(?<ChildPath>.+)$') {
              "  Resolve-Path -Path `"`$SourceFolder/$($Matches.ChildPath -replace '\\', '/')`""
            } else {
              "  Resolve-Path -Path $FilePath"
            }
          }
          ')'
          'foreach ($RequiredFunction in $RequiredFunctions) {'
          '  . $RequiredFunction'
          '}'
          ''
          '#endregion RequiredFunctions'
        )
      }
    } catch {
    } finally {
      Pop-Location
    }

    return $Lines
  }
}
