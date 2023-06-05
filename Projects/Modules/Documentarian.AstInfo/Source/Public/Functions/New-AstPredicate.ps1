# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/AstTypeTransformAttribute.psm1

Function New-AstPredicate {
    <#
        .SYNOPSIS
        Returns a scriptblock predicate for finding ASTs of a particular type.
    #>

    [CmdletBinding()]
    [OutputType([scriptblock])]
    Param (
        [Parameter(ValueFromPipeline)]
        [AstTypeTransformAttribute()]
        [System.Type]$Type
    )

    begin {
        $Predicate = {
            [CmdletBinding()]
            [OutputType([bool])]

            param(
                [Ast]$AstObject
            )

            return ($AstObject -is $Type)
        }
    }

    process {
        return $Predicate.GetNewClosure()
    }

    end {}
}
