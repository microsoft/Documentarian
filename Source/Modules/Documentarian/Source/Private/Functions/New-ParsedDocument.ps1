# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../../Public/Classes/ParsedDocument.psm1

function New-ParsedDocument {
  [CmdletBinding()]
  [OutputType('ParsedDocument')]
  param(
    [Parameter(Mandatory)]
    [System.IO.FileInfo]$FileInfo,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [string]$RawContent,

    [Parameter(Mandatory)]
    [AllowNull()]
    [Markdig.Syntax.MarkdownDocument]$ParsedMarkdown,

    [Parameter()]
    [System.Collections.Specialized.OrderedDictionary]$FrontMatter,

    [Parameter(Mandatory)]
    [AllowEmptyString()]
    [string]$Body
  )

  process {
    $Document = [ParsedDocument]::new()

    $Document.FileInfo = $FileInfo
    $Document.RawContent = $RawContent
    $Document.ParsedMarkdown = $ParsedMarkdown
    if ($FrontMatter) {
      $Document.FrontMatter = $FrontMatter
    }
    $Document.Body = $Body

    $Document
  }
}
