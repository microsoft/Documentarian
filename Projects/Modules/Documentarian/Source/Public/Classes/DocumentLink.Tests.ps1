# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ./DocumentLink.psm1

Describe 'Class: DocumentLink' -Tag Unit {
  Context 'Method: TrimSquareBrackets' {
    It 'Removes only the outermost bracket pair from text' {
      [DocumentLink]::TrimSquareBrackets('[outer[middle[inner]middle]]')
      | Should -Be 'outer[middle[inner]middle]'
    }
  }
}
