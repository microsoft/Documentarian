# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using module ../../../Public/Classes/HelpInfo/OverloadParameterHelpInfo.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Private/Functions/Comments/Resolve-CommentDecoration.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Resolve-OverloadParameterHelpInfo {
    [CmdletBinding(DefaultParameterSetName = 'ByParameter')]
    [OutputType([OverloadParameterHelpInfo[]])]
    param (
        [Parameter(Mandatory, ParameterSetName = 'ByParameter')]
        [ParameterAst[]]$Parameter,
        [Parameter(Mandatory, ParameterSetName = 'ByMethod')]
        [FunctionMemberAst]$Method,
        [Parameter(Mandatory)]
        [Token[]]$Tokens
    )

    begin {
    }

    process {
        if ($Method) {
            $Parameter = $Method.Parameters
        }
        foreach ($P in $Parameter) {
            $Info = [OverloadParameterHelpInfo]::new()
            $Name = $P.Name.VariablePath.ToString()

            # For custom types the parser doesn't know about, they're listed as
            # an attribute instead. We should use that as the type name if
            # available.
            $Type = $P.StaticType.FullName
            if ($Type -eq 'System.Object' -and $P.Attributes.Count -gt 0) {
                $Type = Resolve-TypeName -TypeName $P.Attributes[0].TypeName
            }

            $Description = ''
            if ($MethodBodyHelp = $P.Parent.Body.GetHelpContent()) {
                if ($ParameterHelp = $MethodBodyHelp.Parameters.($Name.ToUpper())) {
                    $Description = $ParameterHelp
                }
            }

            $ParentString = $P.Parent.Extent.ToString()
            $ParameterString = $P.Extent.ToString()
            $ParameterOnNewLine = $ParentString -match "\r?\n$([regex]::Escape($ParameterString))"

            if ([string]::IsNullOrEmpty($Description) -and $ParameterOnNewLine) {
                $ResolutionParameters = @{
                    StatementFirstLine = $Parameter.Extent.StartLineNumber
                    Tokens             = $Tokens
                }
                $Description = Resolve-CommentDecoration @ResolutionParameters
            }

            $Info.Name = $Name
            $Info.Type = $Type
            if (![string]::isNullOrEmpty($Description)) {
                $Info.Description = $Description
            }

            $Info
        }
    }
}
