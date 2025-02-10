# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Generic
using namespace System.Collections.Specialized
using module ../../Classes/AstInfo.psm1
using module ../../Classes/DecoratingComments/DecoratingComments.psm1

function Get-DecoratingComment {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(ParameterSetName='FromAstInfo')]
        [AstInfo[]]$AstInfo,
        [Parameter(ParameterSetName='FromTargetAst')]
        [Ast[]]$TargetAst,
        [Parameter(ParameterSetName='FromTargetAst')]
        [Token[]]$Token
    )

    process {
        if ($AstInfo.Count -gt 0) {
            foreach ($Info in $AstInfo) {
                [DecoratingComments]::FindDecoratingComment($Info.Ast, $Info.Tokens)
            }
        }

        if ($TargetAst.Count -gt 0) {
            if ($null -eq $Token) {
                $Token = @()
            }

            foreach ($Target in $TargetAst) {
                [DecoratingComments]::FindDecoratingComment($Target, $Token)
            }
        }
    }
}
