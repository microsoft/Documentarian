# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/SourceFile.psm1
using module ../../Classes/SourceReference.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Private/Functions/Find-Ast.ps1"
  Resolve-Path -Path "$SourceFolder/Private/Functions/Get-Ast.ps1"
  Resolve-Path -Path "$SourceFolder/Private/Functions/New-SourceReference.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/General/Get-SourceFolder.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/General/Resolve-SourceFolderPath.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Resolve-SourceDependency {
  <#
    .SYNOPSIS
  #>

  [CmdletBinding(DefaultParameterSetName = 'ByPath')]
  [OutputType([SourceReference])]
  param(
    [Parameter()]
    [SourceFile[]]
    $SourceFile,

    [Parameter()]
    [parameter(Mandatory, ParameterSetName = 'ByName')]
    [string[]]
    $Name,

    [Parameter()]
    [parameter(Mandatory, ParameterSetName = 'ByPath')]
    [string[]]
    $Path
  )

  begin {
    $TypeDefinitionSources     = [SourceFile[]]@()
    $FunctionDefinitionSources = [SourceFile[]]@()

    $TypeReferenceAsts = @(
      'TypeExpressionAst'
      'TypeConstraintAst'
      'AttributeAst'
    )
    $FunctionReferenceAsts = @(
      'CommandAst'
    )
  }

  process {
    if ($Path) {
      $Path = Resolve-Path $Path -ErrorAction Stop

      $sourceFolder = Resolve-SourceFolderPath -Path $Path
      | Select-Object -Unique
      | Where-Object -FilterScript {
        $_.Category -notin @('Format', 'Type', 'Task')
      }

      Write-Verbose "Searching for source files in '$SourceFolder'"
      $SourceFile = $sourceFolder | ForEach-Object -Process {
        Get-SourceFolder -SourceFolder $_
      } | Select-Object -ExpandProperty SourceFiles

      Write-Verbose 'Analyzing path input path for source files to resolve'
      $SourceToResolve = Get-Item -Path $Path | ForEach-Object -Process {
        $Item = $_
        if ($Item -is [System.IO.FileInfo]) {
          $SourceFile | Where-Object -FilterScript {
            $_.FileInfo.FullName -eq $Item.FullName
          }
        } else {
          $SourceFile | Where-Object -FilterScript {
            $_.FileInfo.FullName -match [regex]::Escape($Path)
          }
        }
      } | Where-Object -FilterScript {
        $_.Category.ToString() -notin @('Format', 'Type', 'Task')
      }
    } elseif ($Name) {
      if (-not $SourceFile) {
        Write-Verbose "No source files provided; Searching for source files in './Source'"
        Write-Verbose 'To search a specific path, use the **Path** parameter'
        $SourceFile = Get-SourceFolder
        | Select-Object -ExpandProperty SourceFiles
      }

      Write-Verbose 'Resolving named source files'
      $SourceToResolve = $SourceFile | Where-Object -FilterScript {
        $_.FileInfo.BaseName -in $Name
      }
    }

    Write-Verbose 'Analyzing source files for type and function definitions'
    $SourceFile | ForEach-Object -Process {
      if ($_.Category.ToString() -eq 'Function') {
        $FunctionDefinitionSources += $_
      } elseif ($_.Category.ToString() -notin @('Format', 'Type', 'Task')) {
        $TypeDefinitionSources += $_
      }
    }

    foreach ($Source in $SourceToResolve) {
      if ($Source.FileInfo.Extension -notin @('.ps1', '.psm1')) {
        Write-Verbose "Skipping source file '$($Source.FileInfo.FullName)' because it is not a PowerShell script file"
        continue
      }

      $SourceName  = $Source.FileInfo.BaseName
      Write-Verbose "Resolving dependencies in '$($Source.FileInfo.FullName)'"
      $DevXAstInfo = Get-Ast -Path $Source.FileInfo.FullName
      $References  = [SourceFile[]]@()

      Find-Ast -DevXAstInfo $DevXAstInfo -Type $TypeReferenceAsts -Recurse
      | ForEach-Object -Process {
        $TypeName = $_.TypeName.FullName.Trim('[]')
        $TypeDefinitionSources | ForEach-Object -Process {
          $Name = $_.FileInfo.BaseName
          if ($Name -eq $TypeName -and $Name -notin $References.FileInfo.BaseName) {
            Write-Verbose "Discovered dependency for $SourceName on $Name"
            $References += $_
          }
        }
      }

      Find-Ast -DevXAstInfo $DevXAstInfo -Type $FunctionReferenceAsts -Recurse
      | ForEach-Object -Process {
        $CommandName = $_.GetCommandName()
        $FunctionDefinitionSources | ForEach-Object -Process {
          $Name = $_.FileInfo.BaseName
          if ($Name -eq $CommandName -and $Name -notin $References.FileInfo.BaseName) {
            Write-Verbose "Discovered dependency for $SourceName on $Name"
            $References += $_
          }
        }
      }

      New-SourceReference -SourceFile $Source -Reference $References
    }
  }

  end {

  }
}
