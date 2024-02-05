# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/DecoratingComments/DecoratingCommentsBlockSchema.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsRegistry.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
    $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
    Resolve-Path -Path "$SourceFolder/Public/Functions/DecoratingComments/Get-DcBlockSchema.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
    . $RequiredFunction
}

#endregion RequiredFunctions

function Register-DcBlockSchema {
    [CmdletBinding(DefaultParameterSetName='ByName')]
    [OutputType([DecoratingCommentsBlockSchema[]])]
    param(
        [Parameter(Mandatory, ParameterSetName='BySchemaValue')]
        [string[]]
        $SchemaValue,

        [Parameter(Mandatory, ParameterSetName='ByName')]
        [string[]]
        $Name,

        [Parameter(Mandatory, ParameterSetName='ByAlias')]
        [string[]]
        $Alias,

        [Parameter(Mandatory, ParameterSetName='BySchemaObject')]
        [DecoratingCommentsBlockSchema[]]
        $Schema,

        [DecoratingCommentsRegistry]
        $Registry = $Global:ModuleAuthorDecoratingCommentsRegistry,

        [switch]
        $Force,

        [switch]
        $PassThru
    )

    process {
        if ($null -eq $Registry) {
            $Message = @(
                'Called Register-DcBlockSchema, but the Registry parameter is null.'
                'You can use New-DecoratingCommentsRegistry to create a registry object,'
                'or Initialize-DcGlobalRegistry to create a global registry that the'
                "functions in this module will use when you don't specify the Registry parameter."
            ) -join ' '
            Write-Error $Message
            return
        }

        if ($null -eq $Schema) {
            $GetParameters = @{
                Registry    = $Registry
                BuiltInOnly = $true
            }
            if ($SchemaValue.Count -gt 0) {
                $GetParameters.SchemaValue = $SchemaValue
            }
            if ($Name.Count -gt 0) {
                $GetParameters.Name = $Name
            }
            if ($Alias.Count -gt 0) {
                $GetParameters.Alias = $Alias
            }

            $Schema = Get-DcBlockSchema @GetParameters

            if ($Schema.Count -eq 0) {
                $W = 'Unable to resolve any DecoratingCommentBlockSchema objects from parameters.'
                Write-Warning $W
            }
        }

        if ($Schema.Count -gt 0) {
            $Registry.RegisterSchemas($Schema, $Force, $PassThru)
        }
    }
}
