# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Public/Enums/SourceCategory.psm1
using module ../../Public/Enums/SourceScope.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Private/Functions/Get-EnumRegex.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Resolve-NameSpace {
  [CmdletBinding()]
  [OutputType([String])]
  param(
    [Parameter(Mandatory, ParameterSetName = 'ByTaxonomy')]
    [SourceCategory]$Category,

    [Parameter(Mandatory, ParameterSetName = 'ByTaxonomy')]
    [SourceScope]$Scope,

    [Parameter(ParameterSetName = 'ByPath')]
    [string]$ParentNameSpace,

    [Parameter(Mandatory, ParameterSetName = 'ByPath')]
    [string]$Path
  )

  begin {
    $BaseFolderPattern = @(
      Get-EnumRegex -EnumType ([SourceScope])
      '\w*\.'
      Get-EnumRegex -EnumType ([SourceCategory])
      '\w*'
      '(?<Remaining>.+)?'
    ) -join ''
  }

  process {
    $ParentNameSpace = ''
    $ChildNameSpace = ''

    # If a path is specified, we need to figure out child namespacing
    if ($Path) {
      <#
        Turn the path containing the file into a period-separated string to avoid future path
        separator munging/checking for xplat concerns.
      #>
      $DefinitionFolder = Get-Item -Path $Path
      | Select-Object -ExpandProperty PSIsContainer
      | ForEach-Object {
        ($_ ? $Path : (Split-Path -Parent -Path $Path)) -replace '(\\|\/)', '.'
      }
      <#
        When there's no parent namespace, we need to figure out the category and scope to build the
        parent namespace and collect any remaining folder segments as child namespace segments.
      #>
      if ([string]::IsNullOrEmpty($ParentNameSpace)) {
        $SourceRelativeFolder = ($DefinitionFolder -split 'Source')[-1].Trim('.')
        if ($SourceRelativeFolder -match $BaseFolderPattern) {
          $Category = [SourceCategory].GetEnumNames() | Where-Object {
            $Matches.SourceCategory -like "$_*"
          }
          $Scope = [SourceScope].GetEnumNames() | Where-Object {
            $Matches.SourceScope -like "$_*"
          }
          $ChildNameSpace = $Matches.Remaining
        }
      } else {
        <#
          When we know the parent, we just want everything after it. When parent is the base (only
          has two segments, Category.Scope) we want to split on Category. Otherwise, split on the
          last segment.
        #>
        $ParentSegments = ($ParentNameSpace -split '\.')
        $SplittingSegment = $ParentSegments.Count -eq 2 ? $ParentSegments[0] : $ParentSegments[-1]
        $ChildNameSpace = $DefinitionFolder -split $SplittingSegment
        | Select-Object -Skip 1
        | Join-String -Separator '.'
      }
    }

    if ([string]::IsNullOrEmpty($ParentNameSpace)) {
      $ParentNameSpace = switch ($Category) {
        Class { "Classes.$Scope" }
        Enum { "Enums.$Scope" }
        Function { "Functions.$Scope" }
      }
    }

    if ($Path) {
      return $ParentNameSpace + $ChildNameSpace
    } else {
      return $ParentNameSpace
    }
  }
}
