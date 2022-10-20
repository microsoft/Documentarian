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
  Resolve-Path -Path "$SourceFolder/Private/Functions/New-SourceReference.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/Ast/Find-Ast.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/Ast/Get-Ast.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/General/Get-SourceFolder.ps1"
  Resolve-Path -Path "$SourceFolder/Public/Functions/General/Resolve-SourceFolderPath.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Resolve-SourceDependency {
  [CmdletBinding(DefaultParameterSetName = 'ByPath')]
  [OutputType([SourceReference])]
  param(
    [SourceFile[]]$SourceFile,

    [parameter(Mandatory, ParameterSetName = 'ByName')]
    [string[]]$Name,
    [parameter(Mandatory, ParameterSetName = 'ByPath')]
    [string[]]$Path
  )

  begin {
    $TypeDefinitionSources = [SourceFile[]]@()
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

      $SourceFolder = Resolve-SourceFolderPath -Path $Path | Select-Object -Unique

      Write-Verbose "Searching for source files in '$SourceFolder'"
      $SourceFile = $SourceFolder | ForEach-Object -Process {
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
      }
    } elseif ($Name) {
      if (!$SourceFile) {
        Write-Verbose "No source files provided; Searching for source files in './Source'"
        Write-Verbose 'To search a specific path, use the **Path** parameter'
        $SourceFile = Get-SourceFolder | Select-Object -ExpandProperty SourceFiles
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
      } else {
        $TypeDefinitionSources += $_
      }
    }

    foreach ($Source in $SourceToResolve) {
      $SourceName = $Source.FileInfo.BaseName
      Write-Verbose "Resolving dependencies '$SourceName' in '$($Source.FileInfo.FullName)'"
      $AstInfo = Get-Ast -Path $Source.FileInfo.FullName
      $References = [SourceFile[]]@()

      Find-Ast -AstInfo $AstInfo -Type $TypeReferenceAsts -Recurse
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

      Find-Ast -AstInfo $AstInfo -Type $FunctionReferenceAsts -Recurse
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
}
