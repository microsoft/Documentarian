# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/DecoratingComments/DecoratingCommentsBlockKeyword.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsBlockSchema.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsRegistry.psm1

function Get-DcBlockSchema {
    [CmdletBinding(DefaultParameterSetName='ByValueFromAny')]
    [OutputType([DecoratingCommentsBlockSchema[]])]
    param(
        [Parameter(ParameterSetName='ByValueFromAny')]
        [Parameter(ParameterSetName='ByValueFromBuiltIn')]
        [Parameter(ParameterSetName='ByValueFromRegistry')]
        [string[]]$SchemaValue,

        [Parameter(ParameterSetName='ByNameFromAny')]
        [Parameter(ParameterSetName='ByNameFromBuiltIn')]
        [Parameter(ParameterSetName='ByNameFromRegistry')]
        [string[]]$Name,

        [Parameter(ParameterSetName='ByAliasFromAny')]
        [Parameter(ParameterSetName='ByAliasFromBuiltIn')]
        [Parameter(ParameterSetName='ByAliasFromRegistry')]
        [string[]]$Alias,

        [DecoratingCommentsBlockKeyword[]]$IncludesKeyword,

        [Parameter(ParameterSetName='ByValueFromAny')]
        [Parameter(ParameterSetName='ByValueFromRegistry')]
        [Parameter(ParameterSetName='ByNameFromAny')]
        [Parameter(ParameterSetName='ByNameFromRegistry')]
        [Parameter(ParameterSetName='ByAliasFromAny')]
        [Parameter(ParameterSetName='ByAliasFromRegistry')]
        [DecoratingCommentsRegistry]$Registry = $Global:ModuleAuthorDecoratingCommentsRegistry,

        [Parameter(ParameterSetName='ByValueFromBuiltIn')]
        [Parameter(ParameterSetName='ByNameFromBuiltIn')]
        [Parameter(ParameterSetName='ByAliasFromBuiltIn')]
        [switch]$BuiltInOnly,

        [Parameter(ParameterSetName='ByValueFromRegistry')]
        [Parameter(ParameterSetName='ByNameFromRegistry')]
        [Parameter(ParameterSetName='ByAliasFromRegistry')]
        [switch]$RegisteredOnly
    )

    process {
        [DecoratingCommentsBlockSchema[]]$Schemas = @()
        if ($PSCmdlet.ParameterSetName -match 'FromBuiltIn$') {
            $Schemas = [DecoratingCommentsRegistry]::BuiltInSchemas
        } elseif ($PSCmdlet.ParameterSetName -match 'FromRegistry$' -and $null -ne $Registry) {
            $Schemas = $Registry.GetEnumeratedRegisteredSchemas()
        } elseif ($PSCmdlet.ParameterSetName -match 'FromRegistry$') {
            $Message = @(
                'Called Get-DcBlockSchema with -RegisteredOnly, but the Registry parameter'
                'is null. You can use New-DecoratingCommentsRegistry to create a registry.'
                'Use the -AsGlobalRegistry to add it as a global variable or save the output'
                'of the command to a variable, then pass it to this command as a parameter.'
            ) -join ' '
            Write-Error $Message
            return
        } elseif ($null -ne $Registry) {
            $Schemas = $Registry.GetEnumeratedRegisteredSchemas()
        } else {
            $Schemas = [DecoratingCommentsRegistry]::BuiltInSchemas
        }

        if ($SchemaValue.Count -gt 0) {
            Write-Verbose "Filtering for Schema Value"
            $Schemas = $Schemas | Where-Object -FilterScript {
                ($_.GetName() -in $SchemaValue) -or 
                ($_.GetAliases().Where({$_ -in $SchemaValue}).Count -gt 0)
            }
        }

        if ($Name.Count -gt 0) {
            Write-Verbose "Filtering for Name"
            $Schemas = $Schemas | Where-Object -FilterScript {
                $_.GetName() -in $Name
            }
        }

        if ($Alias.Count -gt 0) {
            Write-Verbose "Filtering for Alias"
            $Schemas = $Schemas | Where-Object -FilterScript {
                $_.GetAliases().Where({$_ -in $Alias}).Count -gt 0
            }
        }

        if ($IncludesKeyword.Count -gt 0) {
            Write-Verbose "Filtering for Keywords"
            $Schemas = $Schemas | Where-Object -FilterScript {
                $_.GetKeywords().Where({ $_ -in $IncludesKeyword }).Count -gt 0
            }
        }

        $Schemas
    }
}
