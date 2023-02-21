# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ./Position.psm1

Describe 'Class: Position' -Tag Unit {
  Context 'Property: FileInfo' {
    It 'defaults to $null' {
      ([Position]::new()).FileInfo | Should -BeNullOrEmpty
      $Fileless.FileInfo | Should -BeNullOrEmpty
    }
    It 'throws when set to an invalid object' {
      {
        [Position]@{FileInfo = Get-Item -Path $PSScriptRoot }
      } | Should -Throw
    }
  }

  Context 'Method: ToString' {
    Context 'When the Position has no FileInfo' {
      It 'Returns the line and column number separated by a colon' {
        $Position = [Position]@{
          LineNumber  = 13
          StartColumn = 22
        }

        $Position.ToString() | Should -Be '13:22'
      }
    }
    Context 'When the Position has FileInfo' {
      It 'Returns the full path, line number, and column number separated by a colon' {
        $Position = [Position]@{
          FileInfo    = Get-Item -Path $PSCommandPath
          LineNumber  = 13
          StartColumn = 22
        }

        $Position.ToString() | Should -Be "${PSCommandPath}:13:22"
      }
    }
  }
}
