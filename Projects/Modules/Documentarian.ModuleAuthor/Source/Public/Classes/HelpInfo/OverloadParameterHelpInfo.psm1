# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Find-Ast.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Resolve-TypeName.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

class OverloadParameterHelpInfo {
    # The name of the parameter.
    [string] $Name
    # The full type name of the parameter.
    [string] $Type
    # A description of the parameter's purpose and usage.
    [string] $Description = ''

    [OrderedDictionary] ToMetadataDictionary() {
        <#
            .SYNOPSIS
            Converts an instance of the class into a dictionary.

            .DESCRIPTION
            The `ToMetadataDictionary()` method converts an instance of the
            class into an ordered dictionary so you can export the
            documentation metadata into YAML or JSON.

            This makes it easier for you to use the data-docs model, which
            separates the content of the reference documentation from its
            presentation.
        #>

        $Metadata = [OrderedDictionary]::new([System.StringComparer]::OrdinalIgnoreCase)

        $Metadata.Add('Name', $this.Name.Trim())
        $Metadata.Add('Type', $this.Type.Trim())
        $Metadata.Add('Description', $this.Description.Trim())

        return $Metadata
    }

    OverloadParameterHelpInfo() {}

    OverloadParameterHelpInfo([AstInfo]$astInfo) {
        $this.Initialize(
            $astInfo,
            [OrderedDictionary]::new([System.StringComparer]::OrdinalIgnoreCase)
        )
    }

    OverloadParameterHelpInfo([AstInfo]$astInfo, [OrderedDictionary]$overloadHelp) {
        $this.Initialize($astInfo, $overloadHelp)
    }

    OverloadParameterHelpInfo([ParameterAst]$parameterAst) {
        $this.Initialize(
            $parameterAst,
            [OrderedDictionary]::new([System.StringComparer]::OrdinalIgnoreCase)
        )
    }

    OverloadParameterHelpInfo([ParameterAst]$parameterAst, [OrderedDictionary]$overloadHelp) {
        $this.Initialize($parameterAst, $overloadHelp)
    }

    hidden [void] Initialize([AstInfo]$astInfo, [OrderedDictionary]$overloadHelp) {
        [ParameterAst]$ParameterAst = [OverloadParameterHelpInfo]::GetValidatedAst($astInfo)
        $ParameterName = $ParameterAst.Name.VariablePath.ToString()
        $ParameterType = $ParameterAst.StaticType.FullName
        $this.Name = $ParameterName
        # For custom types the parser doesn't know about, they're listed as
        # an attribute instead. We should use that as the type name if
        # available.
        if ($ParameterType -eq 'System.Object' -and $ParameterAst.Attributes.Count -gt 0) {
            $this.Type = Resolve-TypeName -TypeName $ParameterAst.Attributes[0].TypeName
        } else {
            $this.Type = $ParameterType
        }

        if ($ParameterHelp = $overloadHelp.Parameters.$ParameterName) {
            $this.Description = $ParameterHelp
        } elseif ($ParameterComment = $astInfo.DecoratingComment.MungedValue) {
            $this.Description = $ParameterComment
        } else {
            $this.Description = ''
        }
    }

    hidden [void] Initialize([ParameterAst]$parameterAst, [OrderedDictionary]$overloadHelp) {
        $ParameterName = $parameterAst.Name.VariablePath.ToString()
        $ParameterType = $parameterAst.StaticType.FullName
        $this.Name = $ParameterName
        # For custom types the parser doesn't know about, they're listed as
        # an attribute instead. We should use that as the type name if
        # available.
        if ($ParameterType -eq 'System.Object' -and $parameterAst.Attributes.Count -gt 0) {
            $this.Type = Resolve-TypeName -TypeName $parameterAst.Attributes[0].TypeName
        } else {
            $this.Type = $ParameterType
        }

        if ($ParameterHelp = $overloadHelp.Parameters.$ParameterName) {
            $this.Description = $ParameterHelp
        } else {
            $this.Description = ''
        }
    }

    hidden static [ParameterAst] GetValidatedAst([AstInfo]$astInfo) {
        [ParameterAst]$TargetAst = $astInfo.Ast -as [ParameterAst]

        if ($null -eq $TargetAst) {
            $Message = @(
                'Invalid AstInfo for OverloadParameterHelpInfo.'
                'Expected the Ast property to be a ParameterAst whose parent AST is an overload,'
                "but the AST object's type was $($astInfo.Ast.GetType().FullName)."
            ) -join ' '
            throw $Message
        } elseif ($TargetAst.Parent -isnot [FunctionMemberAst]) {
            $Message = @(
                'Invalid AstInfo for OverloadParameterHelpInfo.'
                'Expected the Ast property to be a ParameterAst whose parent AST is an overload,'
                "but the parent AST is the $($TargetAst.Parent.Name) class."
            ) -join ' '
            throw $Message
        }

        return $TargetAst
    }

    static [OverloadParameterHelpInfo[]] Resolve(
        [AstInfo]$astInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($astInfo.Ast -isnot [FunctionMemberAst]) {
            $Message = @(
                "The [OverloadParameterHelpInfo]::Resolve() method expects an AstInfo object"
                "where the Ast property is a FunctionMemberAst,"
                "but received an AstInfo object with an Ast type of"
                $astInfo.Ast.GetType().FullName
            ) -join ' '
            throw $Message
        }

        if ($astInfo.Ast.Parameters.Count -eq 0) {
            return @()
        }

        $OverloadHelp = $astInfo.DecoratingComment.ParsedValue

        $ParameterInfo = [OverloadParameterHelpInfo]::GetParametersAstInfo($astInfo, $registry)

        if ($ParameterInfo.Count -eq 0) {
            return @()
        }

        return $ParameterInfo | ForEach-Object -Process {
            if ($null -ne $OverloadHelp) {
                [OverloadParameterHelpInfo]::new($_, $OverloadHelp)
            } else {
                [OverloadParameterHelpInfo]::new($_)
            }
        }
    }

    hidden static [AstInfo[]] GetParametersAstInfo(
        [AstInfo]$overloadAstInfo,
        [DecoratingCommentsRegistry]$registry
    ) {
        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        $FindValueParameters = @{
            AstInfo                = $overloadAstInfo
            Type                   = 'ParameterAst'
            AsAstInfo              = $true
            Registry               = $registry
            ParseDecoratingComment = $true
        }
        return (Find-Ast @FindValueParameters)
    }
}
