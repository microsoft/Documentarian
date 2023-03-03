# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
    $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
    Resolve-Path -Path "$SourceFolder/Private/Functions/Get-ParameterMdHeaders.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
    . $RequiredFunction
}

#endregion RequiredFunctions

function Update-ParameterOrder {

    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [SupportsWildcards()]
        [string[]]$Path
    )

    $mdfiles = Get-ChildItem $path

    foreach ($file in $mdfiles) {
        $mdtext = Get-Content $file -Encoding utf8
        $mdheaders = Select-String -Pattern '^#' -Path $file

        $unsorted = Get-ParameterMdHeaders $mdheaders
        if ($unsorted.Count -gt 0) {
            $sorted = $unsorted | Sort-Object Line
            $newtext = $mdtext[0..($unsorted[0].StartLine - 1)]
            $confirmWhatIf = @()
            foreach ($paramblock in $sorted) {
                if ( '### -Confirm', '### -WhatIf' -notcontains $paramblock.Line) {
                    $newtext += $mdtext[$paramblock.StartLine..$paramblock.EndLine]
                } else {
                    $confirmWhatIf += $paramblock
                }
            }
            foreach ($paramblock in $confirmWhatIf) {
                $newtext += $mdtext[$paramblock.StartLine..$paramblock.EndLine]
            }
            $newtext += $mdtext[($unsorted[-1].EndLine + 1)..($mdtext.Count - 1)]

            Set-Content -Value $newtext -Path $file.FullName -Encoding utf8 -Force
            $file
        }
    }

}
