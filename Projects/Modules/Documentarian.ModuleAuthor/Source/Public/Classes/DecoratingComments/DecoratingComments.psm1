# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Generic
using namespace System.Collections.Specialized

class DecoratingComments {
    static [string] FindDecoratingComment([ast]$targetAst, [Token[]]$tokens) {
        $InsideComment = [DecoratingComments]::FindDecoratingCommentBlockIn($targetAst, $tokens)
        if ($InsideComment -match '\S+') {
            return $InsideComment
        }

        return [DecoratingComments]::FindDecoratingCommentAbove(
            ($targetAst.Extent.StartLineNumber - 1),
            $tokens
        )
    }

    static [string] FindDecoratingCommentBlock([ast]$targetAst, [Token[]]$tokens) {
        $InsideComment = [DecoratingComments]::FindDecoratingCommentBlockIn($targetAst, $tokens)
        if ($InsideComment -match '\S+') {
            return $InsideComment
        }

        return [DecoratingComments]::FindDecoratingCommentBlockAbove(
            ($targetAst.Extent.StartLineNumber - 1),
            $tokens
        )
    }

    static [Token[]] FilterForCommentTokens([Token[]]$tokens) {
        return $tokens | Where-Object -FilterScript {
            $_.Kind -eq 'Comment'
        }
    }

    static [Token[]] FilterForCommentBlockTokens([Token[]]$tokens) {
        return [DecoratingComments]::FilterForCommentTokens($tokens) | Where-Object -FilterScript {
            $_ -match '^<#'
        }
    }

    static [string] FindDecoratingCommentAbove([int]$expectedLastLine, [Token[]]$tokens) {
        $CommentTokens = [DecoratingComments]::FilterForCommentTokens($tokens)

        $LastComment = $CommentTokens | Where-Object -FilterScript {
            $_.Extent.EndLineNumber -eq $expectedLastLine
        }

        if ($null -eq $LastComment) {
            return $null
        }

        if ($LastComment -match '^<#') {
            return $LastComment
        }

        $Lines = [List[string]]::new()
        $Lines.Add($LastComment.Text.TrimStart('#').TrimStart())

        $PreviousLine = $CommentTokens | Where-Object -FilterScript {
            $_.Extent.EndLineNumber -eq ($LastComment.Extent.StartLineNumber - 1)
        }

        while ($null -ne $PreviousLine) {
            $Lines.Add($PreviousLine.Text.TrimStart('#').TrimStart())
            $ExpectedLastLine = $PreviousLine.Extent.StartLineNumber - 1
            $PreviousLine = $Tokens | Where-Object -FilterScript {
                $_.Extent.EndLineNumber -eq $ExpectedLastLine -and
                $_.Kind -eq 'Comment'
            }
        }

        $Lines.Reverse()

        return ($Lines -join "`n")
    }

    static [string] FindDecoratingCommentBlockAbove([int]$expectedLastLine, [Token[]]$tokens) {
        $CommentTokens = [DecoratingComments]::FilterForCommentTokens($tokens)

        $LastComment = $CommentTokens | Where-Object -FilterScript {
            $_.Extent.EndLineNumber -eq $expectedLastLine
        }

        if ($null -eq $LastComment) {
            return $null
        }

        if ($LastComment -notmatch '^<#') {
            return $null
        }

        return $LastComment
    }

    static [string] FindDecoratingCommentBlockAt([int]$expectedFirstLine, [Token[]]$tokens) {
        $CommentTokens = [DecoratingComments]::FilterForCommentTokens($tokens)

        $LastComment = $CommentTokens | Where-Object -FilterScript {
            $_.Extent.StartLineNumber -eq $expectedFirstLine
        }

        if ($null -eq $LastComment) {
            return $null
        }

        if ($LastComment -notmatch '^<#') {
            return $null
        }

        return $LastComment
    }

    static [string] FindDecoratingCommentBlockIn([Ast]$targetAst, [Token[]] $tokens) {
        $CommentTokens = [DecoratingComments]::FilterForCommentTokens($tokens)

        $ValidTargetAstTypes = @(
            [FunctionDefinitionAst]
            [FunctionMemberAst]
            [DataStatementAst]
            [TypeDefinitionAst]
        )

        if ($targetAst.GetType().FullName -notin $ValidTargetAstTypes.FullName) {
            return $null
        }

        if ($targetAst -isnot [TypeDefinitionAst]) {
            $InternalBlock = [DecoratingComments]::FindDecoratingCommentBlockAt(
                ($targetAst.Body.Extent.StartLineNumber + 1),
                $CommentTokens
            )
            # Only return multi-line internal blocks
            if ($InternalBlock -match '\r?\n') {
                return $InternalBlock
            }
        }

        if ($targetAst.Extent.Text -match '(?mn)(class|enum)\s+\w+\s*{\s*$\s*^\s*<#') {
            $LineOffset = ($Matches[0] -split '\r?\n').Count - 1

            return [DecoratingComments]::FindDecoratingCommentBlockAt(
                ($targetAst.Extent.StartLineNumber + $LineOffset),
                $CommentTokens
            )
        }

        return $null
    }
}
