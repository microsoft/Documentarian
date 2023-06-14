# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Enums/DecoratingCommentsBlockKeywordKind.psm1
using module ./DecoratingCommentsPatterns.psm1

class DecoratingCommentsBlockKeyword {
    <#
        .SYNOPSIS
        Represents a keyword in a comment block that decorates PowerShell code.
    #>

    <#
        .SYNOPSIS
        The name of the keyword.

        .DESCRIPTION
        The Name of a keyword is used as the actual Keyword when parsing. All
        keywords expect either a value, a block of text, or both after them.
    #>
    [string] $Name

    <#
        .SYNOPSIS
        The keyword's Kind, indicating how it should be parsed and written.
    #>
    [DecoratingCommentsBlockKeywordKind] $Kind
    [bool] $SupportsMultipleEntries
    [regex] $Pattern

    hidden [void] Initialize(
        [string]$name,
        [string]$kind,
        [bool]$supportsMultipleEntries,
        [regex]$pattern
    ) {
        $this.Name = $name

        $this.Kind = if ([string]::IsNullOrEmpty($kind)) {
            [DecoratingCommentsBlockKeyword]::GetDefaultKind()
        } else {
            $kind
        }

        $this.Pattern = if ([string]::IsNullOrEmpty($pattern)) {
            [DecoratingCommentsPatterns]::GetKeywordPattern($name, $this.Kind)
        } else {
            [DecoratingCommentsPatterns]::GetKeywordPattern($name, $pattern, $this.Kind)
        }

        $this.SupportsMultipleEntries = $supportsMultipleEntries
    }

    hidden static [DecoratingCommentsBlockKeywordKind] GetDefaultKind() {
        return [DecoratingCommentsBlockKeywordKind]::Block
    }

    DecoratingCommentsBlockKeyword(
        [string]$name
    ) {
        $this.Initialize($name, $null, $false, $null)
    }

    DecoratingCommentsBlockKeyword(
        [string]$name,
        [boolean]$supportsMultipleEntries
    ) {
        $this.Initialize($name, $null, $supportsMultipleEntries, $null)
    }

    DecoratingCommentsBlockKeyword(
        [string]$name,
        [DecoratingCommentsBlockKeywordKind]$kind
    ) {
        $this.Initialize($name, $kind, $false, $null)
    }

    DecoratingCommentsBlockKeyword(
        [string]$name,
        [regex]$pattern
    ) {
        $this.Initialize($name, $null, $false, $pattern)
    }

    DecoratingCommentsBlockKeyword(
        [string]$name,
        [DecoratingCommentsBlockKeywordKind]$kind,
        [boolean]$supportsMultipleEntries
    ) {
        $this.Initialize($name, $kind, $supportsMultipleEntries, $null)
    }

    DecoratingCommentsBlockKeyword(
        [string]$name,
        [boolean]$supportsMultipleEntries,
        [regex]$pattern
    ) {
        $this.Initialize($name, $null, $supportsMultipleEntries, $pattern)
    }

    DecoratingCommentsBlockKeyword(
        [string]$name,
        [DecoratingCommentsBlockKeywordKind]$kind,
        [boolean]$supportsMultipleEntries,
        [regex]$pattern
    ) {
        $this.Initialize($name, $kind, $supportsMultipleEntries, $pattern)
    }
}
