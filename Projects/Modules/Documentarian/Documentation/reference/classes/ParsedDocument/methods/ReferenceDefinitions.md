---
title: ReferenceDefinitions
summary: Returns every reference link definition from the document.
description: >-
  The `ReferenceDefinitions()` method returns every reference link definition from the document.
---

## Overloads

[`ReferenceDefinitions()`](#referencedefinitions)
: Returns every reference link definition from the document.

## `ReferenceDefinitions()`

Returns every reference link definition from the document.

```powershell
[ParsedDocument] ReferenceDefinitions()
```

### Parameters

None.

### Returns

Type
: [`[DocumentLink[]]`][01]
{ .pwsh-metadata }

The list of links from the document whose **Kind** is [`ReferenceDefinition`][02].

### Exceptions

None.

### Examples

The following example demonstrates retrieving the list of reference definitions from a parsed
document.

```powershell
$Doc = Get-Document ./README.md
$Doc.ReferenceDefinitions()
```

<!-- Link Reference Definitions -->
[01]: ../../documentlink
[02]: ../../../enums/linkkind#referencedefinition
