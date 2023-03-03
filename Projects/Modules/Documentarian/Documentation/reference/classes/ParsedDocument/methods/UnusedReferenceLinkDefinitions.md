---
title: UnusedReferenceLinkDefinitions
summary: >-
  Returns every reference link definition that doesn't have at least one matching reference link
  from the document.
description: >-
  The `UnusedReferenceLinkDefinitions()` method returns every reference link definition that doesn't
  have at least one matching reference link from the document.
---

## Overloads

[`UnusedReferenceLinkDefinitions()`](#unusedreferencelinkdefinitions)
: Returns every reference link definition that doesn't have at least one matching reference link
  from the document.

## `UnusedReferenceLinkDefinitions()`

Returns every reference link definition that doesn't have at least one matching reference link from
the document.

```powershell
[ParsedDocument] UnusedReferenceLinkDefinitions()
```

### Parameters

None.

### Returns

Type
: [`[DocumentLink[]]`][01]
{ .pwsh-metadata }

The list of links from the document whose **Kind** is [`ReferenceDefinition`][02] and whose
**ReferenceID** doesn't match either:

- the **Text** of any links whose **Kind** is `TextSelfReference` or `ImageSelfReference`
- the **ReferenceID** of any links whose **Kind** is `TextUsingReference` or `ImageUsingReference`

### Exceptions

None.

### Examples

The following example demonstrates retrieving the list of unused reference definitions from a parsed
document.

```powershell
$Doc = Get-Document ./README.md
$Doc.UnusedReferenceLinkDefinitions()
```

<!-- Link Reference Definitions -->
[01]: ../../documentlink
[02]: ../../../enums/linkkind#referencedefinition
