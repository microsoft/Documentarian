# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Get-AstType.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Test-IsAstType.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

class AstTypeTransformAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform(
        [System.Management.Automation.EngineIntrinsics]$engineIntrinsics,
        [System.Object]$inputData
    ) {
        <#
            .SYNOPSIS
            Transforms a type name or type object into a valid AST type object.

            .DESCRIPTION
            Transforms a type name or type object into a valid AST type object.

            If the input object is **System.Type**, the method validates that it's an
            AST type. If it's an AST type, the method returns it. If it isn't, the method throws an
            exception.

            If the input object is a **System.String**, the method validates that it's a valid AST
            type name. If it's the name of an AST type, the method returns the named type. If it
            isn't, the method throws an exception.

            If the input object is neither a **System.Type** nor a **System.String**, the method
            throws an exception.
        #>

        $outputData = switch ($inputData) {
            { $_ -is [System.Type] } {
                if (Test-IsAstType -Type $_) {
                    $_
                } else {
                    $Message = @(
                        "Specified type '$($_.GetType().FullName)' is not an AST type;"
                        "valid types must be in the 'System.Management.Automation.Language' namespace"
                        "and must end in 'Ast'"
                        'You can use Get-AstType to discover valid AST Types'
                        'and to pass for this argument.'
                    ) -join ' '
                    throw [System.Management.Automation.ArgumentTransformationMetadataException]::New(
                        $Message
                    )
                }
            }
            { $_ -is [string] } {
                try {
                    Get-AstType -Name $_ -ErrorAction Stop
                } catch {
                    $Message = @(
                        "Specified type name '$_' is not an AST type;"
                        "valid types must be in the 'System.Management.Automation.Language' namespace"
                        "and must end in 'Ast'"
                        'You can use Get-AstType to discover valid AST Types'
                        'and to pass for this argument.'
                    ) -join ' '
                    throw [System.Management.Automation.ArgumentTransformationMetadataException]::New(
                        $Message
                    )
                }
            }
            default {
                $Message = @(
                    "Could not convert input ($_)"
                    "of type '$($_.GetType().FullName)'"
                    'to a valid AST Type.'
                    'Specify the type itself or its name as a string.'
                    'You can use Get-AstType to discover valid AST Types'
                    'and to pass for this argument.'
                ) -join ' '
                throw [System.Management.Automation.ArgumentTransformationMetadataException]::New(
                    $Message
                )
            }
        }

        return $outputData
    }
}
