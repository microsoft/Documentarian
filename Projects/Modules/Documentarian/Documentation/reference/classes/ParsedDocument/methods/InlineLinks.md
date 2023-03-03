---
title: InlineLinks
summary: Returns every inline (non-reference) link from the document.
description: >-
  The `InlineLinks()` method returns every inline (non-reference) link from the document.
---

## Overloads

[`InlineLinks()`](#inlinelinks)
: Returns every inline (non-reference) link from the document.

## `InlineLinks()`

Returns every inline (non-reference) link from the document.

```powershell
[ParsedDocument] InlineLinks()
```

### Parameters

None.

### Returns

Type
: [`[DocumentLink[]]`][01]
{ .pwsh-metadata }

The list of links from the document whose **Kind** is [`TextInline`][02] or [`ImageInline`][03].

### Exceptions

None.

### Examples

The following example demonstrates retrieving the list of inline links from a parsed document.

```powershell
$Doc = Get-Document ./README.md
$Doc.InlineLinks()
```

<!-- Link Reference Definitions -->
[01]: ../../documentlink
[02]: ../../../enums/linkkind#textinline
[03]: ../../../enums/linkkind#imageinline
