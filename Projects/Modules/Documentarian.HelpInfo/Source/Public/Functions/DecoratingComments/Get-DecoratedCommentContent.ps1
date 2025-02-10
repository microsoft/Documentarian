# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Get-KeywordContent {
    <#
        .SCHEMA Function

        .SYNOPSIS
        Retrieves the content for a keyword from a **DecoratedComment**.
    #>
    [cmdletbinding(DefaultParameterSetName='ByKeyword')]
    param(
        [Parameter(Mandatory, Position=0, ParameterSetName='ByKeyword')]
        [string]$Keyword,
        
        [Parameter(Mandatory, Position=0, ParameterSetName='ByPattern')]
        [regex]$Pattern,
        
        [string]$Comment
    )

    begin {

    }

    process {

    }
}