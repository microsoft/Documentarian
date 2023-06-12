# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Enums/DecoratingCommentsBlockKeywordKind.psm1
using module ./DecoratingCommentsBlockKeyword.psm1

class DecoratingCommentsBlockKeywords {
    static [DecoratingCommentsBlockKeyword]
    $Component = [DecoratingCommentsBlockKeyword]::new(
        'COMPONENT',
        [DecoratingCommentsBlockKeywordKind]::Value,
        $true
    )
    
    static [DecoratingCommentsBlockKeyword]
    $Description = [DecoratingCommentsBlockKeyword]::new(
        'DESCRIPTION',
        [DecoratingCommentsBlockKeywordKind]::Block,
        $false
    )

    static [DecoratingCommentsBlockKeyword]
    $Example = [DecoratingCommentsBlockKeyword]::new(
        'EXAMPLE',
        [DecoratingCommentsBlockKeywordKind]::BlockAndOptionalValue,
        $true
    )

    static [DecoratingCommentsBlockKeyword]
    $Exception = [DecoratingCommentsBlockKeyword]::new(
        'EXCEPTION',
        [DecoratingCommentsBlockKeywordKind]::BlockAndValue,
        $true
    )

    static [DecoratingCommentsBlockKeyword]
    $ExternalHelp = [DecoratingCommentsBlockKeyword]::new(
        'EXTERNALHELP',
        [DecoratingCommentsBlockKeywordKind]::Value,
        $false,
        [DecoratingCommentsBlockKeywords]::ExternalHelpPattern()
    )

    static [DecoratingCommentsBlockKeyword]
    $ForwardHelpCategory = [DecoratingCommentsBlockKeyword]::new(
        'FORWARDHELPCATEGORY',
        [DecoratingCommentsBlockKeywordKind]::Value,
        $false
    )

    static [DecoratingCommentsBlockKeyword]
    $ForwardHelpTargetName = [DecoratingCommentsBlockKeyword]::new(
        'FORWARDHELPTARGETNAME',
        [DecoratingCommentsBlockKeywordKind]::Value,
        $false
    )

    static [DecoratingCommentsBlockKeyword]
    $Functionality = [DecoratingCommentsBlockKeyword]::new(
        'FUNCTIONALITY',
        [DecoratingCommentsBlockKeywordKind]::Value,
        $true
    )

    static [DecoratingCommentsBlockKeyword]
    $Inputs = [DecoratingCommentsBlockKeyword]::new(
        'INPUTS',
        [DecoratingCommentsBlockKeywordKind]::BlockAndValue,
        $true
    )

    static [DecoratingCommentsBlockKeyword]
    $Label = [DecoratingCommentsBlockKeyword]::new(
        'LABEL',
        [DecoratingCommentsBlockKeywordKind]::BlockAndValue,
        $true
    )

    static [DecoratingCommentsBlockKeyword]
    $Link = [DecoratingCommentsBlockKeyword]::new(
        'LINK',
        [DecoratingCommentsBlockKeywordKind]::Value,
        $true
    )

    static [DecoratingCommentsBlockKeyword]
    $Method = [DecoratingCommentsBlockKeyword]::new(
        'METHOD',
        [DecoratingCommentsBlockKeywordKind]::BlockAndValue,
        $true
    )

    static [DecoratingCommentsBlockKeyword]
    $Notes = [DecoratingCommentsBlockKeyword]::new(
        'NOTES',
        [DecoratingCommentsBlockKeywordKind]::Block,
        $false
    )

    static [DecoratingCommentsBlockKeyword]
    $Outputs = [DecoratingCommentsBlockKeyword]::new(
        'OUTPUTS',
        [DecoratingCommentsBlockKeywordKind]::BlockAndValue,
        $true
    )

    static [DecoratingCommentsBlockKeyword]
    $Parameter = [DecoratingCommentsBlockKeyword]::new(
        'PARAMETER',
        [DecoratingCommentsBlockKeywordKind]::BlockAndValue,
        $true
    )

    static [DecoratingCommentsBlockKeyword]
    $RemoteHelpRunspace = [DecoratingCommentsBlockKeyword]::new(
        'REMOTEHELPRUNSPACE',
        [DecoratingCommentsBlockKeywordKind]::Value,
        $false
    )

    static [DecoratingCommentsBlockKeyword]
    $Role = [DecoratingCommentsBlockKeyword]::new(
        'ROLE',
        [DecoratingCommentsBlockKeywordKind]::Value,
        $true
    )

    static [DecoratingCommentsBlockKeyword]
    $Schema = [DecoratingCommentsBlockKeyword]::new(
        'SCHEMA',
        [DecoratingCommentsBlockKeywordKind]::Value,
        $false
    )

    static [DecoratingCommentsBlockKeyword]
    $Synopsis = [DecoratingCommentsBlockKeyword]::new(
        'SYNOPSIS',
        [DecoratingCommentsBlockKeywordKind]::Block,
        $false
    )

    hidden static [string] ExternalHelpPattern() {
        return @(
            '('
                '\S+'   # Matches a bare string without spaces
                '|'
                '".*"'  # Matches a double-quoted string
                '|'
                "'.*'"  # Matches a single-quoted string
            ')'
        ) -join ''
    }
}
