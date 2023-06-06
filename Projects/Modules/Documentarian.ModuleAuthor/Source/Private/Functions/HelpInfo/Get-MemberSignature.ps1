# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language

function Get-MemberSignature {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [FunctionMemberAst[]]$MemberAst,
        [ValidateSet('Full', 'TypeOnly')]
        [string]$Mode = 'Full'
    )

    begin {}

    process {
        foreach ($Member in $MemberAst) {
            $Name = $Member.Name
            $Parameters = switch ($Mode) {
                'TypeOnly' {
                    $ParameterTypes = $Member.Parameters | ForEach-Object {
                        $Type = $_.StaticType.FullName

                        # For custom types the parser doesn't know about, they're listed as an
                        # attribute instead. We should use that as the type name if available.
                        if ($Type -eq 'System.Object' -and $_.Attributes.Count -gt 0) {
                            $Type = Resolve-TypeName -TypeName $_.Attributes[0].TypeName
                        }

                        $Type
                    }
                    $ParameterTypes -join ', '
                }
                Default {
                    $Member.Parameters.Extent.Text -join ', '
                }
            }

            "$Name($Parameters)"
        }
    }

    end {}
}
