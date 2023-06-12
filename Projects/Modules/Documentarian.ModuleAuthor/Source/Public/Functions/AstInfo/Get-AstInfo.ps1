# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/AstInfo.psm1
using module ../../Classes/DecoratingComments/DecoratingCommentsRegistry.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/DecoratingComments/New-DecoratingCommentsRegistry.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

Function Get-AstInfo {
    <#
        .SYNOPSIS
        Gets an AstInfo object from a script block, file, or text.
    #>

    [CmdletBinding(DefaultParameterSetName = 'FromPath')]
    [OutputType([AstInfo])]
    param(
        [Parameter(Mandatory, ParameterSetName = 'FromPath')]
        [ValidatePowerShellScriptPath()]
        [string[]]$Path,
        [Parameter(Mandatory, ParameterSetName = 'FromScriptBlock')]
        [scriptblock[]]$ScriptBlock,
        [Parameter(Mandatory, ParameterSetName = 'FromInputText')]
        [ValidateNotNullOrEmpty()]
        [string[]]$Text,
        [Parameter(Mandatory, ParameterSetName = 'FromTargetAst')]
        [Ast[]]$TargetAst,
        [Parameter(ParameterSetName = 'FromTargetAst')]
        [Token[]]$Token,
        [DecoratingCommentsRegistry]$Registry = $Global:ModuleAuthorDecoratingCommentsRegistry,
        [switch]$ParseDecoratingComment
    )

    begin {}

    process {
        if ($ParseDecoratingComment) {
            if ($null -eq $Registry) {
                $Message = @(
                    'Specified -ParseDecoratingComment without passing a value for the Registry'
                    'parameter and without the global registry initialized. Creating a default'
                    'DecoratingCommentsRegistry to use for this command.'
                ) -join ' '
                Write-Verbose $Message
                $Registry = New-DecoratingCommentsRegistry
            }
        } elseif ($PSBoundParameters.ContainsKey('Registry')) {
            $Message = @(
                'Explititly specified -Regisistry without -ParseDecoratingComment.'
                'Parsing any discovered decorating comments with the passed Registry.'
            ) -join ' '
            Write-Verbose $Message
            $ParseDecoratingComment = $true
        }
        switch ($PSCmdlet.ParameterSetName) {
            'FromPath' {
                $Path | ForEach-Object -Process {
                    if ($ParseDecoratingComment) {
                        [AstInfo]::New($_, $Registry)
                    } else {
                        [AstInfo]::New($_)
                    }
                }
            }
            'FromScriptBlock' {
                foreach ($Block in $ScriptBlock) {
                    if ($ParseDecoratingComment) {
                        [AstInfo]::New($Block, $Registry)
                    } else {
                        [AstInfo]::New($Block)
                    }
                }
            }
            'FromInputText' {
                foreach ($Block in $Text) {
                    if ($ParseDecoratingComment) {
                        [AstInfo]::New([ScriptBlock]::Create($Block), $Registry)
                    } else {
                        [AstInfo]::New([ScriptBlock]::Create($Block))
                    }
                }
            }
            'FromTargetAst' {
                foreach ($Target in $TargetAst) {
                    if ($ParseDecoratingComment -and ($Token.Count -gt 0)) {
                        [AstInfo]::New($Target, $Token, $Registry)
                    } elseif ($ParseDecoratingComment) {
                        [AstInfo]::New($Target, $Registry)
                    } elseif ($Token.Count -gt 0) {
                        [AstInfo]::New($Target, $Token)
                    } else {
                        [AstInfo]::New($Target)
                    }
                }
            }
        }
    }

    end {}
}
