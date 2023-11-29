# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ./BaseHelpInfo.psm1

class OverloadExceptionHelpInfo : BaseHelpInfo {
    # The full type name of the exception an overload may raise.
    [string] $Type
    # Information about when and why the overload might raise this exception.
    [string] $Description = ''

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

    static [OverloadExceptionHelpInfo[]] Resolve([DecoratingCommentsBlockParsed]$overloadHelp) {
        $Exceptions = $overloadHelp.Exception
        
        if ($null -eq $Exceptions) {
            return @()
        }

        return $Exceptions | ForEach-Object -Process {
            [OverloadExceptionHelpInfo]::new($_.Value, $_.Content)
        }
    }

    hidden static [OrderedDictionary] AddYamlFormatting([OrderedDictionary]$metadata) {
        $metadata.Type = $metadata.Type | yayaml\Add-YamlFormat -ScalarStyle Plain -PassThru
        $metadata.Description = $metadata.Description | yayaml\Add-YamlFormat -ScalarStyle Literal -PassThru

        return $metadata
    }
}
