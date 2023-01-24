# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ./DocumentLink.psm1

class ParsedDocument {
  [System.IO.FileInfo]$FileInfo
  [string]$RawContent
  [Markdig.Syntax.MarkdownDocument]$ParsedMarkdown
  [System.Collections.Specialized.OrderedDictionary]$FrontMatter
  [string]$Body
  [DocumentLink[]]$Links

  hidden [bool]$HasParsedLinks

  ParsedDocument() {}

  hidden ParseLinksFromBody() {
    $this.Links = [DocumentLink]::Parse($this.Body)
    | ForEach-Object -Process {
      # Add the file info to each link
      $_.Position.FileInfo = $FileInfo
      # Emit the link for the list
      $_
    }

    $this.HasParsedLinks = $true
  }

  [DocumentLink[]] ParsedLinks([bool]$Force) {
    if (!$this.HasParsedLinks -or $Force) {
      $this.ParseLinksFromBody()
    }

    return $this.Links
  }

  [DocumentLink[]] InlineLinks() {
    return [DocumentLink]::FilterForInlineLinks($this.Links)
  }

  [DocumentLink[]] ReferenceLinks() {
    return [DocumentLink]::FilterForReferenceLinks($this.Links)
  }

  [DocumentLink[]] ReferenceDefinitions() {
    return [DocumentLink]::FilterForReferenceDefinitions($this.Links)
  }

  [DocumentLink[]] ReferenceLinksAndDefinitions() {
    return [DocumentLink]::FilterForReferenceLinksAndDefinitions($this.Links)
  }

  [DocumentLink[]] UndefinedReferenceLinks() {
    return [DocumentLink]::FilterForUndefinedReferenceLinks($this.Links)
  }

  [DocumentLink[]] UnusedReferenceLinkDefinitions() {
    return [DocumentLink]::FilterForUnusedReferenceLinkDefinitions($this.Links)
  }

  [DocumentLink[]] ValidReferenceLinksAndDefinitions() {
    return [DocumentLink]::FilterForValidReferenceLinksAndDefinitions($this.Links)
  }

  [string] ToDecoratedString() {
    return $this.Body
    | ConvertFrom-Markdown -AsVT100EncodedString
    | Select-Object -ExpandProperty VT100EncodedString
  }
}
