---
title: ReferenceLinks
summary: Returns every reference link from the document.
description: >-
  The `ReferenceLinks()` method returns every reference link from the document.
---

## Overloads

[`ReferenceLinks()`](#referencelinks)
: Returns every reference link from the document.

## `ReferenceLinks()`

Returns every reference link from the document.

```powershell
[ParsedDocument] ReferenceLinks()
```

### Parameters

None.

### Returns

Type
: [`[DocumentLink[]]`][01]
{ .pwsh-metadata }

The list of links from the document whose **Kind** is [`TextSelfReference`][02],
[`TextUsingReference`][03], [`ImageSelfReference`][04], or[`ImageUsingReference`][05].

### Exceptions

None.

### Examples

The following example demonstrates retrieving the list of reference links from a parsed document.

```powershell
$Doc = Get-Document ./README.md
$Doc.ReferenceLinks()
```

<!-- Link Reference Definitions -->
[01]: ../../documentlink
[02]: ../../../enums/linkkind#textselfreference
[03]: ../../../enums/linkkind#textusingreference
[04]: ../../../enums/linkkind#imageselfreference
[05]: ../../../enums/linkkind#imageusingreference
