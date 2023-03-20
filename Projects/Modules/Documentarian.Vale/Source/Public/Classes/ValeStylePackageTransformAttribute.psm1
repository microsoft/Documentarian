# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation
using module ../Enums/ValeKnownStylePackage.psm1

class ValeStylePackageTransformAttribute : ArgumentTransformationAttribute {
    [object] Transform([EngineIntrinsics]$engineIntrinsics, [System.Object]$inputData) {
        $ValidEnums = [ValeKnownStylePackage].GetEnumNames()
        $outputData = switch ($inputData) {
            { $_ -in $ValidEnums } {
                switch ([ValeKnownStylePackage]$_) {
                    Alex {
                        'alex'
                        continue
                    }
                    JobLint {
                        'Joblint'
                        continue
                    }
                    PowerShellDocs {
                        'https://microsoft.github.io/Documentarian/packages/vale/PowerShell-Docs.zip'
                        continue
                    }
                    ProseLint {
                        'proselint'
                        continue
                    }
                    WriteGood {
                        'write-good'
                        continue
                    }
                    default { $_.ToString() }
                }
                continue
            }

            { $_ -is [string] } { $_ }

            default {
                $Message = @(
                    "Could not convert input ($_) of type '$($_.GetType().FullName)' to a string."
                ) -join ' '
                throw [ArgumentTransformationMetadataException]::New(
                    $Message
                )
            }
        }

        return $outputData
    }
}
