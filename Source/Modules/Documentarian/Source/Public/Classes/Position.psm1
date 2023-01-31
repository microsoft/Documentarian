# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class Position {
  [System.IO.FileInfo]$FileInfo
  [int]$LineNumber
  [int]$StartColumn

  [string] ToString() {
    $StringValue = "$($this.LineNumber):$($this.StartColumn)"

    if ($null -ne $this.FileInfo) {
      $StringValue = "$($this.FileInfo):$StringValue"
    }

    return $StringValue
  }
}
