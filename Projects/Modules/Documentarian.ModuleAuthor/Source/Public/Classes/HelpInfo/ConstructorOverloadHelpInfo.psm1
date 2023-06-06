# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Collections.Specialized
using module ./OverloadHelpInfo.psm1
using module ./OverloadSignature.psm1

class ConstructorOverloadHelpInfo : OverloadHelpInfo {
    static [ConstructorOverloadHelpInfo] GetDefaultConstructor([string]$ClassName) {
        return [ConstructorOverloadHelpInfo]@{
            Signature = [OverloadSignature]@{
                Full     = "$ClassName()"
                TypeOnly = "$ClassName()"
            }
            Synopsis  = 'Creates an instance of the class with default values for every property.'
        }
    }
}
