# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Generic
using namespace System.Collections.Specialized
using module ../../Classes/DecoratingComments/DecoratingCommentsRegistry.psm1

function ConvertFrom-DecoratingComment {
    [CmdletBinding()]
    [OutputType([OrderedDictionary])]
    param(
        [Parameter(Mandatory)]
        [string]$Comment,
        [string]$Schema,
        [Ast]$DecoratedAst,
        [DecoratingCommentsRegistry]$Registry = $Global:ModuleAuthorDecoratingCommentsRegistry
    )

    process {
        if ($null -eq $Registry) {
            $Message = @(
                'Called ConvertFrom-DecoratingComment, but the Registry parameter is null.'
                'You can use New-DecoratingCommentsRegistry to create a registry object,'
                'or Initialize-DcGlobalRegistry to create a global registry that the'
                "functions in this module will use when you don't specify the Registry parameter."
                "You can't parse a DecoratingComment without a registry's schemas."
            ) -join ' '
            throw $Message
        } elseif ($Registry.Schemas.Count -eq 0) {
            $Message = @(
                'Called ConvertFrom-DecoratingComment, but the Registry has no schemas.'
                "You can't parse a DecoratingComment without a registry's schemas."
            ) -join ' '
            throw $Message
        }

        $SpecifiedSchema = $PSBoundParameters.ContainsKey('Schema')
        $SpecifiedAst    = $PSBoundParameters.ContainsKey('DecoratedAst')

        if ($SpecifiedSchema -and $SpecifiedAst) {
            $Registry.ParseDecoratingCommentBlock($Comment, $Schema, $DecoratedAst)
        } elseif ($SpecifiedSchema) {
            $Registry.ParseDecoratingCommentBlock($Comment, $Schema)
        } elseif ($SpecifiedAst) {
            $Registry.ParseDecoratingCommentBlock($Comment, $DecoratedAst)
        } else {
            $Registry.ParseDecoratingCommentBlock($Comment)
        }
    }
}
