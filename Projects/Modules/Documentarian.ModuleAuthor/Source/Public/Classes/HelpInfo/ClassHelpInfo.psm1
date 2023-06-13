# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using namespace System.Management.Automation.Language
using namespace System.Collections.Specialized
using module ../AstInfo.psm1
using module ../DecoratingComments/DecoratingCommentsRegistry.psm1
using module ./BaseHelpInfo.psm1
using module ./AttributeHelpInfo.psm1
using module ./ClassMethodHelpInfo.psm1
using module ./ClassPropertyHelpInfo.psm1
using module ./ConstructorOverloadHelpInfo.psm1
using module ./ExampleHelpInfo.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/AstInfo/Resolve-TypeName.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

class ClassHelpInfo : BaseHelpInfo {
    # The name of the defined PowerShell class.
    [string] $Name = ''
    # A short description of the class.
    [string] $Synopsis = ''
    # A full description of the class, with details.
    [string] $Description = ''
    # A list of examples showing how you can use the class.
    [ExampleHelpInfo[]] $Examples = @()
    # Additional information about the class.
    [string] $Notes = ''
    # A list of full type names for the classes this class inherits from and
    # the interfaces this class implements.
    [string[]] $BaseTypes = @()
    # A list of attributes applied to the class.
    [AttributeHelpInfo[]] $Attributes = @()
    # A list of constructor overloads for the class with their documentation.
    [ConstructorOverloadHelpInfo[]] $Constructors = @()
    # A list of methods defined by the class with their documentation.
    [ClassMethodHelpInfo[]] $Methods = @()
    # A list of properties defined by the class with their documentation.
    [ClassPropertyHelpInfo[]] $Properties = @()

    # A list of links used in your documentation. Not retrieved from source.
    [OrderedDictionary] $LinkReferences = @{}

    ClassHelpInfo() {}

    ClassHelpInfo([AstInfo]$astInfo) {
        $this.Initialize($astInfo, [DecoratingCommentsRegistry]::Get())
    }

    ClassHelpInfo([AstInfo]$astInfo, [DecoratingCommentsRegistry]$registry) {
        $this.Initialize($astInfo, $registry)
    }

    hidden [void] Initialize([AstInfo]$astInfo, [DecoratingCommentsRegistry]$registry) {
        if ($null -eq $registry) {
            $registry = [DecoratingCommentsRegistry]::Get()
        }

        $ClassAst = [ClassHelpInfo]::GetValidatedAst($astInfo)
        $Help = $astInfo.DecoratingComment.ParsedValue

        $this.Name = $ClassAst.Name.Trim()
        $this.BaseTypes = $ClassAst.BaseTypes.ForEach({ Resolve-TypeName -TypeName -$_.TypeName })
        $this.Attributes = [AttributeHelpInfo]::Resolve($astInfo)
        $this.Properties = [ClassPropertyHelpInfo]::Resolve($astInfo, $registry)
        $this.Constructors = [ConstructorOverloadHelpInfo]::Resolve($astInfo, $registry)
        $this.Methods = [ClassMethodHelpInfo]::Resolve($astInfo, $registry)

        if ($Help.IsUsable()) {
            if ($HelpSynopsis = $Help.GetKeywordEntry('Synopsis')) {
                $this.Synopsis = $HelpSynopsis
            }
            if ($HelpDescription = $Help.GetKeywordEntry('Description')) {
                $this.Description = $HelpDescription
            }
            $this.Examples = [ExampleHelpInfo]::Resolve($Help)

            if ($HelpNotes = $Help.GetKeywordEntry('Notes')) {
                $this.Notes = $HelpNotes
            }
        } elseif ($SynopsisHelp = $astInfo.DecoratingComment.MungedValue) {
            $this.Synopsis = $SynopsisHelp
        }
    }

    hidden static [TypeDefinitionAst] GetValidatedAst([AstInfo] $astInfo) {
        $TargetAst = $astInfo.Ast -as [TypeDefinitionAst]

        if ($null -eq $TargetAst) {
            $Message = @(
                'Invalid AstInfo for ClassHelpInfo.'
                'Expected the Ast property to be a TypeDefinitionAst for a class,'
                "but the AST object's type was $($astInfo.Ast.GetType().FullName)."
            ) -join ' '
            throw $Message
        } elseif (-not $TargetAst.IsClass) {
            $Message = @(
                'Invalid AstInfo for ClassHelpInfo.'
                'Expected the Ast property to be a TypeDefinitionAst for a class,'
                "but the AST is for the $($TargetAst.Name) enum."
            ) -join ' '
            throw $Message
        }

        return $TargetAst
    }
}
