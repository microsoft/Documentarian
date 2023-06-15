# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Generic
using namespace System.Collections.Specialized

class DecoratingComments {
    static [bool] CanHaveCommentBlockInside([Ast]$targetAst) {
        return $targetAst.GetType().FullName -in @(
            [FunctionDefinitionAst].FullName
            [FunctionMemberAst].FullName
            [DataStatementAst].FullName
            [TypeDefinitionAst].FullName
        )
    }

    static [bool] CanHaveCommentBlockInside([AstInfo]$astInfo) {
        return [DecoratingComments]::CanHaveCommentBlockInside($astInfo.Ast)
    }

    static [Token[]] FindCommentTokensAbove([int]$expectedLastLine, [Token[]]$tokens) {
        <#
            .SYNOPSIS
            Finds comment tokens above a given line in parsed PowerShell code.

            .DESCRIPTION
            This method looks for a comment token on the line above a given
            line. If it finds no tokens, it returns `$null`. If it finds a
            block comment token, it returns that token.
            
            If it finds an inline comment token, like `# foo`, it checks the
            line above that comment to account for multi-line-non-block
            comments. It builds a list of all the adjacent comment tokens above
            the given line, ensuring they are returned in their correct order.

            If it finds a block comment token above the last discovered inline
            comment token, it ends the search and returns the list of line
            comment tokens it found.

            .PARAMETER expectedLastLine
            The line number to look for comment tokens at and above.
            
            If you're looking for comments above a given AST object, you can
            use the  value `$AstObject.Extent.StartLineNumber -1`, where
            `$AstObject` is the AST object you're looking for comments above.

            .PARAMETER tokens
            The list of tokens from the parsed PowerShell code to look for
            comments in. The method handles filtering for comment tokens.

            .EXAMPLE
            This example shows how the method finds adjacent comment tokens
            above a given line.

            ```powershell
            $AstInfo = Get-AstInfo -Text @'
            class ExampleClass {
                [string] $FirstProperty # This is the first property.
                # This is the first line of the comment above the property.
                #
                # This is the third line of the comment above the property.
                [string] $SecondProperty
            }
            '@
            [DecoratingComments]::FindCommentTokensAbove(
                5,
                $AstInfo.Tokens
            ).Extent.Text
            ```

            ```Output
            # This is the first property.
            # This is the first line of the comment above the property.
            #
            # This is the third line of the comment above the property.
            ```
        #>

        $CommentTokens = [DecoratingComments]::FilterForCommentTokens($tokens)

        $LastComment = $CommentTokens | Where-Object -FilterScript {
            $_.Extent.EndLineNumber -eq $expectedLastLine
        }

        if ($null -eq $LastComment) {
            return $null
        }

        if ($LastComment.Extent.Text -match '^<#') {
            return $LastComment
        }

        $Comments = [Token[]]@()
        $Comments += $LastComment

        $PreviousComment = [DecoratingComments]::FindPreviousInlineCommentToken(
            $LastComment,
            $CommentTokens
        )

        while ($null -ne $PreviousComment) {
            $Comments += $PreviousComment
            $PreviousComment = [DecoratingComments]::FindPreviousInlineCommentToken(
                $PreviousComment,
                $CommentTokens
            )
        }

        [Array]::Reverse($Comments)

        return $Comments
    }

    static [Token[]] FindCommentTokensAbove([Ast]$targetAst, [Token[]]$tokens) {
        <#
            .SYNOPSIS
            Finds comment tokens above an AST object in parsed PowerShell code.

            .DESCRIPTION
            This method looks for a comment token on the line above a given
            AST object's first line. If it finds no tokens, it returns `$null`.
            If it finds a block comment token, it returns that token.
            
            If it finds an inline comment token, like `# foo`, it checks that
            the comment is the only thing on the line. If the line only the
            comment with whitespace around it, the method checks the line above
            that comment to account for multi-line-non-block comments. It
            builds a list of all the adjacent comment tokens above the AST
            object, ensuring they are returned in their correct order.

            If it finds a line comment token that is preceded by non-whitespace,
            it ends the search and returns the list of line comment tokens it
            found.

            If it finds a block comment token above the last discovered inline
            comment token, it ends the search and returns the list of line
            comment tokens it found.

            .PARAMETER targetAst
            The AST object to look for comments above.
            
            The method uses the  value `$targetAst.Extent.StartLineNumber -1`,
            which only finds a comment immediately preceding the AST object.

            .PARAMETER tokens
            The list of tokens from the parsed PowerShell code to look for
            comments in. The method handles filtering for comment tokens.

            .EXAMPLE
            This example shows how the method finds adjacent comment tokens
            above a given line.

            ```powershell
            $astInfo = Get-AstInfo -Text @'
            class ExampleClass {
                [string] $FirstProperty # This is the first property.
                # This is the first line of the comment above the property.
                #
                # This is the third line of the comment above the property.
                [string] $SecondProperty
            }
            '@
            [DecoratingComments]::FindCommentTokensAbove(
                $astInfo.Ast,
                $AstInfo.Tokens
            ).Extent.Text
            ```

            ```Output
            # This is the first line of the comment above the property.
            #
            # This is the third line of the comment above the property.
            ```
        #>
        $FoundComments = [DecoratingComments]::FindCommentTokensAbove(
            ($targetAst.Extent.StartLineNumber - 1),
            $tokens
        )

        if ($null -eq $FoundComments) {
            return $null
        }

        if ($FoundComments[0].Extent.Text -match '^<#') {
            return $FoundComments
        }

        # Reverse the comments to check for invalid comments from the bottom up.
        [Array]::Reverse($FoundComments)
        
        # Initialize the list of valid comment.
        $Comments = [Token[]]@()
        
        # Find the correct parent. For TypeDefinitionAsts, their parent might
        # be NamedBlockAst, which is still the same extent as the type, not
        # including any comments above it.
        $Parent = $targetAst.Parent
        if ($Parent -is [NamedBlockAst]) {
            $Parent = $Parent.Parent
        }

        # Loop over each comment token, validating it.
        foreach ($Comment in $FoundComments) {
            # If the comment is a block, stop processing
            if ($Comment.Extent.Text -match '^<#') {
                break
            }
            # If the comment has non-whitespace before it, stop processing.
            $CommentAlonePattern = "(?m)^\s*$([Regex]::Escape($Comment.Extent.Text))"
            if ($Parent.Extent.Text -notmatch $CommentAlonePattern) {
                break
            }

            $Comments += $Comment
        }

        # Put the comments back in correct order
        [Array]::Reverse($Comments)

        return $Comments
    }

    static [Token[]] FindCommentTokensAbove([AstInfo]$astInfo) {
        <#
            .SYNOPSIS
            Finds comment tokens above an AstInfo object.

            .DESCRIPTION
            This method looks for a comment token on the line above a given
            AstInfo object's first line. If it finds no tokens, it returns
            `$null`. If it finds a block comment token, it returns that token.
            
            If it finds an inline comment token, like `# foo`, it checks that
            the comment is the only thing on the line. If it is, it checks the
            line above that comment to account for multi-line-non-block
            comments. It builds a list of all the adjacent comment tokens above
            the AST object, ensuring they are returned in their correct order.

            If it finds a line comment token that is preceded by non-whitespace,
            it ends the search and returns the list of line comment tokens it
            found.

            If it finds a block comment token above the last discovered inline
            comment token, it ends the search and returns the list of line
            comment tokens it found.

            .PARAMETER astInfo
            The AstInfo object to look for comments above.
            
            The method uses the  value `$astInfo.Ast.Extent.StartLineNumber -1`
            as the line it expects to find comments at or above, so the method
            only finds comments immediately preceding object's AST.

            The methodd uses the Tokens property of the AstInfo object as the
            list of tokens to search for the comments. The method handles
            filtering for comment tokens.

            .EXAMPLE
            This example shows how the method finds adjacent comment tokens
            above a given line.

            ```powershell
            $astInfo = Get-AstInfo -Text @'
            class ExampleClass {
                [string] $FirstProperty # This is the first property.
                # This is the first line of the comment above the property.
                #
                # This is the third line of the comment above the property.
                [string] $SecondProperty
            }
            '@
            [DecoratingComments]::FindCommentTokensAbove($astInfo).Extent.Text
            ```

            ```Output
            # This is the first line of the comment above the property.
            #
            # This is the third line of the comment above the property.
            ```
        #>
        return [DecoratingComments]::FindCommentTokensAbove($astInfo.Ast, $astInfo.Tokens)
    }

    static [Token] FindCommentBlockTokenAbove([int]$expectedLastLine, [Token[]]$tokens) {
        $CommentsAbove = [DecoratingComments]::FindCommentTokensAbove($expectedLastLine, $tokens)

        if ($null -eq $CommentsAbove) {
            return $null
        }

        if ($CommentsAbove.Extent.Text -notmatch '^<#') {
            return $null
        }

        return $CommentsAbove[0]
    }

    static [Token] FindCommentBlockTokenAbove([Ast]$targetAst, [Token[]]$tokens) {
        return [DecoratingComments]::FindCommentBlockTokenAbove(
            ($targetAst.Extent.StartLineNumber - 1),
            $tokens
        )
    }

    static [Token] FindCommentBlockTokenAbove([AstInfo]$astInfo) {
        return [DecoratingComments]::FindCommentBlockTokenAbove($astInfo.Ast, $astInfo.Tokens)
    }

    static [Token] FindCommentTokenAt([int]$targetLine, [Token[]]$tokens) {
        $CommentTokens = [DecoratingComments]::FilterForCommentTokens($tokens)

        return $CommentTokens | Where-Object -FilterScript {
            $_.Extent.StartLineNumber -eq $targetLine
        } | Select-Object -First 1
    }

    static [Token] FindCommentBlockTokenAt([int]$targetLine, [Token[]]$tokens) {
        $Comment = [DecoratingComments]::FindCommentTokenAt($targetLine, $tokens)

        if ($null -eq $Comment) {
            return $null
        }

        if ($Comment.Extent.Text -notmatch '^<#') {
            return $null
        }

        return $Comment
    }

    static [Token] FindCommentTokenBeside([ast]$targetAst, [Token[]]$tokens) {
        $Comment = [DecoratingComments]::FindCommentTokenAt(
            $targetAst.Extent.StartLineNumber,
            $tokens
        )

        if ($null -eq $Comment) {
            return $null
        }

        $TargetRegex  = [regex]::Escape($targetAst.Extent.Text)
        $CommentRegex = [regex]::Escape($Comment.Extent.Text)
        $IsBesideRegex = "$TargetRegex\s*$CommentRegex"

        if ($targetAst.Parent.Extent.Text -notmatch $IsBesideRegex) {
            return $null
        }

        if ($Comment.Extent.Text -match '\r?\n') {
            return $null
        }

        return $Comment
    }

    static [Token] FindCommentTokenBeside([AstInfo]$astInfo) {
        return [DecoratingComments]::FindCommentTokenBeside(
            $astInfo.Ast,
            $astInfo.Tokens
        )
    }

    static [Token] FindBlockCommentTokenIn([ast]$targetAst, [Token[]]$tokens) {
        # Only some types can have a comment block inside them. For all others,
        # immediately return null.
        if (-not [DecoratingComments]::CanHaveCommentBlockInside($targetAst)) {
            return $null
        }

        # Most valid types have a Body property, which we can use by looking
        # for a comment block on the first line of the body after its opening
        # brace.
        if ($targetAst -isnot [TypeDefinitionAst]) {
            $BlockComment = [DecoratingComments]::FindCommentBlockTokenAt(
                ($targetAst.Body.Extent.StartLineNumber + 1),
                $tokens
            )
            if ($BlockComment.Text -match '\r?\n') {
                return $BlockComment
            }
        }

        # TypeDefinitionASTs don't have a body, so we need to use a pattern to
        # see if they have a comment block before any other code.
        $HasCommentBlockPattern = '(?mn)(class|enum)\s+\w+\s*{\s*$\s*^\s*<#'
        if ($targetAst.Extent.Text -match $HasCommentBlockPattern) {
            # The TypeDefinition may have multiple lines, so we need to create
            # an offset that accounts for the number of lines before the opening
            # brace of the definition. To do so, get the full match, including
            # any preceding lines for attributes, and split it on newlines. We
            # want the total number of lines minus the last line where the
            # comment block starts.
            $FullOpenPattern = "(?n)^(.|\s)*?$([regex]::Escape($Matches[0]))"
            $OpeningLines = $targetAst.Extent.Text |
                Select-String -Pattern $FullOpenPattern |
                ForEach-Object -Process { $_.Matches[0].Value -split '\r?\n' }
            $LineOffset = $OpeningLines.Count - 1

            # Look for a comment block token on the line after the offset.
            $BlockComment = [DecoratingComments]::FindCommentBlockTokenAt(
                ($targetAst.Extent.StartLineNumber + $LineOffset),
                $tokens
            )

            if ($BlockComment.Text -match '\r?\n') {
                return $BlockComment
            }
        }

        return $null
    }

    static [Token] FindBlockCommentTokenIn([AstInfo]$astInfo) {
        return [DecoratingComments]::FindBlockCommentTokenIn(
            $astInfo.Ast,
            $astInfo.Tokens
        )
    }

    static [Token[]] FindDecoratingCommentTokens([ast]$targetAst, [Token[]]$tokens) {
        $InsideCommentToken = [DecoratingComments]::FindBlockCommentTokenIn($targetAst, $tokens)
        if ($null -ne $InsideCommentToken) {
            return $InsideCommentToken
        }

        $BesideCommentToken = [DecoratingComments]::FindCommentTokenBeside($targetAst, $tokens)
        if ($null -ne $BesideCommentToken) {
            return $BesideCommentToken
        }

        return [DecoratingComments]::FindCommentTokensAbove($targetAst, $tokens)
    }

    static [Token[]] FindDecoratingCommentTokens([AstInfo]$astInfo) {
        return [DecoratingComments]::FindDecoratingCommentTokens(
            $astInfo.Ast,
            $astInfo.Tokens
        )
    }

    static [Token] FindDecoratingCommentBlockToken([ast]$targetAst, [Token[]]$tokens) {
        $InsideCommentToken = [DecoratingComments]::FindBlockCommentTokenIn($targetAst, $tokens)
        if ($null -ne $InsideCommentToken) {
            return $InsideCommentToken
        }

        return [DecoratingComments]::FindCommentBlockTokenAbove($targetAst, $tokens)
    }

    static [string] FindDecoratingComment([ast]$targetAst, [Token[]]$tokens) {
        $CommentTokens = [DecoratingComments]::FindDecoratingCommentTokens($targetAst, $tokens)
        if ($null -eq $CommentTokens) {
            return $null
        }

        return ($CommentTokens.Extent.Text -join "`n")
    }

    static [string] FindDecoratingComment([AstInfo]$astInfo) {
        return [DecoratingComments]::FindDecoratingComment(
            $astInfo.Ast,
            $astInfo.Tokens
        )
    }

    static [string] FindDecoratingCommentBlock([ast]$targetAst, [Token[]]$tokens) {
        $CommentToken = [DecoratingComments]::FindDecoratingCommentBlockToken($targetAst, $tokens)
        if ($null -eq $CommentToken) {
            return $null
        }

        return $CommentToken.Text
    }

    static [string] FindDecoratingCommentBlock([AstInfo]$astInfo) {
        return [DecoratingComments]::FindDecoratingCommentBlock(
            $astInfo.Ast,
            $astInfo.Tokens
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

    hidden static [Token] FindPreviousCommentToken([Token]$commentToken, [Token[]]$tokens) {
        return $tokens | Where-Object -FilterScript {
            $_.Extent.EndLineNumber -eq ($commentToken.Extent.StartLineNumber - 1) -and
            $_.Kind -eq 'Comment'
        } | Select-Object -Last 1
    }

    hidden static [Token] FindPreviousInlineCommentToken([Token]$commentToken, [Token[]]$tokens) {
        return [DecoratingComments]::FindPreviousCommentToken($commentToken, $tokens) |
            Where-Object -FilterScript {
                $_.Extent.Text -notmatch '^<#'
            } | Select-Object -Last 1
    }
}
