# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class InlineFormatter {
    # The line ending character flags, any combination of `CR` and `LF`.
    [EmphasisStyle]
    $EmphasisStyle = [EmphasisStyle]::Underscore

    [EmphasisStyle]
    $StrongStyle = [EmphasisStyle]::Asterisk

    [StrikethroughStyle]
    $StrikethroughStyle = [StrikethroughStyle]::Tilde

    [HighlightStyle]
    $HighlightStyle = [HighlightStyle]::HTML

    [SubscriptStyle]
    $SubscriptStyle = [SubscriptStyle]::HTML

    [SuperscriptStyle]
    $SuperscriptStyle = [SuperscriptStyle]::HTML


    [string] Emphasize([string] $text) {
        <#
            .SYNOPSIS
            Emphasizes the specified text.

            .DESCRIPTION
            Emphasizes the specified text.

            .PARAMETER Text
            The text to emphasize.
        #>

        $munged = switch ($this.EmphasisStyle) {
            Underscore { "_${text}_" }
            Asterisk   { "*${text}*" }
            HTML       { "<em>${text}</em>" }
        }

        return $munged
    }

    [string] StronglyEmphasize([string] $text) {
        <#
            .SYNOPSIS
            Strongly emphasizes the specified text.

            .DESCRIPTION
            Strongly emphasizes the specified text.

            .PARAMETER Text
            The text to strongly emphasize.
        #>

        $munged = switch ($this.StrongStyle) {
            Underscore { "__${text}__" }
            Asterisk   { "**${text}**" }
            HTML       { "<strong>${text}</strong>" }
        }

        return $munged
    }

    [string] InlineCode([string] $text) {
        <#
            .SYNOPSIS
            Formats the specified text as inline code.

            .DESCRIPTION
            Formats the specified text as inline code.

            .PARAMETER Text
            The text to format as inline code.
        #>

        $munged = $text

        if ($text -match '`+') {
            $MinimumCount = $text |
                Select-String -AllMatches -Pattern '(?m)(?<InnerBackTick>`+)' |
                Select-Object -ExpandProperty Matches |
                ForEach-Object { $_.Groups.Where{$_.Name -eq 'InnerBacktick'}.Length } |
                Sort-Object -Descending |
                Select-Object -First 1

            $wrapper = '`' * ($MinimumCount + 1)
            $munged  = "${wrapper}${text}${wrapper}"
        } else {
            $munged = "``${text}``"
        }

        return $munged
    }

    [string] Strikethrough([string] $text) {
        <#
            .SYNOPSIS
            Formats the specified text as strikethrough text.

            .DESCRIPTION
            Formats the specified text as strikethrough text.

            .PARAMETER Text
            The text to format as strikethrough text.
        #>

        $munged = switch ($this.StrikethroughStyle) {
            Tilde { "~~${text}~~" }
            HTML  { "<del>${text}</del>" }
        }

        return $munged
    }

    [string] Highlight([string] $text) {
        <#
            .SYNOPSIS
            Formats the specified text as highlighted text.

            .DESCRIPTION
            Formats the specified text as highlighted text.

            .PARAMETER Text
            The text to format as highlighted text.
        #>

        $munged = switch ($this.HighlightStyle) {
            HTML    { "<mark>${text}</mark>" }
            Equals  { "==${text}==" }
        }

        return $munged
    }

    [string] Superscript([string] $text) {
        <#
            .SYNOPSIS
            Formats the specified text as superscript text.

            .DESCRIPTION
            Formats the specified text as superscript text.

            .PARAMETER Text
            The text to format as superscript text.
        #>

        $munged = switch ($this.SuperscriptStyle) {
            HTML  { "<sup>${text}</sup>" }
            Caret { "^${text}^" }
        }

        return $munged
    }

    [string] Subscript([string] $text) {
        <#
            .SYNOPSIS
            Formats the specified text as subscript text.

            .DESCRIPTION
            Formats the specified text as subscript text.

            .PARAMETER Text
            The text to format as subscript text.
        #>

        $munged = switch ($this.SubscriptStyle) {
            HTML  { "<sub>${text}</sub>" }
            Tilde { "~${text}~" }
        }

        return $munged
    }

    [string] Format([string] $text, [InlineFormatOptions]$options) {
        $munged = $text

        if ($options.HasFlag([InlineFormatOptions]::Code)) {
            $munged = $this.InlineCode($munged)
        }
        if ($options.HasFlag([InlineFormatOptions]::Emphasize)) {
            $munged = $this.Emphasize($munged)
        }
        if ($options.HasFlag([InlineFormatOptions]::Strong)) {
            $munged = $this.StronglyEmphasize($munged)
        }
        if ($options.HasFlag([InlineFormatOptions]::Strikethrough)) {
            $munged = $this.Strikethrough($munged)
        }
        if ($options.HasFlag([InlineFormatOptions]::Highlight)) {
            $munged = $this.Highlight($munged)
        }
        if ($options.HasFlag([InlineFormatOptions]::Superscript)) {
            $munged = $this.Superscript($munged)
        }
        if ($options.HasFlag([InlineFormatOptions]::Subscript)) {
            $munged = $this.Subscript($munged)
        }

        return $munged
    }
}
