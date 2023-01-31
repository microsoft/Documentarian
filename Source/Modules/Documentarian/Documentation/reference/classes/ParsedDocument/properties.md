---
title: Properties
summary: Properties for the ParsedDocument class
description: >-
  Defines the properties for the **ParsedDocument** class.
---

### `Body`

The **Body** property contains the Markdown content of the document as a single string with the
front matter removed.

Type
: {{% xref "System.String" %}}
{.pwsh-metadata}

### `FileInfo`

The **FileInfo** property contains the document's metadata from the file system.

Type
: {{% xref "System.IO.FileInfo" %}}
{.pwsh-metadata}

### `FrontMatter`

The **FrontMatter** property contains the key-value data from the document's frontmatter. The data
is stored as an ordered dictionary so it can be modified and written back to the file without
changing the order of the keys in the document.

Type
: {{% xref "System.Collections.Specialized.OrderedDictionary" %}}
{.pwsh-metadata}

### `Links`

The **Links** property contains the list of all discovered links from the document's Markdown
content.

Type
: [`DocumentLink[]`][01]
{.pwsh-metadata}

### `ParsedMarkdown`

The **ParsedMarkdown** property contains the abstract syntax tree (AST) representation of the
document's Markdown returned by Markdig.

Type
: {{% xref "Markdig.Syntax.MarkdownDocument" %}}
{.pwsh-metadata}

### `RawContent`

The **RawContent** property contains the document's content as a single string, including the
frontmatter and Markdown exactly as it existed in the file when it was parsed.

Type
: {{% xref "System.String" %}}
{.pwsh-metadata}

<!-- Reference Link Definitions -->
[01]: ../documentlink
