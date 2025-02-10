# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/DecoratingComments/DecoratingCommentsBlockSchema.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsRegistry.psm1

function New-DcBlockSchema {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([DecoratingCommentsBlockSchema])]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Definition,
        [DecoratingCommentsRegistry]$Registry = $Global:ModuleAuthorDecoratingCommentsRegistry,
        [switch]$Register
    )

    process {
        if ($PSCmdlet.ShouldProcess($Definition, "Load the DecoratingCommentsSchemaBlock definition")) {
            $ModuleDefinition = [scriptblock]::create($Definition)
            $SchemaModule = New-Module -ScriptBlock $ModuleDefinition -Name $Name
            $SchemaModule | Import-Module
            . ([scriptblock]::create("using module $Name"))
            $Schema = New-Object -TypeName $Name

            if ($null -ne $Registry -and $Register) {

            } elseif ($Register) {

            }

            $Schema
        }
    }
}
