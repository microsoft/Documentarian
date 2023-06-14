# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Function Test-IsAstType {
    <#
        .SYNOPSIS
        Determines if a type is an AST type.
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    Param(
        [System.Type]$Type
    )

    $InNamespace = $Type.NameSpace -eq 'System.Management.Automation.Language'
    $EndsInAst = $Type.Name -match 'Ast$'

    return ($InNamespace -and $EndsInAst)
}
