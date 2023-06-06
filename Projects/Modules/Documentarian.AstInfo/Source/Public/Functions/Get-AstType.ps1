# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/Test-IsAstType.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

Function Get-AstType {
    <#
        .SYNOPSIS
        Gets AST types from the current AppDomain with optional filters.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByPattern')]
    [OutputType([System.Type[]])]
    Param(
        [Parameter(
            Mandatory,
            ParameterSetName = 'ByPattern',
            HelpMessage = 'Specify a valid regex pattern to match in the list of AST types'
        )]
        [string]$Pattern,

        [Parameter(
            Mandatory,
            ParameterSetName = 'ByName',
            HelpMessage = 'Specify a name to look for in the list of AST types; the "Ast" suffix is optional'
        )]
        [string[]]$Name
    )

    begin {
        # ignore exceptions getting the types in an assembly
        $Types = [System.AppDomain]::CurrentDomain.GetAssemblies() |
        ForEach-Object -Process { try { $_.GetTypes() } catch {} } |
        Where-Object -FilterScript {
            Test-IsAstType -Type $_
        }
    }

    process {
        if (![string]::isNullOrEmpty($Pattern)) {
            $Types | Where-Object -Property Name -Match $Pattern
        } elseif ($Name.Count -gt 0) {
            foreach ($N in $Name) {
                $Types | Where-Object -Property Name -In @($N, "${N}Ast")
            }
        } else {
            $Types
        }
    }

    end {}
}
