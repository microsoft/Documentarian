# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Private/Functions/Test-DevXIsAstType.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

Function Get-AstType {
  <#
    .SYNOPSIS
    Function synopsis.
  #>

  [CmdletBinding(DefaultParameterSetName = 'ByPattern')]
  [OutputType([Type])]
  Param(
    [Parameter(
      Mandatory,
      ParameterSetName = 'ByPattern',
      HelpMessage = 'Specify a valid regex pattern to match in the list of AST types'
    )]
    [string]
    $Pattern,

    [Parameter(
      Mandatory,
      ParameterSetName = 'ByName',
      HelpMessage = 'Specify a name to look for in the list of AST types; the "Ast" suffix is optional'
    )]
    [string[]]
    $Name
  )

  begin {
    # ignore exceptions getting the types in an assembly
    $types = [System.AppDomain]::CurrentDomain.GetAssemblies()
    | ForEach-Object -Process { try { $_.GetTypes() } catch {} }
    | Where-Object -FilterScript {
      Test-DevXIsAstType -Type $_
    }
  }

  process {
    if (-not [string]::IsNullOrEmpty($Pattern)) {
      $types | Where-Object -FilterScript {
        $_.Name -match $Pattern
      }
    } elseif ($Name.Count -gt 0) {
      foreach ($n in $Name) {
        $types | Where-Object -FilterScript {
          $_.Name -in @($n, "${n}Ast")
        }
      }
    } else {
      $types
    }
  }

  end {

  }
}
