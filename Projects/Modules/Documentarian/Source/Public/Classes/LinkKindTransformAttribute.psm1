# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation
using module ../Enums/LinkKind.psm1

class LinkKindTransformAttribute : ArgumentTransformationAttribute {
  [object] Transform([EngineIntrinsics]$engineIntrinsics, [System.Object]$inputData) {
    $ValidEnums = [LinkKind].GetEnumNames()
    $outputData = switch ($inputData) {
      { $_ -is [LinkKind] } { $_ }

      { $_ -is [string] } {
        if ($_ -in $ValidEnums) {
          $_
        } elseif ($Matching = $ValidEnums -like $_) {
          $Matching
        } else {
          $Message = @(
            "Specified kind '$_' couldn't resolve to any LinkKind enums;"
            'values must be a specific LinkKind or a wildcard expression'
            "(containing '*', '?', or '[]') matching one or more LinkKind."
            "Valid LinkKind enums are: $ValidEnums"
          ) -join ' '
          throw [ArgumentTransformationMetadataException]::New(
            $Message
          )
        }
      }
      default {
        $Message = @(
          "Could not convert input ($_) of type '$($_.GetType().FullName)' to a LinkKind."
          "Specify a valid LinkKind or a wildcard expression (containing '*', '?', or '[]')"
          "matching one or more LinkKind enums. Valid LinkKind enums are: $ValidEnums"
        ) -join ' '
        throw [ArgumentTransformationMetadataException]::New(
          $Message
        )
      }
    }

    return $outputData
  }
}
