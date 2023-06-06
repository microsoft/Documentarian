# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language

function Resolve-TypeName {
    <#
        .SYNOPSIS
        Resolves a TypeName object to the type's full name.
    #>

    [CmdletBinding()]
    [OutputType([string])]
    param(
        # System.Management.Automation.Language.TypeName
        [parameter(ValueFromPipeline, Mandatory)]
        [ValidateScript({ $_ -is [TypeName] -or $_ -is [ArrayTypeName] })]
        $TypeName
    )

    process {
        $ReflectedTypeName = $TypeName.GetReflectionType().FullName
        [string]$ResolvedType = if (![string]::IsNullOrEmpty($ReflectedTypeName)) {
            $ReflectedTypeName
        } else {
            $TypeName.FullName
        }

        $ResolvedType
    }
}
