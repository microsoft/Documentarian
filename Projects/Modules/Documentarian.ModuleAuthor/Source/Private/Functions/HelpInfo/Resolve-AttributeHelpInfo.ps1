# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using module ../../../Public/Classes/HelpInfo/AttributeHelpInfo.psm1

function Resolve-AttributeHelpInfo {
    [CmdletBinding()]
    [OutputType([AttributeHelpInfo[]])]
    param(
        # System.Management.Automation.Language.AttributeAst
        [AttributeAst[]]
        $Attribute
    )

    process {
        if ($Attribute.Count -eq 0) {
            return @()
        }
        foreach ($A in $Attribute) {
            [AttributeHelpInfo]@{
                Type       = Resolve-TypeName -TypeName $A.TypeName
                Definition = $A.Extent.ToString()
            }
        }
    }
}
