# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Private/Functions/Comments/ConvertFrom-BlockComment.ps1"
  Resolve-Path -Path "$SourceFolder/Private/Functions/Comments/Test-IsBlockComment.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

Function Resolve-CommentDecoration {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [int]$StatementFirstLine,
        [Parameter(Mandatory)]
        [token[]]$Tokens
    )

    begin {
        $ExpectedLastLine = $StatementFirstLine - 1
        $Tokens = $Tokens | Where-Object -FilterScript {
            $_.Kind -eq 'Comment'
        }
    }

    process {
        $LastComment = $Tokens | Where-Object -FilterScript {
            $_.Extent.EndLineNumber -eq ($ExpectedLastLine)
        }

        if ($null -eq $LastComment) {
            return # No decoration found
        }

        if (Test-IsBlockComment -Token $LastComment) {
            return ConvertFrom-BlockComment -Token $LastComment
        }

        $Lines = New-Object -TypeName 'System.Collections.Generic.List[string]'
        $Lines.Add($LastComment.Text.TrimStart('#').TrimStart())
        $PreviousLine = $Tokens | Where-Object -FilterScript {
            $_.Extent.EndLineNumber -eq ($LastComment.Extent.StartLineNumber - 1)
        }

        while ($null -ne $PreviousLine) {
            $Lines.Add($PreviousLine.Text.TrimStart('#').TrimStart())
            $ExpectedLastLine = $PreviousLine.Extent.StartLineNumber - 1
            $PreviousLine = $Tokens | Where-Object -FilterScript {
                $_.Extent.EndLineNumber -eq $ExpectedLastLine
            }
        }

        $Lines.Reverse()
        $Lines -join "`n"
    }

    end {}
}
