# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Collections.Specialized
using module ../../Enums/DecoratingCommentsBlockKeywordKind.psm1
using module ./DecoratingCommentsBlockKeyword.psm1
using module ./DecoratingCommentsBlockKeyword.psm1

class DecoratingCommentsBlockParsed : System.Collections.Specialized.OrderedDictionary {
    [DecoratingCommentsBlockKeyword[]]$Keywords = @()

    DecoratingCommentsBlockParsed() : base([System.StringComparer]::OrdinalIgnoreCase) {}

    DecoratingCommentsBlockParsed([System.StringComparer]$comparer) : base($comparer) {}

    [void] Add([object]$key, [object]$value) {
        if ($key -is [DecoratingCommentsBlockKeyword]) {
            if ($key -notin $this.Keywords) {
                $this.Keywords += $key
            }
            ([OrderedDictionary]$this).Add($key.Name, $value)
        } else {
            ([OrderedDictionary]$this).Add($key, $value)
        }
    }

    [bool] IsUsable() {
        return $this.Keywords.Count -gt 0
    }

    [DecoratingCommentsBlockKeyword] GetKeyword([DecoratingCommentsBlockKeyword]$keyword) {
        return $this.GetKeyword($keyword.Name)
    }

    [DecoratingCommentsBlockKeyword] GetKeyword([string]$keyword) {
        return $this.Keywords |
            Where-Object -FilterScript { $_.Name -eq $keyword } |
            Select-Object -First 1
    }

    [object] GetKeywordEntry([DecoratingCommentsBlockKeyword]$keyword) {
        $ParsedKeyword = $this.GetKeyword($keyword)

        if ($null -eq $ParsedKeyword) {
            return $this.GetEntry($keyword.Name)
        }

        switch ($ParsedKeyword.Kind) {
            Block {
                if ($ParsedKeyword.SupportsMultipleEntries) {
                    return $this.GetKeywordBlockAll($ParsedKeyword.Name)
                } else {
                    return $this.GetKeywordBlock($ParsedKeyword.Name)
                }
            }
            BlockAndValue {
                if ($ParsedKeyword.SupportsMultipleEntries) {
                    return $this.GetKeywordBlockAndValueAll($ParsedKeyword.Name)
                } else {
                    return $this.GetKeywordBlockAndValue($ParsedKeyword.Name)
                }
            }
            BlockAndOptionalValue {
                if ($ParsedKeyword.SupportsMultipleEntries) {
                    return $this.GetKeywordBlockAndValueAll($ParsedKeyword.Name)
                } else {
                    return $this.GetKeywordBlockAndValue($ParsedKeyword.Name)
                }
            }
            Value {
                if ($ParsedKeyword.SupportsMultipleEntries) {
                    return $this.GetKeywordValueAll($ParsedKeyword.Name)
                } else {
                    return $this.GetKeywordValue($ParsedKeyword.Name)
                }
            }
        }

        return $this.GetEntry($ParsedKeyword.Name)
    }

    [object] GetKeywordEntry([string]$keyword) {
        if ($ParsedKeyword = $this.GetKeyword($keyword)) {
            return $this.GetKeywordEntry($ParsedKeyword)
        }

        return $null
    }

    [string] GetKeywordEntry([string]$keyword, [string]$value) {
        $Entry = $this.GetKeywordEntry($keyword)

        if ([string]::IsNullOrEmpty($value)) {
            return $Entry
        }

        return $Entry |
            Where-Object -FilterScript { $_.Value -eq $value } |
            Select-Object -First 1 |
            ForEach-Object -Process { $_.Content.Trim() }
    }

    [string] GetKeywordEntry([string]$keyword, [regex]$valuePattern) {
        $Entry = $this.GetKeywordEntry($keyword)

        if ([string]::IsNullOrEmpty($valuePattern)) {
            return $Entry
        }

        return $Entry |
            Where-Object -FilterScript { $_.Value -match $valuePattern } |
            Select-Object -First 1 |
            ForEach-Object -Process { $_.Content.Trim() }
    }

    hidden [object] GetEntry([string]$key) {
        return ([OrderedDictionary]$this)[$key]
    }


    [string] GetKeywordBlock([string]$keyword) {
        return $this.GetEntry($keyword) |
            Select-Object -First 1 |
            ForEach-Object { $_.Trim() }
    }

    [string] GetKeywordBlock([string]$keyword, [int]$index) {
        return $this.GetEntry($keyword)[$index] |
            ForEach-Object { $_.Trim() }
    }

    [string[]] GetKeywordBlockAll([string]$keyword) {
        return $this.GetEntry($keyword) |
            ForEach-Object { $_.Trim() }
    }

    [string] GetKeywordValue([string]$keyword) {
        return $this.GetEntry($keyword) |
            Select-Object -First 1 |
            ForEach-Object { $_.Trim() }
    }

    [string] GetKeywordValue([string]$keyword, [int]$index) {
        return $this.GetEntry($keyword)[$index] |
            ForEach-Object { $_.Trim() }
    }

    [string[]] GetKeywordValueAll([string]$keyword) {
        return $this.GetEntry($keyword) |
            ForEach-Object { $_.Trim() }
    }

    [DecoratingCommentsBlockParsed] GetKeywordBlockAndValue([string]$keyword) {
        return $this.GetEntry($keyword) | Select-Object -First 1
    }

    [string] GetKeywordBlockAndValue([string]$keyword, [string]$value) {
        return $this.GetEntry($keyword) |
            Where-Object -FilterScript { $_ -eq $value } |
            Select-Object -First 1 |
            ForEach-Object { $_.Content.Trim() }
    }

    [DecoratingCommentsBlockParsed] GetKeywordBlockAndValue([string]$keyword, [int]$index) {
        return $this.GetEntry($keyword)[$index]
    }

    [DecoratingCommentsBlockParsed[]] GetKeywordBlockAndValueAll([string]$keyword) {
        return $this.GetEntry($keyword)
    }
}
