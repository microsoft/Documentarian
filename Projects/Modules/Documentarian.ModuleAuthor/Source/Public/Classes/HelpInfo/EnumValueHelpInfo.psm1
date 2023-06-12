# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1

class EnumValueHelpInfo {
    # The value's label.
    [string] $Label
    # The numerical value.
    [int] $Value = 0
    # The Markdown text explaining the value's purpose.
    [string] $Description = ''
    # Whether the value is explicitly defined in the enum.
    [bool] $HasExplicitValue = $false

    [string] ToString() {
        <#
            .SYNOPSIS
            Converts an instance of **EnumValueHelpInfo** into a string.

            .DESCRIPTION
            The `ToString()` method converts an instance of the
            **EnumValueHelpInfo** class into a string with the instance's
            **Label** and **Value** on the first line,followed by the
            instance's **Description on the next line.

            .EXAMPLE
            ```powershell
            $enumValue = [EnumValueHelpInfo]@{
                Label       = 'NoCache'
                Value       = 4
                Description = 'Indicates the service should ignore caching.'
            }
            $enumValue.ToString()
            ```

            ```output
            NoCache (4):
            Indicates the service should ignore caching.
            ```
        #>

        return "$($this.Label) ($($this.Value)):`n$($this.Description)"
    }

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

        $Metadata.Add('Label', $this.Label.Trim())
        $Metadata.Add('Value', $this.Value)
        $Metadata.Add('Description', $this.Description.Trim())

        return $Metadata
    }

    EnumValueHelpInfo() {
        $this.Label = ''
        $this.Value = 0
        $this.Description = ''
        $this.HasExplicitValue = $false
    }

    EnumValueHelpInfo([AstInfo]$astInfo) {
        $this.Initialize($astInfo, [OrderedDictionary]::new([System.StringComparer]::OrdinalIgnoreCase))
    }

    EnumValueHelpInfo([AstInfo]$astInfo, [OrderedDictionary]$enumHelp) {
        $this.Initialize($astInfo, $enumHelp)
    }

    hidden [void] Initialize([AstInfo]$astInfo, [OrderedDictionary]$enumHelp) {
        [MemberAst]$EnumValueAst = [EnumValueHelpInfo]::GetValidatedAst($astInfo)
        $LabelName = $EnumValueAst.Name.Trim()
        $this.Label = $LabelName
        $this.Value = $EnumValueAst.InitialValue.Value
        $this.HasExplicitValue = $null -ne $EnumValueAst.InitialValue
        $LabelHelpFromEnum = $enumHelp.Label | Where-Object -FilterScript {
            $_.Value -eq $LabelName
        } | Select-Object -First 1 | ForEach-Object -Process { $_.Content }
        $this.Description = if ($LabelHelpFromEnum) {
            $LabelHelpFromEnum
        } elseif ($LabelHelp = $astInfo.DecoratingComment.MungedValue) {
             $LabelHelp
        } else { '' }
    }

    hidden static [MemberAst] GetValidatedAst([AstInfo]$astInfo) {
        [MemberAst]$TargetAst = $astInfo.Ast -as [MemberAst]

        if ($null -eq $TargetAst) {
            $Message = @(
                'Invalid AstInfo for EnumValueHelpInfo.'
                'Expected the Ast property to be a MemberAst whose parent AST is an enum,'
                "but the AST object's type was $($astInfo.Ast.GetType().FullName)."
            ) -join ' '
            throw $Message
        } elseif (-not $TargetAst.Parent.IsEnum) {
            $Message = @(
                'Invalid AstInfo for EnumValueHelpInfo.'
                'Expected the Ast property to be a MemberAst whose parent AST is an enum,'
                "but the parent AST is the $($TargetAst.Parent.Name) class."
            ) -join ' '
            throw $Message
        }

        return $TargetAst
    }
}
