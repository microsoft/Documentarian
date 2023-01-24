# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Classes/ParsedDocument.psm1
using module ../../Classes/DocumentLink.psm1
using module ../../Classes/LinkKindTransformAttribute.psm1
using module ../../Enums/LinkKind.psm1

#region    RequiredFunctions

$SourceFolder = $PSScriptRoot
while ('Source' -ne (Split-Path -Leaf $SourceFolder)) {
  $SourceFolder = Split-Path -Parent -Path $SourceFolder
}
$RequiredFunctions = @(
  Resolve-Path -Path "$SourceFolder/Public/Functions/General/Get-Document.ps1"
)
foreach ($RequiredFunction in $RequiredFunctions) {
  . $RequiredFunction
}

#endregion RequiredFunctions

function Get-DocumentLink {
  [CmdletBinding(DefaultParameterSetName = 'FilterByKind')]
  [OutputType([DocumentLink])]
  param(
    [Parameter(
      ParameterSetName = 'FilterByKind',
      ValueFromPipeline,
      ValueFromPipelineByPropertyName
    )]
    [Parameter(
      ParameterSetName = 'FilterByOnly',
      ValueFromPipeline,
      ValueFromPipelineByPropertyName
    )]
    [Alias('FullName')]
    [string[]]$Path,
    [Parameter(ParameterSetName = 'FilterByKind', ValueFromPipeline)]
    [Parameter(ParameterSetName = 'FilterByOnly', ValueFromPipeline)]
    [ParsedDocument[]]$Document,
    [Parameter(ParameterSetName = 'FilterByKind')]
    [LinkKindTransformAttribute()]
    [LinkKind[]]$IncludeKind,
    [Parameter(ParameterSetName = 'FilterByKind')]
    [LinkKindTransformAttribute()]
    [LinkKind[]]$ExcludeKind,
    [Parameter(ParameterSetName = 'FilterByOnly')]
    [ValidateSet(
      'Inline',
      'References',
      'UndefinedReferences',
      'UnusedReferences',
      'ValidReferences'
    )]
    [string]$Only,
    [regex]$MatchMarkdown,
    [regex]$MatchText,
    [regex]$MatchDestination,
    [regex]$MatchReferenceID,
    [regex]$NotMatchMarkdown,
    [regex]$NotMatchText,
    [regex]$NotMatchDestination,
    [regex]$NotMatchReferenceID
  )

  process {
    if ($Path) {
      $Document = Get-Document -Path $Path
    }

    $Document | ForEach-Object {
      $ParsedDocument = $_
      $Links = $ParsedDocument.Links

      switch ($Only) {
        'Inline' {
          $Links = $ParsedDocument.InlineLinks()
        }

        'References' {
          $Links = $ParsedDocument.ReferenceLinksAndDefinitions()
        }

        'UndefinedReferences' {
          $Links = $ParsedDocument.UndefinedReferenceLinks()
        }

        'UnusedReferences' {
          $Links = $ParsedDocument.UnusedReferenceLinkDefinitions()
        }

        'ValidReferences' {
          $Links = $ParsedDocument.ValidReferenceLinksAndDefinitions()
        }
      }

      if ($IncludeKind.Count) {
        $Links = $Links.Where({ $_.Kind -in $IncludeKind })
      }

      if ($ExcludeKind.Count) {
        $Links = $Links.Where({ $_.Kind -notin $ExcludeKind })
      }

      if ($MatchMarkdown) {
        $Links = $Links.Where({ $_.Markdown -match $MatchMarkdown })
      }

      if ($MatchText) {
        $Links = $Links.Where({ $_.Text -match $MatchText })
      }

      if ($MatchDestination) {
        $Links = $Links.Where({ $_.Destination -match $MatchDestination })
      }

      if ($MatchReferenceID) {
        $Links = $Links.Where({ $_.ReferenceID -match $MatchReferenceID })
      }

      if ($NotMatchMarkdown) {
        $Links = $Links.Where({ $_.Markdown -notmatch $NotMatchMarkdown })
      }

      if ($NotMatchText) {
        $Links = $Links.Where({ $_.Text -notmatch $NotMatchText })
      }

      if ($NotMatchDestination) {
        $Links = $Links.Where({ $_.Destination -notmatch $NotMatchDestination })
      }

      if ($NotMatchReferenceID) {
        $Links = $Links.Where({ $_.ReferenceID -notmatch $NotMatchReferenceID })
      }

      $Links
    }
  }
}
