# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class Position {
  [System.IO.FileInfo]$FileInfo
  [int]$LineNumber
  [int]$StartColumn

  [string] ToString() {
    return "$($this.FileInfo):$($this.LineNumber):$($this.StartColumn)"
  }
}
