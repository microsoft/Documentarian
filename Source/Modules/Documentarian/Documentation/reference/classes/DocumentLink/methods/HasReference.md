---
title: HasReference
summary: Returns whether the DocumentLink instance's Kind reference link.
description: >-
  The `HasReference()` method returns whether the **DocumentLink** instance's **Kind** is a
  reference link.
---

## Overloads

[`HasReference()`](#hasreference)
: Returns whether the **DocumentLink** instance's **Kind** is a reference link.

## `HasReference()`

Returns whether the [**DocumentLink**][01] instance's [**Kind**][02] is a reference link.

```powershell
[ParsedDocument] HasReference()
```

### Parameters

None.

### Returns

Type
: {{% xref "System.Boolean" %}}
{ .pwsh-metadata }

The method returns `$true` if the [**Kind**][02] is [`ImageInline`][03],
[`ImageSelfReference`][04], or [`ImageUsingReference`][05] or `$false` if not.

### Exceptions

None.

### Examples

The following example demonstrates retrieving the list of reference links from a parsed document.

```powershell
$Doc = Get-Document ./README.md
$Doc.Links | Where-Object -FilterScript { $_.HasReference() }
```

<!-- Link Reference Definitions -->
[01]: ../../
[02]: ../../properties#kind
[03]: ../../../../enums/linkkind#imageinline
[04]: ../../../../enums/linkkind#imageselfreference
[05]: ../../../../enums/linkkind#imageusingreference
