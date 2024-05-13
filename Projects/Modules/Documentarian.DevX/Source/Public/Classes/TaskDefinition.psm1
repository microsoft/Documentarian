# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ./SourceFile.psm1

class TaskDefinition {
  <#
    .SYNOPSIS
    Defines an Invoke-Build task by name and source files.
  #>

  #region Static properties
  #endregion Static properties

  #region Static methods
  #endregion Static methods

  #region Instance properties

  <#
    .SYNOPSIS
    The name of the task.
  #>
  [string]
  $Name

  <#
    .SYNOPSIS
    The source files to include in the task.

    .DESCRIPTION
    The source files to include in the task. The content of the source files is munged and
    concatenated to form the content of the task file.
  #>
  [SourceFile[]]
  $SourceFiles

  #endregion Instance properties

  #region Instance methods

  [string] GetTaskName(
    [string]
    $prefix
  ) {
    <#
      .SYNOPSIS
      Return the name of the task with the specified prefix.

      .DESCRIPTION
      Return the name of the task with the specified prefix. The returned string includes the
      prefix and the task name, using a period (`.`) as a separator.

      .PARAMETER Prefix
      The prefix to use when composing the task name.
    #>
    return "$prefix.$($this.Name)"
  }

  [string] GetTaskPath(
    [string]
    $prefix
  ) {
    <#
      .SYNOPSIS
      Return the path to the task file with the specified prefix.

      .DESCRIPTION
      Return the path to the task file with the specified prefix. The returned string includes
      the prefix, the task name, and the file extension, using a forward slash (`/`) as a
      separator. Tasks are always composed in the `Tasks` directory of the output module, so the
      task path is always relative to the module root and found in the `Tasks` directory.

      .PARAMETER Prefix
      The prefix to use when composing the task name.
    #>

    return @(
      '$PSScriptRoot'
      'Tasks'
      "$($this.GetTaskName($prefix)).ps1"
    ) -join '/'
  }

  [string] ComposeContent() {
    <#
      .SYNOPSIS
      Compose the content of the task file.

      .DESCRIPTION
      Compose the content of the task file. The content is composed by concatenating the munged
      content of each source file in the task. The content of each source file is munged by
      stripping out the notices and prefixing the content with the namespace of the source file.
    #>

    if ($this.SourceFiles.Count -eq 0) {
      return ''
    }

    $output = New-Object -TypeName System.Text.StringBuilder

    $this.SourceFiles.MungedContent | ForEach-Object -Process {
      $output.AppendLine($_).AppendLine()
    }

    return $output.ToString()
  }

  #endregion Instance methods

  #region Constructors
  #endregion Constructors
}
