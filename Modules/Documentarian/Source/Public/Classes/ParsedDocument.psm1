# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class ParsedDocument {
  [System.IO.FileInfo]$FileInfo
  [string]$RawContent
  [Markdig.Syntax.MarkdownDocument]$ParsedMarkdown
  [System.Collections.Specialized.OrderedDictionary]$FrontMatter
  [string]$Body

  ParsedDocument() {}

  [string] ToDecoratedString() {
    return $this.Body
    | ConvertFrom-Markdown -AsVT100EncodedString
    | Select-Object -ExpandProperty VT100EncodedString
  }
}
