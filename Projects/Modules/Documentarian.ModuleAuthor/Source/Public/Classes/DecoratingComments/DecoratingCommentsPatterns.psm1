# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../../Enums/DecoratingCommentsBlockKeywordKind.psm1

class DecoratingCommentsPatterns {

    static [regex] GetKeywordPattern([string]$keyword) {
        return [DecoratingCommentsPatterns]::GetBlockKeywordPattern($keyword)
    }

    static [regex] GetKeywordPattern([string]$keyword, [DecoratingCommentsBlockKeywordKind]$kind) {
        $KeywordPattern = switch ($kind) {
            Block {
                [DecoratingCommentsPatterns]::GetBlockKeywordPattern($keyword)
            }
            BlockAndValue {
                [DecoratingCommentsPatterns]::GetBlockAndValueKeywordPattern($keyword)
            }
            BlockAndOptionalValue {
                [DecoratingCommentsPatterns]::GetBlockAndOptionalValueKeywordPattern($keyword)
            }
            Value {
                [DecoratingCommentsPatterns]::GetValueKeywordPattern($keyword)
            }
        }

        return $KeywordPattern
    }

    static [regex] GetKeywordPattern(
        [string]$keyword,
        [regex]$pattern,
        [DecoratingCommentsBlockKeywordKind]$kind
    ) {
        $KeywordPattern = switch ($kind) {
            Block {
                [DecoratingCommentsPatterns]::GetBlockKeywordPattern($keyword)
            }
            BlockAndValue {
                [DecoratingCommentsPatterns]::GetBlockAndValueKeywordPattern($keyword, $pattern)
            }
            BlockAndOptionalValue {
                [DecoratingCommentsPatterns]::GetBlockAndOptionalValueKeywordPattern(
                    $keyword,
                    $pattern
                )
            }
            Value {
                [DecoratingCommentsPatterns]::GetValueKeywordPattern($keyword, $pattern)
            }
        }

        return $KeywordPattern
    }

    static [string] GetBlockKeywordPattern([string]$keyword) {
        return @(
            [DecoratingCommentsPatterns]::RegexMode()
            "^\s*\.${keyword}\s*$"      # Match the specific key declaration only.
            [DecoratingCommentsPatterns]::GetBlockContentPattern()
        ) -join ''
    }

    static [string] GetBlockAndValueKeywordPattern([string]$keyword) {
        return [DecoratingCommentsPatterns]::GetBlockAndValueKeywordPattern(
            $keyword,
            ([regex]'\S+')
        )
    }

    static [string] GetBlockAndValueKeywordPattern([string]$keyword, [regex]$pattern) {
        return @(
            [DecoratingCommentsPatterns]::RegexMode()
            "^\s*\.${keyword}\s*(?<Value>${pattern})\s*$"
            [DecoratingCommentsPatterns]::GetBlockContentPattern()
        ) -join ''
    }

    static [string] GetBlockAndOptionalValueKeywordPattern([string]$keyword) {
        return [DecoratingCommentsPatterns]::GetBlockAndOptionalValueKeywordPattern(
            $keyword,
            ([regex]'\S+')
        )
    }

    static [string] GetBlockAndOptionalValueKeywordPattern([string]$keyword, [regex]$pattern) {
        return @(
            [DecoratingCommentsPatterns]::RegexMode()
            "^\s*\.${keyword}\s*(?<Value>${pattern})?\s*$"
            [DecoratingCommentsPatterns]::GetBlockContentPattern()
        ) -join ''
    }

    static [string] GetValueKeywordPattern([string]$keyword) {
        return [DecoratingCommentsPatterns]::GetValueKeywordPattern($keyword, '.+')
    }

    static [string] GetValueKeywordPattern([string]$keyword, [regex]$pattern) {
        return @(
            [DecoratingCommentsPatterns]::RegexMode()
            "^\s*\.${keyword}\s*"
            [DecoratingCommentsPatterns]::GetValueContentPattern($pattern)
            '\s*$'
        ) -join ''
    }

    # Set the regex modes for the patterns used in this class.
    hidden static [string] RegexMode() {
        return @(
            '(?'                 # Start mode declaration
            '    m'.TrimStart()  # ^ and $ match start/end of line, not string.
            '    n'.TrimStart()  # Don't capture unnamed groups.
            ')'                  # End mode declaration
        ) -join ''
    }

    hidden static [string] GetKeywordsMatchingPattern([string[]]$keywords) {
        $EscapedKeywords = $keywords | ForEach-Object -Process {
            [regex]::Escape($_)
        }

        return "($($EscapedKeywords -join '|'))"
    }

    hidden static [string] GetValueContentPattern([regex]$pattern) {
        return "(?<Value>${pattern})"
    }

    hidden static [string] NegativeLookAhead([string]$keywordMatch) {
        return @(
            '(?!'                             # Don't capture if this sub pattern matches:
            '    \s*'.TrimStart()             #     Any whitespace, including newlines
            '    ^\s*'.TrimStart()            #     A line with any leading whitespace
            "    \.$KeywordMatch".TrimStart() #     A line that starts with another keyword.
            ')'                               # Close negative lookahead.
        ) -join ''
    }

    hidden static [string] GetNegativeLookAhead() {
        return [DecoratingCommentsPatterns]::NegativeLookAhead('\w{2,}')
    }

    hidden static [string] GetNegativeLookAhead([string[]]$keywords) {
        return [DecoratingCommentsPatterns]::NegativeLookAhead(
            [DecoratingCommentsPatterns]::GetKeywordsMatchingPattern($keywords)
        )
    }

    hidden static [string] BlockContentPattern([string]$negativeLookAhead) {
        return @(
            '(?<Content>'.TrimStart()                # Open capture group for the key's content.
            '    ('.TrimStart()                      # Open group to match with negative lookahead.
            '        (\s|.)'.TrimStart()             # Match any character, including newlines,
            "        $negativeLookAhead".TrimStart() # unless the negative lookahead pattern matches.
            '    )+'.TrimStart()                     # Match the group at least once, greedily.
            '    .?'.TrimStart()                     # Match the last character that was potentially missed.
            ')'                                      # Close the capture group.
        ) -join ''
    }

    hidden static [string] GetBlockContentPattern() {
        return [DecoratingCommentsPatterns]::BlockContentPattern(
            [DecoratingCommentsPatterns]::GetNegativeLookAhead()
        )
    }

    hidden static [string] GetBlockContentPattern([string[]]$keywords) {
        return [DecoratingCommentsPatterns]::BlockContentPattern(
            [DecoratingCommentsPatterns]::GetNegativeLookAhead($keywords)
        )
    }
}
