# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language

Function ConvertFrom-BlockComment {
    [CmdletBinding()]
    Param(
        [token]$Token
    )

    begin {
        $LineEnding = if ($Token.Text -match "`r`n") { "`r`n" }else { "`n" }
        $LeadingWhiteSpace = $null
        $FirstNonEmptyLine = 0
        $Output = New-MarkdownStringBuilder
    }

    process {
        $Comment = if ($null -ne $Token.Text) { $Token.Text.Trim('(<#+|#+>)') }
        $Lines = $Comment -split $LineEnding

        for ($index = 0 ; $index -lt $Lines.Count ; $index++) {
            if (![string]::IsNullOrWhiteSpace($lines[$index])) {
                $FirstNonEmptyLine = $index
                $Line = $Lines[$index]
                $LeadingWhiteSpaceCount = $Line.Length - $Line.TrimStart().Length
                $LeadingWhiteSpace = $Line.Substring(0, $LeadingWhiteSpaceCount)
                break
            }
        }

        for ($index = $FirstNonEmptyLine ; $index -lt $Lines.Count ; $index++) {
            $LineIsEmpty = [string]::IsNullOrWhiteSpace($Lines[$Index])
            $IsLastLine = ($index -eq ($Lines.Count - 1))
            if ($IsLastLine -and $LineIsEmpty) {
                continue
            }

            $LineContent = $Lines[$index].TrimStart($LeadingWhiteSpace)
            Add-Line -Builder $Output -Content $LineContent
        }

        $Output.ToString()

    }

    end {}
}
