# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ./DecoratingCommentsBlockKeyword.psm1
using module ./DecoratingCommentsBlockParsed.psm1

class DecoratingCommentsBlockSchema {
    <#
        .SYNOPSIS
        The name of the parser schema to use for a decorated comment.

        .DESCRIPTION
        The **Name** property is used to select the correct parser schema for a
        decorated comment.

        If a decorated comment declares the `Schema` keyword, the
        **DecoratingCommentsRegistry** tries to retrieve the correct schema by
        matching the keyword's value first to a schema's  **Name** and then
        **Alias**. Schemas can share aliases, but not names.

        If a decorated comment doesn't declare the `Schema` keyword, the caller
        needs to decide which schema to use based on the current context.
    #>
    static [string] $Name = $null

    <#
        .SYNOPSIS
        A list of alternate names for the parser schema.

        .DESCRIPTION
        The **Aliases** property is used to select the correct parser schema
        for a decorated comment.

        If a decorated comment declares the `Schema` keyword, the
        **DecoratingCommentsRegistry** tries to retrieve the correct schema by
        matching the keyword's value first to a schema's  **Name** and then
        **Alias**. Schemas can share aliases, but not names.

        If a decorated comment doesn't declare the `Schema` keyword, the caller
        needs to decide which schema to use based on the current context.

    #>
    static [string[]] $Aliases = @()

    [bool] $IsValid
    [bool] $HasValidated

    DecoratingCommentsBlockSchema() {
        $this.TestValidity()
    }

    DecoratingCommentsBlockSchema([bool]$quiet) {
        $this.TestValidity($quiet)
    }

    [string] GetName() {
        if ($GetMethod = $this.GetPropertyGetter('Name')) {
            return $GetMethod.Invoke($null, $null)
        }

        $Message = @(
            "The [$($this.GetType().FullName)] class didn't implement its own"
            "static 'Name' property as a string. It's not a valid implementation"
            'of [DecoratingCommentsBlockSchema].'
        ) -join ' '
        throw $Message
    }

    [string[]] GetAliases() {
        if ($GetMethod = $this.GetPropertyGetter('Aliases')) {
            return $GetMethod.Invoke($null, $null)
        }

        return @()
    }

    [DecoratingCommentsBlockKeyword[]] GetKeywords() {
        if ($GetMethod = $this.GetPropertyGetter('Keywords')) {
            return $GetMethod.Invoke($null, $null)
        }

        $Message = @(
            "The [$($this.GetType().FullName)] class didn't implement its own static 'Keywords'"
            "property as an array of [DecoratingCommentsBlockKeyword]. It's not a valid"
            'implementation of [DecoratingCommentsBlockSchema].'
        ) -join ' '
        throw $Message
    }

    [boolean] TestValidity() {
        return $this.TestValidity($true)
    }

    [boolean] TestValidity([bool]$quiet) {
        if (-not $this.HasValidated) {
            $this.IsValid = [DecoratingCommentsBlockSchema]::TestValidity($this.GetType(), $quiet)
            $this.HasValidated = $true
        }

        return $this.IsValid
    }

    [DecoratingCommentsBlockParsed] Parse([string]$comment) {
        <#
            .SYNOPSIS
            Parses the given comment string for comment-based help keys.

            .DESCRIPTION
            Parses the given comment token for the comment-based help keys
            defined as class properties. It returns the information as an
            ordered dictionary to the caller.

            .PARAMETER comment
            A string representing the text to parse for the comment-based help
            keys.
        #>

        $Parsed = [DecoratingCommentsBlockParsed]::new()

        foreach ($Keyword in $this.GetKeywords()) {
            switch ($Keyword.Kind) {
                Block {
                    if ($Keyword.SupportsMultipleEntries) {
                        $Blocks = [DecoratingCommentsBlockSchema]::GetKeywordBlockAll(
                            $Keyword.Pattern, $comment
                        ) | Where-Object -FilterScript { $_ -match '\S+' }

                        if ($Blocks.Count -gt 0) {
                            $Parsed.Add($Keyword, $Blocks)
                        }
                    } else {
                        $Block = [DecoratingCommentsBlockSchema]::GetKeywordBlock(
                            $Keyword.Pattern,
                            $comment
                        )
                        if ($Block -match '\S+') {
                            $Parsed.Add($Keyword, $Block)
                        }
                    }
                }
                BlockAndValue {
                    if ($Keyword.SupportsMultipleEntries) {
                        $Entries = [DecoratingCommentsBlockSchema]::GetKeywordBlockAndValueAll(
                            $Keyword.Pattern, $comment
                        )
                        if ($Entries.Count -gt 0) {
                            $Parsed.Add($Keyword, $Entries)
                        }
                    } else {
                        $Entry = [DecoratingCommentsBlockSchema]::GetKeywordBlockAndValue(
                            $Keyword.Pattern, $comment
                        )
                        if ($null -ne $Entry) {
                            $Parsed.Add($Keyword, $Entry)
                        }
                    }
                }
                BlockAndOptionalValue {
                    if ($Keyword.SupportsMultipleEntries) {
                        $Entries = [DecoratingCommentsBlockSchema]::GetKeywordBlockAndOptionalValueAll(
                            $Keyword.Pattern, $comment
                        )
                        if ($Entries.Count -gt 0) {
                            $Parsed.Add($Keyword, $Entries)
                        }
                    } else {
                        $Entry = [DecoratingCommentsBlockSchema]::GetKeywordBlockAndOptionalValue(
                            $Keyword.Pattern, $comment
                        )
                        if ($null -ne $Entry) {
                            $Parsed.Add($Keyword, $Entry)
                        }
                    }
                }
                Value {
                    if ($Keyword.SupportsMultipleEntries) {
                        $Values = [DecoratingCommentsBlockSchema]::GetKeywordValueAll(
                            $Keyword.Pattern, $comment
                        ) | Where-Object -FilterScript { $_ -match '\S+' }

                        if ($Values.Count -gt 0) {
                            $Parsed.Add($Keyword, $Values)
                        }
                    } else {
                        $Value = [DecoratingCommentsBlockSchema]::GetKeywordValue(
                            $Keyword.Pattern,
                            $comment
                        )
                        if ($Value -match '\S+') {
                            $Parsed.Add($Keyword, $Value)
                        }
                    }
                }
            }
        }

        return $Parsed
    }

    static [void] ValidateKeywordsProperty([System.Type]$schemaType) {
        $ValidReturnType = [DecoratingCommentsBlockKeyword[]]

        $Prefix = @(
            "[$schemaType] is not a valid implementation of DecoratingCommentsBlockSchema."
            "A valid implementation must define the 'Keywords' static property"
            "as an array with the type [$ValidReturnType] and at least one Keyword."
        ) -join ' '

        $KeywordsProperty = $schemaType.GetProperty('Keywords')
        if ($null -eq $KeywordsProperty) {
            $Message = @(
                $Prefix
                "[$schemaType] doesn't define the 'Keywords' property at all."
            ) -join ' '
            throw $Message
        }

        $KeywordsPropertyGetMethod = $KeywordsProperty.GetGetMethod()
        if (-not $KeywordsPropertyGetMethod.IsStatic) {
            $Message = @(
                $Prefix
                "[$schemaType]'s 'Keywords' property isn't static."
            ) -join ' '
            throw $Message
        }

        $ReturnType = $KeywordsPropertyGetMethod.ReturnType.FullName

        if ($ReturnType -ne $ValidReturnType.FullName) {
            $Message = @(
                $Prefix
                "[$schemaType]'s 'Keywords' property's return type is [$ReturnType]"
                "instead of [$ValidReturnType]"
            ) -join ' '
            throw $Message
        }

        try {
            $StaticKeywords = $KeywordsPropertyGetMethod.Invoke($null, $null) -as $ValidReturnType
        } catch {
            $Message = @(
                $Prefix
                "Retrieving the value of the 'Keywords' property failed."
            ) -join ' '
            throw $Message
        }

        if ($StaticKeywords.Count -eq 0) {
            $Message = @(
                $Prefix
                "The 'Keywords' property returned no Keywords."
            ) -join ' '
            throw $Message
        }
    }

    static [void] ValidateClassType([System.Type]$schemaType) {
        if (-not $schemaType.IsAssignableTo([DecoratingCommentsBlockSchema])) {
            $Message = @(
                'A valid schema must inherit from [DecoratingCommentsBlockSchema],'
                "but [$schemaType] doesn't."
            )
            throw $Message
        }
    }

    static [void] Validate([System.Type]$schemaType) {
        [DecoratingCommentsBlockSchema]::ValidateClassType($schemaType)
        [DecoratingCommentsBlockSchema]::ValidateKeywordsProperty($schemaType)
    }

    static [boolean] TestValidity([System.Type]$schemaType) {
        return [DecoratingCommentsBlockSchema]::TestValidity($schemaType, $true)
    }

    static [boolean] TestValidity([System.Type]$schemaType, [bool]$quiet) {
        $status = $true

        if ($quiet) {
            try {
                [DecoratingCommentsBlockSchema]::Validate($schemaType)
            } catch {
                $status = $false
            }
        } else {
            [DecoratingCommentsBlockSchema]::Validate($schemaType)
        }

        return $status
    }

    static [string] GetKeywordBlock([regex]$pattern, [string]$commentBlock) {
        $CleanedCommentBlock = [DecoratingCommentsBlockSchema]::CleanCommentBlock($commentBlock)

        $Content = if ($CleanedCommentBlock -match $pattern) {
            [DecoratingCommentsBlockSchema]::MungeKeywordBlock($Matches.Content)
        } else {
            ''
        }

        return $Content
    }

    static [string[]] GetKeywordBlockAll([regex]$pattern, [string]$comment) {
        $CleanedComment = [DecoratingCommentsBlockSchema]::CleanCommentBlock($comment)

        $Result = $CleanedComment |
        Select-String -Pattern $pattern -AllMatches |
        ForEach-Object -Process { $_.Matches.Groups } |
        Where-Object -FilterScript { $_.Name -eq 'Content' } |
        Select-Object -ExpandProperty Value |
        ForEach-Object -Process {
            [DecoratingCommentsBlockSchema]::MungeKeywordBlock($_)
        }

        return $Result
    }

    static [string] GetKeywordValue([regex]$pattern, [string]$commentBlock) {
        $CleanedCommentBlock = [DecoratingCommentsBlockSchema]::CleanCommentBlock($commentBlock)

        $Value = if ($CleanedCommentBlock -match $pattern) {
            $Matches.Value.Trim()
        } else {
            ''
        }

        return $Value
    }

    static [string[]] GetKeywordValueAll([regex]$pattern, [string]$comment) {
        $CleanedComment = [DecoratingCommentsBlockSchema]::CleanCommentBlock($comment)

        $Result = $CleanedComment |
        Select-String -Pattern $pattern -AllMatches |
        ForEach-Object -Process { $_.Matches.Groups } |
        Where-Object -FilterScript { $_.Name -eq 'Value' } |
        Select-Object -ExpandProperty Value |
        ForEach-Object -Process {
            $_.Trim()
        }

        return $Result
    }

    static [DecoratingCommentsBlockParsed] GetKeywordBlockAndValue([regex]$pattern, [string]$comment) {
        $CleanedComment = [DecoratingCommentsBlockSchema]::CleanCommentBlock($comment)

        if ($CleanedComment -match $pattern) {
            $Entry = [DecoratingCommentsBlockParsed]::new()
            $Value = $Matches.Value.Trim()
            $Content = [DecoratingCommentsBlockSchema]::MungeKeywordBlock($Matches.Content)
            $Entry.Add('Value', $Value)
            $Entry.Add('Content', $Content)
            return $Entry
        }

        return $null
    }

    static [DecoratingCommentsBlockParsed[]] GetKeywordBlockAndValueAll([regex]$pattern, [string]$comment) {
        $CleanedComment = [DecoratingCommentsBlockSchema]::CleanCommentBlock($comment)

        $Result = $CleanedComment |
        Select-String -Pattern $pattern -AllMatches |
        Select-Object -ExpandProperty Matches |
        ForEach-Object -Process {
            $Value = $_.Groups | Where-Object -FilterScript { $_.Name -eq 'Value' }
            $Content = $_.Groups | Where-Object -FilterScript { $_.Name -eq 'Content' }
            $Value = $Value.Value.Trim()
            $Content = [DecoratingCommentsBlockSchema]::MungeKeywordBlock($Content.Value)
            $Entry = [DecoratingCommentsBlockParsed]::new()
            $Entry.Add('Value', $Value)
            $Entry.Add('Content', $Content)
            $Entry
        }

        return $Result
    }

    static [DecoratingCommentsBlockParsed] GetKeywordBlockAndOptionalValue([regex]$pattern, [string]$comment) {
        $CleanedComment = [DecoratingCommentsBlockSchema]::CleanCommentBlock($comment)

        if ($CleanedComment -match $pattern) {
            $Entry = [DecoratingCommentsBlockParsed]::new()
            $Value = if ($Matches.Value) { $Matches.Value.Trim() } else { '' }
            $Content = [DecoratingCommentsBlockSchema]::MungeKeywordBlock($Matches.Content)
            $Entry.Add('Value', $Value)
            $Entry.Add('Content', $Content)
            return $Entry
        }

        return $null
    }

    static [DecoratingCommentsBlockParsed[]] GetKeywordBlockAndOptionalValueAll(
        [regex]$pattern,
        [string]$comment
    ) {
        $CleanedComment = [DecoratingCommentsBlockSchema]::CleanCommentBlock($comment)

        $Result = $CleanedComment |
        Select-String -Pattern $pattern -AllMatches |
        Select-Object -ExpandProperty Matches |
        ForEach-Object -Process {
            $Value = $_.Groups | Where-Object -FilterScript { $_.Name -eq 'Value' }
            $Content = $_.Groups | Where-Object -FilterScript { $_.Name -eq 'Content' }
            $Value = if ($Value.Value) { $Value.Value.Trim() } else { '' }
            $Content = [DecoratingCommentsBlockSchema]::MungeKeywordBlock($Content.Value)
            $Entry = [DecoratingCommentsBlockParsed]::new()
            $Entry.Add('Value', $Value)
            $Entry.Add('Content', $Content)
            $Entry
        }

        return $Result
    }

    static [string] MungeKeywordBlock([string]$content) {
        $Lines = [System.Collections.Generic.List[string]]::new()
        $LookingForFirstContentLine = $true

        foreach ($Line in ($Content -split '\r?\n')) {
            $LineIsEmpty = $Line -match '^\s*$'

            if ($LookingForFirstContentLine -and $LineIsEmpty) {
                continue
            } elseif ($LookingForFirstContentLine) {
                $Lines.Add($Line)
                $LookingForFirstContentLine = $false
            } else {
                $Lines.Add($Line)
            }
        }

        if ($Lines[0] -match '^\s*') {
            $Lead = $Matches[0]
            for ($i = 0; $i -lt $Lines.Count; $i++) {
                $Lines[$i] = $Lines[$i] -replace "^${Lead}", ''
            }
        }

        return ($Lines -join "`n").Trim()
    }

    static [string] CleanCommentBlock([string]$comment) {
        # Remove comment opener, if it exists.
        $munged = $comment -replace '^\s*<#', ''
        # Remove comment closer, if it exists.
        $munged = $munged -replace '\s*#>\s*$', ''

        return $munged
    }

    hidden [System.Reflection.PropertyInfo] GetPropertyInfo([string]$propertyName) {
        return $this.GetType().GetProperty($propertyName)
    }

    hidden [System.Reflection.MethodInfo] GetPropertyGetter([string]$propertyName) {
        if ($propertyInfo = $this.GetPropertyInfo($propertyName)) {
            return $propertyInfo.GetGetMethod()
        }

        return $null
    }
}
