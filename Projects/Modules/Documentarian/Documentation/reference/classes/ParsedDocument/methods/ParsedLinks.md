---
title: ParsedLinks
summary: Returns the parsed links from the document, parsing if needed or if **Force** is `$true`.
description: >-
  The `ParsedLinks()` method returns the parsed links from the document, parsing if needed or if
  **Force** is `$true`.
---

## Overloads

[`ParsedLinks()`](#parsedlinks)
: Returns the parsed links from the document, parsing it first if needed.

[`ParsedLinks([bool]$Force)`](#parsedlinksboolforce)
: Returns the parsed links from the document, parsing it first if needed or if **Force** is `$true`.

## `ParsedLinks()`

Returns the parsed links from the document, parsing it first if needed.

```powershell
[ParsedDocument] ParsesLinks()
```

### Parameters

None.

### Returns

Type
: [`[DocumentLink[]]`][01]
{ .pwsh-metadata }

The list of parsed links from the document.

### Exceptions

None.

### Examples

The following example demonstrates retrieving the links from a document.

```powershell
$Doc = Get-Document ./README.md
$Doc.ParsedLinks()
```

## `ParsedLinks([bool]$Force)`

Returns the parsed links from the document, parsing it first if needed or if **Force** is `$true`.

```powershell
[ParsedDocument] ParsesLinks([bool]$Force)
```

### Parameters

#### Force

Type
: {{< xref "System.Boolean" >}}

If **Force** is `$true`, the document's body is parsed for links, even if it was already parsed.

### Returns

Type
: [`[DocumentLink[]]`][01]
{ .pwsh-metadata }

The list of parsed links from the document.

### Exceptions

None.

### Examples

The following example demonstrates retrieving the links from a document, always parsing it again,
even if the list of links has been retrieved before.

```powershell
$Doc = Get-Document ./README.md
$Doc.ParsedLinks($true)
```

<!-- Link Reference Definitions -->
[01]: ../../documentlink
