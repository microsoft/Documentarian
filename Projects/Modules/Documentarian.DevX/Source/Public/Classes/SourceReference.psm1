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
    $LineEnding = $this.SourceFile.LineEnding

    if ([string]::IsNullOrEmpty($LineEnding)) {
      $LineEnding = [System.Environment]::NewLine
    }

    $Sections = New-Object -TypeName System.Collections.Generic.List[String]

    foreach ($notice in $this.SourceFile.CopyrightNotices) {
      $Sections.Add($notice)
    }

    foreach ($notice in $this.SourceFile.LicenseNotices) {
      $Sections.Add($notice)
    }

    if ($this.ReferencePreamble.Count) {
      if ($sections.Count) {
        $Sections.Add('')
      }
      foreach ($preamble in $this.ReferencePreamble) {
        $Sections.Add($preamble)
      }
      $Sections.Add('')
      $Sections.Add($this.SourceFile.MungedContent)
      $Sections.Add('')

      $Sections
      | Join-String -Separator $LineEnding
      | Set-Content -Path $this.SourceFile.FileInfo.FullName -NoNewline
    }
  }

  hidden [void] WriteMungedContentWithReferencePreamble([string]$LineEnding) {
    $Sections = New-Object -TypeName System.Collections.Generic.List[String]

    foreach ($notice in $this.SourceFile.CopyrightNotices) {
      $Sections.Add($notice)
    }

    foreach ($notice in $this.SourceFile.LicenseNotices) {
      $Sections.Add($notice)
    }

    if ($this.ReferencePreamble.Count) {
      if ($sections.Count) {
        $Sections.Add('')
      }
      foreach ($preamble in $this.ReferencePreamble) {
        $Sections.Add($preamble)
      }
      $Sections.Add('')
      $Sections.Add($this.SourceFile.MungedContent)
      $Sections.Add('')

      $Sections
      | Join-String -Separator $LineEnding
      | Set-Content -Path $this.SourceFile.FileInfo.FullName -NoNewline
    }
  }

  [void] ResolveAndSetReferencePreamble() {
    $this.ReferencePreamble = $this.ResolveReferencePreamble()
    $this.WriteMungedContentWithReferencePreamble()
  }

  [void] SetReferencePreamble() {
    $this.WriteMungedContentWithReferencePreamble()
  }

  [void] SetReferencePreamble([string]$LineEnding) {
    $this.WriteMungedContentWithReferencePreamble($LineEnding)
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
        # Find the source folder so we can truncate the segment for the preamble.
        # It needs to reference the determined source folder and not a full path
        # or the import breaks across systems.
        $SourceFolder = Get-Location | Select-Object -ExpandProperty Path
        while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
          $SourceFolder = Split-Path -Parent -Path $SourceFolder
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
            if ($FilePath -match "^$([regex]::Escape($SourceFolder))(?<ChildPath>.+)$") {
              $FilePath = "`$SourceFolder/$($Matches.ChildPath.Trim('\/') -replace '\\', '/')"
            }
            "  Resolve-Path -Path `"$FilePath`""
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
