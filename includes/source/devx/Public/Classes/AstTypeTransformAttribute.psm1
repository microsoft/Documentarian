# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Private/Functions/Test-IsAstType.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/Ast/Get-AstType.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

class AstTypeTransformAttribute : ArgumentTransformationAttribute {
  [object] Transform([EngineIntrinsics]$engineIntrinsics, [System.Object]$inputData) {
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
          throw [ArgumentTransformationMetadataException]::New(
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
          throw [ArgumentTransformationMetadataException]::New(
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
        throw [ArgumentTransformationMetadataException]::New(
          $Message
        )
      }
    }

    return $outputData
  }
}
