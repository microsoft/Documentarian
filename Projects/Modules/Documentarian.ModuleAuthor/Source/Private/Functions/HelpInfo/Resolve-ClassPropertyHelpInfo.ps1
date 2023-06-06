# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using module ../../../Public/Classes/HelpInfo/ClassPropertyHelpInfo.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Resolve-AttributeHelpInfo.ps1"
  Resolve-Path -Path "$SourceFolder/Private/Functions/HelpInfo/Resolve-ClassPropertyHelpText.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Resolve-ClassPropertyHelpInfo {
    [CmdletBinding(DefaultParameterSetName = 'FromProperties')]
    [OutputType([ClassPropertyHelpInfo[]])]
    param (
        [parameter(Mandatory, ParameterSetName = 'FromClass')]
        [TypeDefinitionAst]$Class,
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'FromProperties')]
        [PropertyMemberAst[]]$Property,
        [Parameter()]
        [CommentHelpInfo]$Help,
        [Parameter()]
        [Token[]]$Tokens
    )

    process {
        if ($null -ne $Class) {
            $Property = $Class.Members | Where-Object -FilterScript {
                $_.GetType().Name -eq 'PropertyMemberAst'
            }
            if ($Property.Count -eq 0) {
                return @()
            }
        }

        foreach ($P in $Property) {
            $Info = [ClassPropertyHelpInfo]::new()
            $Info.Name = $P.Name
            $Info.Type = Resolve-TypeName -TypeName $P.PropertyType.TypeName
            $Info.Attributes = Resolve-AttributeHelpInfo -Attribute $P.Attributes
            $Info.IsHidden = $P.IsHidden
            $Info.IsStatic = $P.IsStatic
            if ($null -ne $P.InitialValue) {
                $Info.InitialValue = $P.InitialValue.Extent.ToString()
            }
            $Resolving = @{
                Property = $P
                Info     = $Info
            }
            if ($null -ne $Help) {
                $Resolving.Help = $Help
            }
            if ($null -ne $Tokens) {
                $Resolving.Tokens = $Tokens
            }
            Resolve-ClassPropertyHelpText @Resolving

            $Info
        }
    }
}
