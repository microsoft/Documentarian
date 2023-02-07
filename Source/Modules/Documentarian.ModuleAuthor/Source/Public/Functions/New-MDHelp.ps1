# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function New-MDHelp {

    ### Runs New-MarkdownHelp with the parameters we use most often.

    param(
        [Parameter(Mandatory)]
        [string]$Module,

        [Parameter(Mandatory)]
        [string]$OutPath
    )
    $parameters = @{
        Module = $Module
        OutputFolder = $OutPath
        AlphabeticParamsOrder = $true
        UseFullTypeName = $true
        WithModulePage = $true
        ExcludeDontShow = $false
        Encoding = [System.Text.Encoding]::UTF8
    }
    New-MarkdownHelp @parameters

}
