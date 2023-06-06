# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ./SourceFile.psm1

class TaskDefinition {
  [string]$Name
  [SourceFile[]]$SourceFiles

  [string] GetTaskName([string]$Prefix) {
    return "$Prefix.$($this.Name)"
  }

  [string] GetTaskPath([string]$Prefix) {
    return @(
      '$PSScriptRoot'
      'Tasks'
      "$($this.GetTaskName($Prefix)).ps1"
    ) -join '/'
  }

  [string] ComposeContent() {
    if ($this.SourceFiles.Count -eq 0) {
      return ''
    }

    $Output = New-Object -TypeName System.Text.StringBuilder

    $this.SourceFiles.MungedContent | ForEach-Object -Process {
      $Output.AppendLine($_).AppendLine()
    }

    return $Output.ToString()
  }
}
