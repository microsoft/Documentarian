---
title: ReferenceLinksAndDefinitions
summary: Returns every reference link and definition from the document.
description: >-
  The `ReferenceLinksAndDefinitions()` method returns every reference link and definition from the
  document.
---

## Overloads

[`ReferenceLinksAndDefinitions()`](#referencelinksanddefinitions)
: Returns every reference link and definition from the document.

## `ReferenceLinksAndDefinitions()`

Returns every reference link and definition from the document.

```powershell
[ParsedDocument] ReferenceLinksAndDefinitions()
```

### Parameters

None.

### Returns

Type
: [`[DocumentLink[]]`][01]
{ .pwsh-metadata }

The list of links from the document whose **Kind** is [`TextSelfReference`][02],
[`TextUsingReference`][03], [`ImageSelfReference`][04], [`ImageUsingReference`][05], or
[`ReferenceDefinition`][06].

### Exceptions

None.

### Examples

The following example demonstrates retrieving the list of reference links and definitions from a
parsed document.

```powershell
$Doc = Get-Document ./README.md
$Doc.ReferenceLinksAndDefinitions()
```

<!-- Link Reference Definitions -->
[01]: ../../documentlink
[02]: ../../../enums/linkkind#textselfreference
[03]: ../../../enums/linkkind#textusingreference
[04]: ../../../enums/linkkind#imageselfreference
[05]: ../../../enums/linkkind#imageusingreference
[06]: ../../../enums/linkkind#referencedefinition
