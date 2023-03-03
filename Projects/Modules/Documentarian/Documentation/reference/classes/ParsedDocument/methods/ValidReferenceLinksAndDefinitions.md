---
title: ValidReferenceLinksAndDefinitions
summary: >-
  Returns every reference link that isn't undefined and every reference link definition that isn't
  unused from the document.
description: >-
  The `ValidReferenceLinksAndDefinitions()` method returns every reference link that isn't undefined
  and every reference link definition that isn't unused from the document.
---

## Overloads

[`ValidReferenceLinksAndDefinitions()`](#validreferencelinksanddefinitions)
: Returns every reference link that isn't undefined and every reference link definition that isn't
  unused from the document.

## `ValidReferenceLinksAndDefinitions()`

Returns every reference link that isn't undefined and every reference link definition that isn't
unused from the document.

```powershell
[ParsedDocument] ValidReferenceLinksAndDefinitions()
```

### Parameters

None.

### Returns

Type
: [`[DocumentLink[]]`][01]
{ .pwsh-metadata }

The list of links from the document where:

1. **Kind** is [`TextSelfReference`][02] or [`ImageSelfReference`][03] and **Text** matches the
   **ReferenceID** of a link whose **Kind** is `ReferenceDefinition`.
1. **Kind** is [`TextUsingReference`][04], or[`ImageUsingReference`][05] and **ReferenceID**
   matches the **ReferenceID** of a link whose **Kind** is `ReferenceDefinition`.
1. **Kind** is [`ReferenceDefinition`][06] and its **ReferenceID** matched the **Text** of a link
   with a **Kind** of `*SelfReference` or the **ReferenceID** of a link with a **Kind** of
   `*UsingReference`.

### Exceptions

None.

### Examples

The following example demonstrates retrieving the list of reference links and definitions from a
parsed document.

```powershell
$Doc = Get-Document ./README.md
$Doc.ValidReferenceLinksAndDefinitions()
```

<!-- Link Reference Definitions -->
[01]: ../../documentlink
[02]: ../../../enums/linkkind#textselfreference
[03]: ../../../enums/linkkind#textusingreference
[04]: ../../../enums/linkkind#imageselfreference
[05]: ../../../enums/linkkind#imageusingreference
[06]: ../../../enums/linkkind#referencedefinition
