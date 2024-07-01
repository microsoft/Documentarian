# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ./SourceFile.psm1

class SourceReference {
  <#
    .SYNOPSIS
    Represents a source file reference with local and non-local references.
  #>

  #region Static properties
  #endregion Static properties

  #region Static methods
  #endregion Static methods

  #region Instance properties

  <#
    .SYNOPSIS
    The source file that is analyzed for references.

    .DESCRIPTION
    The source file that is analyzed for references. The source file is analyzed for using
    statements and other references to determine the preamble that should be included in the
    munged content when updating source references.
  #>
  [SourceFile]
  $SourceFile

  <#
    .SYNOPSIS
    The local references that are discovered in the source file.

    .DESCRIPTION
    The local references that are discovered in the source file. Local references include enums,
    classes, and functions that are defined in the same module as the source file. Local references
    are used to determine the preamble that should be included in the munged content when updating
    source references.
  #>
  [SourceFile[]]
  $LocalReferences

  <#
    .SYNOPSIS
    The non-local references that are discovered in the source file.

    .DESCRIPTION
    The non-local references that are discovered in the source file. Non-local references include
    using statements that reference modules outside of the current module, as well as any classes,
    enums, and functions that aren't defined in the current module. Non-local references are used
    to determine the preamble that should be included in the munged content when updating source
    references.
  #>
  [string[]]
  $NonLocalReferences

  <#
    .SYNOPSIS
    The preamble that should be included in the munged content when updating source references.

    .DESCRIPTION
    The preamble that should be included in the munged content when updating source references. The
    preamble includes using statements for non-local references and dot-sourcing for functions that
    are required by the source file.
  #>
  [string[]]
  $ReferencePreamble

  #endregion Instance properties

  #region Instance methods

  [void] DiscoverNonLocalReferences() {
    <#
      .SYNOPSIS
    #>

    if (!$this.NonLocalReferences) {
      $this.NonLocalReferences = $this.SourceFile.GetNonLocalUsingStatements()
    }
  }

  [void] ResolveAndSetReferencePreamble() {
    <#
      .SYNOPSIS
    #>

    $this.ReferencePreamble = $this.ResolveReferencePreamble()
    $this.WriteMungedContentWithReferencePreamble()
  }

  [void] SetReferencePreamble() {
    <#
      .SYNOPSIS
    #>

    $this.WriteMungedContentWithReferencePreamble()
  }

  [void] SetReferencePreamble(
    [string]
    $lineEnding
  ) {
    <#
      .SYNOPSIS
    #>

    $this.WriteMungedContentWithReferencePreamble($lineEnding)
  }

  [string[]] ResolveReferencePreamble() {
    <#
      .SYNOPSIS
    #>

    $lines = [string[]]@()

    $this.DiscoverNonLocalReferences()

    if ($this.NonLocalReferences.Count) {
      $lines += $this.NonLocalReferences
    }

    try {
      Push-Location -Path (Split-Path -Parent -Path $this.SourceFile.FileInfo.FullName)

      $lines += $this.LocalReferences
      | Where-Object -FilterScript {
        $_.Category.ToString() -ne 'Function' -and
        $_.FileInfo.BaseName -ne $this.SourceFile.FileInfo.BaseName
      } | Sort-Object -Property @(
        @{ Expression = 'Category' ; Descending = $true }
        @{ Expression = 'Scope'    ; Descending = $false }
      ) | ForEach-Object {
        "using module $((Resolve-Path -Relative -Path $_.FileInfo.FullName) -replace '\\', '/')"
      }

      $commandReferences = $this.LocalReferences
      | Where-Object -FilterScript {
        $_.Category.ToString() -eq 'Function' -and
        $_.FileInfo.BaseName -ne $this.SourceFile.FileInfo.BaseName
      } | Sort-Object -Property @(
        @{ Expression = 'Category' ; Descending = $true }
        @{ Expression = 'Scope'    ; Descending = $false }
      )

      if ($commandReferences) {
        # Make sure there's a line between requires/using statements and dot-sourcing
        if ($lines) {
          $lines += ''
        }
        # Find the source folder so we can truncate the segment for the preamble.
        # It needs to reference the determined source folder and not a full path
        # or the import breaks across systems.
        $sourceFolder = Get-Location | Select-Object -ExpandProperty Path
        while ('Source' -ne (Split-Path -Leaf $sourceFolder)) {
          $sourceFolder = Split-Path -Parent -Path $sourceFolder
        }

        $lines += @(
          '#region    RequiredFunctions'
          ''
          '$SourceFolder = $PSScriptRoot'
          "while ('Source' -ne (Split-Path -Leaf `$SourceFolder)) {"
          '    $SourceFolder = Split-Path -Parent -Path $SourceFolder'
          '}'
          '$RequiredFunctions = @('
          $commandReferences | ForEach-Object -Process {
            $filePath = $_.FileInfo.FullName
            if ($filePath -match "^$([regex]::Escape($sourceFolder))(?<ChildPath>.+)$") {
              $filePath = "`$SourceFolder/$($Matches.ChildPath.Trim('\/') -replace '\\', '/')"
            }
            "    Resolve-Path -Path `"$filePath`""
          }
          ')'
          'foreach ($RequiredFunction in $RequiredFunctions) {'
          '    . $RequiredFunction'
          '}'
          ''
          '#endregion RequiredFunctions'
        )
      }
    } catch {
    } finally {
      Pop-Location
    }

    return $lines
  }

  hidden [void] WriteMungedContentWithReferencePreamble() {
    <#
      .SYNOPSIS
    #>

    $lineEnding = $this.SourceFile.LineEnding

    if ([string]::IsNullOrEmpty($lineEnding)) {
      $lineEnding = [System.Environment]::NewLine
    }

    $sections = New-Object -TypeName System.Collections.Generic.List[String]

    foreach ($notice in $this.SourceFile.CopyrightNotices) {
      $sections.Add($notice)
    }

    foreach ($notice in $this.SourceFile.LicenseNotices) {
      $sections.Add($notice)
    }

    if ($this.ReferencePreamble.Count) {
      if ($sections.Count) {
        $sections.Add('')
      }
      foreach ($preamble in $this.ReferencePreamble) {
        $sections.Add($preamble)
      }
      $sections.Add('')
      $sections.Add($this.SourceFile.MungedContent)
      $sections.Add('')

      $sections
      | Join-String -Separator $LineEnding
      | Set-Content -Path $this.SourceFile.FileInfo.FullName -NoNewline
    }
  }

  hidden [void] WriteMungedContentWithReferencePreamble(
    [string]
    $lineEnding
  ) {
    <#
      .SYNOPSIS
    #>

    $sections = New-Object -TypeName System.Collections.Generic.List[String]

    foreach ($notice in $this.SourceFile.CopyrightNotices) {
      $sections.Add($notice)
    }

    foreach ($notice in $this.SourceFile.LicenseNotices) {
      $sections.Add($notice)
    }

    if ($this.ReferencePreamble.Count) {
      if ($sections.Count) {
        $sections.Add('')
      }
      foreach ($preamble in $this.ReferencePreamble) {
        $sections.Add($preamble)
      }
      $sections.Add('')
      $sections.Add($this.SourceFile.MungedContent)
      $sections.Add('')

      $sections
      | Join-String -Separator $LineEnding
      | Set-Content -Path $this.SourceFile.FileInfo.FullName -NoNewline
    }
  }

  #endregion Instance methods

  #region Constructors

  SourceReference(
    [SourceFile]
    $SourceFile
  ) {
    <#
      .SYNOPSIS
      Initialize a new instance of the SourceReference class from a **SourceFile**.

      .DESCRIPTION
      Initialize a new instance of the SourceReference class from a **SourceFile**. It analyzes the
      source file for non-local references and resolves the preamble that should be included in the
      munged content when updating source references. This ensures that, even without looking up
      references from other source files, the preamble includes using statements for non-local
      references.

      .PARAMETER SourceFile
      The source file to analyze for references.
    #>
    $this.SourceFile = $SourceFile

    $this.DiscoverNonLocalReferences()

    $this.ReferencePreamble = $this.ResolveReferencePreamble()
  }

  SourceReference(
    [SourceFile]
    $SourceFile,

    [SourceFile[]]
    $LocalReferences
  ) {
    <#
      .SYNOPSIS
      Initialize a new instance of the SourceReference class from a **SourceFile** and local
      references.

      .DESCRIPTION
      Initialize a new instance of the SourceReference class from a **SourceFile** and local
      references. It analyzes the source file for non-local references and resolves the preamble
      that should be included in the munged content when updating source references. This ensures
      that, even without looking up references from other source files, the preamble includes using
      statements for non-local references.

      .PARAMETER SourceFile
      The source file to analyze for references.

      .PARAMETER LocalReferences
      The local references that are discovered in the source file.
    #>
    $this.SourceFile = $SourceFile

    $this.DiscoverNonLocalReferences()

    $this.LocalReferences = $LocalReferences
    | Sort-Object -Unique -Property NameSpace, FileInfo

    $this.ReferencePreamble = $this.ResolveReferencePreamble()
  }

  #endregion Constructors
}
