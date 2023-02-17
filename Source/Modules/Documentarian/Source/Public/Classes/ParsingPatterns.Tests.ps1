# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ./ParsingPatterns.psm1

Describe 'Class: ParsingPatterns' -Tag Unit {
  Context 'Property: LineLead' {
    It 'Handles text after <Case>' -TestCases @(
      @{
        Case               = 'leading spaces'
        Line               = '  Some text.'
        ExpectedLeadLength = 2
      }
      @{
        Case               = 'a single blockquote'
        Line               = '> Some text.'
        ExpectedLeadLength = 2
      }
      @{
        Case               = 'a single blockquote after leading spaces'
        Line               = '  > Some text.'
        ExpectedLeadLength = 4
      }
      @{
        Case               = 'nested blockquotes'
        Line               = '> > Some text.'
        ExpectedLeadLength = 4
      }
      @{
        Case               = 'an ordered list syntax'
        Line               = '1. Some text.'
        ExpectedLeadLength = 3
      }
      @{
        Case               = 'an unordered list syntax (-)'
        Line               = '- Some text.'
        ExpectedLeadLength = 2
      }
      @{
        Case               = 'an unordered list syntax (+)'
        Line               = '+ Some text.'
        ExpectedLeadLength = 2
      }
      @{
        Case               = 'an unordered list syntax (*)'
        Line               = '* Some text.'
        ExpectedLeadLength = 2
      }
      @{
        Case               = 'leading whitespace, nested blockquotes, and ordered list syntax'
        Line               = '  > > 1. Some text.'
        ExpectedLeadLength = 9
      }
    ) {
      $Line -match [ParsingPatterns]::LineLead | Should -BeTrue

      $Matches.Lead.Length | Should -Be $ExpectedLeadLength
    }
  }
  Context 'Method: InSquareBrackets' {
    It 'Returns no match when the brackets do not close after opening' {
      $Line = '[this link() is missing a bracket'
      $Line -match [ParsingPatterns]::InSquareBrackets() | Should -BeFalse
    }
    It 'Matches a closed bracket pair nested inside an unclosed pair' {
      $Line = '[outer ![inner]()'
      $Line -match [ParsingPatterns]::InSquareBrackets() | Should -BeTrue
      $Matches.Close | Should -BeExactly 'inner'
    }
    It 'Returns the text for the outer-most bracket pair without the brackets' {
      $Line = '[outer[middle[inner]]]'
      $Line -match [ParsingPatterns]::InSquareBrackets() | Should -BeTrue
      $Matches.Close | Should -BeExactly 'outer[middle[inner]]'
    }
    It 'Uses "Open" and "Close" as the default balance group names' {
      $Pattern = [ParsingPatterns]::InSquareBrackets()
      $Pattern | Should -Match ([regex]::Escape('?<Open>'))
      $Pattern | Should -Match ([regex]::Escape('?<Close-Open>'))
    }
    It 'Appends the BalanceGroupName parameter to the open capture group if used' {
      $Pattern = [ParsingPatterns]::InSquareBrackets('Example')
      $Pattern | Should -Match ([regex]::Escape('?<OpenExample>'))
    }
    It 'Uses the BalanceGroupName parameter as the name of the close capture group' {
      $Pattern = [ParsingPatterns]::InSquareBrackets('Example')
      $Pattern | Should -Match ([regex]::Escape('?<Example-OpenExample>'))
    }
  }
}
