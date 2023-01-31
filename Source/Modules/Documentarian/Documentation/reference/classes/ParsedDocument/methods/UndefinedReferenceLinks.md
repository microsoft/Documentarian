---
title: UndefinedReferenceLinks
summary: >-
  Returns every reference link that doesn't have a matching reference link definition from the
  document.
description: >-
  The `UndefinedReferenceLinks()` method returns every reference link that doesn't have a matching
  reference link definition from the document.
---

## Overloads

[`UndefinedReferenceLinks()`](#undefinedreferencelinks)
: Returns every reference link that doesn't have a matching reference link definition from the
  document.

## `UndefinedReferenceLinks()`

Returns every reference link that doesn't have a matching reference link definition from the
document.

```powershell
[ParsedDocument] UndefinedReferenceLinks()
```

### Parameters

None.

### Returns

Type
: [`[DocumentLink[]]`][01]
{ .pwsh-metadata }

The list of links from the document that meet these criteria:

1. Have a **Kind** of [`TextSelfReference`][02], [`TextUsingReference`][03],
   [`ImageSelfReference`][04], or [`ImageUsingReference`][05]
1. Don't have their **Text** (if **Kind** is `TextSelfReference` or `ImageSelfReference`) or
   **ReferenceID** (if **Kind** is `TextUsingReference` or `ImageUsingReference`) match the
   **ReferenceID** of another link in the document whose **Kind** is [`ReferenceDefinition`][06].

### Exceptions

None.

### Examples

The following example demonstrates retrieving the list of reference links from a parsed document
that don't have a matching definition.

```powershell
$Doc = Get-Document ./README.md
$Doc.UndefinedReferenceLinks()
```

<!-- Link Reference Definitions -->
[01]: ../../documentlink
[02]: ../../../enums/linkkind#textselfreference
[03]: ../../../enums/linkkind#textusingreference
[04]: ../../../enums/linkkind#imageselfreference
[05]: ../../../enums/linkkind#imageusingreference
[06]: ../../../enums/linkkind#referencedefinition
