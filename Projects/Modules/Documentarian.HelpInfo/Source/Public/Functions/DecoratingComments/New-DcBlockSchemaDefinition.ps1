# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/DecoratingComments/DecoratingCommentsBlockKeyword.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsRegistry.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
    $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
    Resolve-Path -Path "$SourceFolder/Public/Functions/DecoratingComments/Get-DcBlockKeyword.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
    . $RequiredFunction
}

#endregion RequiredFunctions

function New-DcBlockSchemaDefinition {
    [CmdletBinding(DefaultParameterSetName = 'WithKeywordNames')]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]
        $Name,

        [string[]]
        $Alias,

        [Parameter(Mandatory, ParameterSetName = 'WithKeywordNames')]
        [string[]]
        $KeywordName,

        [Parameter(ParameterSetName = 'WithKeywordObjects')]
        [DecoratingCommentsBlockKeyword[]]
        $Keyword,

        [DecoratingCommentsRegistry]
        $Registry = $Global:ModuleAuthorDecoratingCommentsRegistry
    )

    begin {}

    process {
        if ($Name -notmatch '\w+') {
            $Message = @(
                "Invalid name '$Name'. The name of a DecoratingCommentsBlockSchema must be a"
                'string that only contains alphanumeric characters and underscores.'
            ) -join ' '
            throw $Message
        }
        foreach ($A in $Alias) {
            if ($A -notmatch '\w+') {
                $Message = @(
                    "Invalid alias '$A'. Aliases of a DecoratingCommentsBlockSchema must be a"
                    'string that only contains alphanumeric characters and underscores.'
                ) -join ' '
                throw $Message
            }
        }

        if ($Keyword.Count -eq 0) {
            if ($null -ne $Registry) {
                $Keyword = Get-DcBlockKeyword -Name $KeywordName -Registry $Registry
            } else {
                $Keyword = Get-DcBlockKeyword -Name $KeywordName
            }
            foreach ($KWName in $KeywordName) {
                if ($KWName -notin $Keyword.Name) {
                    $Message = @(
                        "Couldn't resolve specified KeywordName '$KWName' to a registered or"
                        'built-in DecoratedCommentsBlockKeyword. When creating a new schema'
                        'with keyword names, all keyword names must resolve to a keyword.'
                    )
                    throw $Message
                }
            }
        }

        if ($Keyword.Count -eq 0) {
            $Message = @(
                "Couldn't resolve options for new DecoratedCommentsBlockSchema."
                'Schemas must include at least one keyword, but no keywords were resolved.'
            )
            throw $Message
        }

        $ModuleStringBuilder = New-Object -TypeName System.Text.StringBuilder

        $null = $ModuleStringBuilder.AppendLine(
            'using module Documentarian.ModuleAuthor'
        ).AppendLine(
            ''
        ).AppendLine(
            "class $Name : DecoratingCommentsBlockSchema {"
        ).AppendLine(
            "  static [string] `$Name = '$Name'"
        )

        if ($Alias.Count -gt 0) {
            $null = $ModuleStringBuilder.AppendLine('  static [string[]] $Aliases = @(')
            foreach ($A in $Alias) {
                $null = $ModuleStringBuilder.AppendLine("    '$A'")
            }
            $null = $ModuleStringBuilder.AppendLine('  )')
        }

        $null = $ModuleStringBuilder.AppendLine(
            '  static [DecoratingCommentsBlockKeyword[]] $Keywords = @('
        )
        foreach ($K in $Keyword) {
            $null = $ModuleStringBuilder.AppendLine(
                '    [DecoratingCommentsBlockKeyword]@{'
            ).AppendLine(
                "      Name                    = '$($K.Name)'"
            ).AppendLine(
                "      Kind                    = '$($K.Kind)'"
            ).AppendLine(
                "      SupportsMultipleEntries = $($K.SupportsMultipleEntries)"
            ).AppendLine(
                "      Pattern                 = '$($K.Pattern)'"
            ).AppendLine(
                '    }'
            )
        }
        $null = $ModuleStringBuilder.AppendLine(
            '  )'
        ).AppendLine(
            '}'
        ).AppendLine()

        $ModuleStringBuilder.ToString()
    }

    end {}
}
