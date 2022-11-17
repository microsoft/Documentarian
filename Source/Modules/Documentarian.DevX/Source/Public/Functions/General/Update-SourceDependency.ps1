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
  Resolve-Path -Path "$SourceFolder/Public/Functions/General/Resolve-SourceDependency.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Update-SourceDependency {
  [CmdletBinding(DefaultParameterSetName = 'ByPath')]
  [OutputType([SourceReference])]
  param(
    [SourceFile[]]$SourceFile,

    [parameter(Mandatory, ParameterSetName = 'ByName')]
    [string[]]$Name,
    [parameter(Mandatory, ParameterSetName = 'ByPath')]
    [string[]]$Path
  )

  process {
    $ResolvedDependencies = Resolve-SourceDependency @PSBoundParameters
    $ResolvedDependencies | ForEach-Object -Process {
      $Message = @(
        'Updating source dependency reference preamble for'
        "'$($_.SourceFile.FileInfo.FullName)'"
      ) -join ' '
      Write-Verbose $Message
      $_.SetReferencePreamble()
    }
  }
}
