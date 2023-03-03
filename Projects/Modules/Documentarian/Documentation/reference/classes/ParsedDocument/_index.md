---
title: ParsedDocument
summary: Defines a parsed Markdown document with metadata and convenience methods.
description: >-
  The **ParsedDocument** class defines a parsed Markdown document with its text, metadata, and
  convenience methods.
no_list: true
---

## Definition

{{% src path="Public/Classes/ParsedDocument.psm1" title="Source Code" /%}}

The **ParsedDocument** class is used throughout the **Documentarian** module as the model and
interface representing a Markdown file. It includes the file's metadata, raw content, the Markdown
AST for the document, its front matter, body text, and the list of links in the document. It also
includes several convenience methods for inspecting the document.

## Examples

### 1. Getting the parsed changelog

This example creates a **ParsedDocument** from the project's changelog, which you can then inspect
with its properties and methods.

```powershell
Get-Document ./CHANGELOG.md
```

```output
FileInfo       : C:\code\pwsh\Documentarian\Source\Modules\Documentaria
                 n\CHANGELOG.md
RawContent     : ---
                 title: Changelog
                 weight: 0
                 description: |
                   All notable changes to the **Documentarian** module
                 are documented in this file.

                   This changelog's format is based on [Keep a
                 Changelog][01] and this project adheres to
                   [Semantic Versioning][02].

                   For releases before `1.0.0`, this project uses the
                 following convention:

                   - While the major version is `0`, the code is
                 considered unstable.
                   - The minor version is incremented when a
                 backwards-incompatible change is introduced.
                   - The patch version is incremented when a
                 backwards-compatible change or bug fix is introduced.

                   [01]: https://keepachangelog.com/en/1.0.0/
                   [02]: https://semver.org/spec/v2.0.0.html
                 ---

                 ## Unreleased

                 - Scaffolded initial project.

ParsedMarkdown : {Markdig.Extensions.Yaml.YamlFrontMatterBlock,
                 Markdig.Syntax.HeadingBlock,
                 Markdig.Syntax.ListItemBlock, Markdig.Extensions.AutoI
                 dentifiers.HeadingLinkReferenceDefinition}
FrontMatter    : {[title, Changelog], [weight, 0], [description, All
                 notable changes to the **Documentarian** module are
                 documented in this file.

                 This changelog's format is based on [Keep a
                 Changelog][01] and this project adheres to
                 [Semantic Versioning][02].

                 For releases before `1.0.0`, this project uses the
                 following convention:

                 - While the major version is `0`, the code is
                 considered unstable.
                 - The minor version is incremented when a
                 backwards-incompatible change is introduced.
                 - The patch version is incremented when a
                 backwards-compatible change or bug fix is introduced.

                 [01]: https://keepachangelog.com/en/1.0.0/
                 [02]: https://semver.org/spec/v2.0.0.html
                 ]}
Body           : ## Unreleased

                 - Scaffolded initial project.

Links          :
```

## Constructors

[`ParsedDocument()`][01]
: Initializes a new instance of the **ParsedDocument** class.

## Methods

[`InlineLinks()`][02]
: Returns every inline (non-reference) link from the document.

[`ParsedLinks()`][03]
: Returns the parsed links from the document, parsing if needed.

[`ReferenceDefinitions()`][04]
: Returns every reference link definition from the document.

[`ReferenceLinks()`][05]
: Returns every reference link from the document.

[`ReferenceLinksAndDefinitions()`][06]
: Returns every reference link and reference link definition from the document.

[`ToDecoratedString()`][07]
: Returns the VT100-encoded string representing the rendered markdown for the document.

[`UndefinedReferenceLinks()`][08]
: Returns every reference link that doesn't have a matching reference link definition from the
  document.

[`UnusedReferenceLinkDefinitions()`][09]
: Returns every reference link definition that doesn't have at least one matching reference link
  from the document.

[`ValidReferenceLinksAndDefinitions()`][10]
: Returns every reference link that isn't undefined and every reference link definition that isn't
  unused from the document.

## Properties

[**Body**][11]
: The **Body** property contains the Markdown content of the document as a single string with the
front matter removed.

[**FileInfo**][12]
: The **FileInfo** property contains the document's metadata from the file system.

[**FrontMatter**][13]
: The **FrontMatter** property contains the key-value data from the document's frontmatter. The data
  is stored as an ordered dictionary so it can be modified and written back to the file without
  changing the order of the keys in the document.

[**Links**][14]
: The **Links** property contains the list of all discovered links from the document's Markdown
  content.

[**ParsedMarkdown**][15]
: The **ParsedMarkdown** property contains the abstract syntax tree (AST) representation of the
  document's Markdown returned by Markdig.

[**RawContent**][16]
: The **RawContent** property contains the document's content as a single string, including the
  frontmatter and Markdown exactly as it existed in the file when it was parsed.

<!-- Reference Link Definitions -->
[01]: ./constructors#parseddocument
[02]: ./methods/inlinelinks
[03]: ./methods/parsedlinks
[04]: ./methods/referencedefinitions
[05]: ./methods/referencelinks
[06]: ./methods/referencelinksanddefinitions
[07]: ./methods/todecoratedstring
[08]: ./methods/undefinedreferencelinks
[09]: ./methods/unusedreferencelinkdefinitions
[10]: ./methods/validreferencelinksanddefinitions
[11]: ./properties#body
[12]: ./properties#fileinfo
[13]: ./properties#frontmatter
[14]: ./properties#links
[15]: ./properties#parsedmarkdown
[16]: ./properties#rawcontent
