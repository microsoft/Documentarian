# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Generic
using namespace System.Collections.Specialized
using module ./DecoratingComments.psm1
using module ./DecoratingCommentsRegistry.psm1

class DecoratingComment {
    [string] $MungedValue
    [string] $LiteralValue
    [OrderedDictionary] $ParsedValue = [OrderedDictionary]::new([System.StringComparer]::OrdinalIgnoreCase)
    [bool] $ParsedAtCreation = $false

    DecoratingComment([string]$comment) {
        $this.LiteralValue = $comment
        $this.MungedValue = [DecoratingComment]::Munge($this.LiteralValue)
    }

    DecoratingComment([Ast]$targetAst, [Token[]]$tokens) {
        $this.LiteralValue = [DecoratingComments]::FindDecoratingComment($targetAst, $tokens)
        $this.MungedValue = [DecoratingComment]::Munge($this.LiteralValue)
    }

    DecoratingComment(
        [Ast]$targetAst,
        [Token[]]$tokens,
        [DecoratingCommentsRegistry]$registry
    ) {
        $this.LiteralValue = [DecoratingComments]::FindDecoratingComment($targetAst, $tokens)
        $this.MungedValue = [DecoratingComment]::Munge($this.LiteralValue)
        if ($this.LiteralValue -match '<#') {
            $this.ParsedValue = $registry.ParseDecoratingCommentBlock(
                $this.LiteralValue,
                $targetAst
            )
            # $this.SetParsedValueCaseSensitivity([System.StringComparer]::OrdinalIgnoreCase)
            $this.ParsedAtCreation = $true
        }
    }

    DecoratingComment(
        [Ast]$targetAst,
        [Token[]]$tokens,
        [DecoratingCommentsRegistry]$registry,
        [string]$schemaName
    ) {
        $this.LiteralValue = [DecoratingComments]::FindDecoratingComment($targetAst, $tokens)
        $this.MungedValue = [DecoratingComment]::Munge($this.LiteralValue)
        if ($this.LiteralValue -match '<#') {
            $this.ParsedValue = $registry.ParseDecoratingCommentBlock(
                $this.LiteralValue,
                $targetAst,
                $schemaName
            )
            # $this.SetParsedValueCaseSensitivity([System.StringComparer]::OrdinalIgnoreCase)
            $this.ParsedAtCreation = $true
        }
    }

    [string] ToString() {
        return $this.LiteralValue
    }

    [void] SetParsedValueCaseSensitivity([System.StringComparer]$comparer) {
        $Dictionary = [OrderedDictionary]::new($comparer)
        foreach ($Key in $this.ParsedValue.Keys) {
            $Dictionary.Add($Key, $this.ParsedValue.$Key)
        }
        $this.ParsedValue = $Dictionary
    }

    [void] SetParsedValueCaseInsensitive() {
        $this.SetParsedValueCaseSensitivity([System.StringComparer]::OrdinalIgnoreCase)
    }

    static [string] Munge([string]$comment) {
        $LeadSpace = ''

        if ($comment -match '^<#') {
            $Lines = $comment.TrimStart('<#').TrimEnd('#>').Trim("`n`r") -split '\r?\n'
            foreach ($Line in $Lines) {
                if ($Line -match '^(?<Lead>\s+)\S') {
                    $LeadSpace = $Matches.Lead
                    break
                }
            }
            
            $MungedLines = @()
            foreach ($Line in $Lines) {
                $MungedLines += $Line -replace "^$LeadSpace", ''
            }

            return ($MungedLines -join "`n")
        }
        $Lines = $comment -split '\r?\n'
        foreach ($Line in $Lines) {
            if ($Line -match '^#(?<Lead>\s+)\S') {
                $LeadSpace = $Matches.Lead
                break
            }
        }
        $MungedLines = @()
        foreach ($Line in $Lines) {
            $MungedLines += $Line -replace "^#$LeadSpace", ''
        }

        return $MungedLines
    }
}
