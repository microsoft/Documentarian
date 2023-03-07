# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class ValeViolationPosition {
    [System.IO.FileInfo]$FileInfo
    [int]$Line
    [int]$StartColumn
    [int]$EndColumn

    [string] ToString() {
        if ($null -ne $this.FileInfo) {
            return @(
                @(
                    $this.FileInfo.FullName
                    $this.Line
                    $this.StartColumn
                ) -join ':'
                $this.EndColumn
            ) -join '-'
        }

        return @(
            @(
                $this.Line
                $this.StartColumn
            ) -join ':'
            $this.EndColumn
        ) -join '-'
    }

    [string] ToRelativeString() {
        if ($null -ne $this.FileInfo) {
            return @(
                @(
                    (Resolve-Path -Path $this.FileInfo.FullName -Relative)
                    $this.Line
                    $this.StartColumn
                ) -join ':'
                $this.EndColumn
            ) -join '-'
        }

        return @(
            @(
                $this.Line
                $this.StartColumn
            ) -join ':'
            $this.EndColumn
        ) -join '-'
    }
}
