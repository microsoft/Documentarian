# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1

class OverloadExceptionHelpInfo {
    # The full type name of the exception an overload may raise.
    [string] $Type
    # Information about when and why the overload might raise this exception.
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

        $Metadata.Add('Type', $this.Type.Trim())
        $Metadata.Add('Description', $this.Description.Trim())

        return $Metadata
    }

    OverloadExceptionHelpInfo() {}

    OverloadExceptionHelpInfo([string]$type) {
        $this.Initialize($type, '')
    }

    OverloadExceptionHelpInfo([string]$type, $description) {
        $this.Initialize($type, $description)
    }

    hidden [void] Initialize([string]$type, [string]$description) {
        $this.Type = $type
        $this.Description = $description
    }

    static [OverloadExceptionHelpInfo[]] Resolve([AstInfo]$overloadAstInfo) {
        if ($overloadAstInfo.ast -isnot [FunctionMemberAst]) {
            $Message = @(
                "Invalid AstInfo object. Expected the object's Ast property"
                'to have the type FunctionMemberAst, but it was'
                $overloadAstInfo.Ast.GetType().FullName
            ) -join ' '
            throw [System.ArgumentException]::new($Message)
        }

        $overloadHelp = $overloadAstInfo.DecoratingComment.ParsedValue

        return [OverloadExceptionHelpInfo]::Resolve($overloadHelp)
    }

    static [OverloadExceptionHelpInfo[]] Resolve([OrderedDictionary]$overloadHelp) {
        $Exceptions = $overloadHelp.Exception
        
        if ($null -eq $Exceptions) {
            return @()
        }

        return $Exceptions | ForEach-Object -Process {
            [OverloadExceptionHelpInfo]::new($_.Value, $_.Content)
        }
    }
}
