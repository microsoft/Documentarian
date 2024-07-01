# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Private/Functions/Get-AstType.ps1"
  Resolve-Path -Path "$SourceFolder/Private/Functions/Test-DevXIsAstType.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

class DevXAstTypeTransformAttribute : ArgumentTransformationAttribute {
  <#
    .SYNOPSIS
    Transforms input into a valid AST type.

    .DESCRIPTION
    This attribute transforms input into a valid AST type. The input can be a type object or a
    string representing the type name. The type must be in the
    `System.Management.Automation.Language` namespace and must end in `Ast`. If the input is not a
    valid AST type, an exception is thrown.
  #>

  #region Static properties
  #endregion Static properties

  #region Static methods
  #endregion Static methods

  #region Instance properties

  [object] Transform([EngineIntrinsics]$engineIntrinsics, [System.Object]$inputData) {
    $outputData = switch ($inputData) {
      { $_ -is [System.Type] } {
        if (Test-DevXIsAstType -Type $_) {
          $_
        } else {
          $errorMessage = @(
            "Specified type '$($_.GetType().FullName)' is not an AST type;"
            "valid types must be in the 'System.Management.Automation.Language' namespace"
            "and must end in 'Ast'"
            'You can use Get-AstType to discover valid AST Types'
            'and to pass for this argument.'
          ) -join ' '
          throw [ArgumentTransformationMetadataException]::New(
            $errorMessage
          )
        }
      }
      { $_ -is [string] } {
        try {
          Get-AstType -Name $_ -ErrorAction Stop
        } catch {
          $errorMessage = @(
            "Specified type name '$_' is not an AST type;"
            "valid types must be in the 'System.Management.Automation.Language' namespace"
            "and must end in 'Ast'"
            'You can use Get-AstType to discover valid AST Types'
            'and to pass for this argument.'
          ) -join ' '
          throw [ArgumentTransformationMetadataException]::New(
            $errorMessage
          )
        }
      }
      default {
        $errorMessage = @(
          "Could not convert input ($_)"
          "of type '$($_.GetType().FullName)'"
          'to a valid AST Type.'
          'Specify the type itself or its name as a string.'
          'You can use Get-AstType to discover valid AST Types'
          'and to pass for this argument.'
        ) -join ' '
        throw [ArgumentTransformationMetadataException]::New(
          $errorMessage
        )
      }
    }

    return $outputData
  }

  #endregion Instance properties

  #region Instance methods
  #endregion Instance methods

  #region Constructors
  #endregion Constructors
}
