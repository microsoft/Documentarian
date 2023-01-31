---
title: IsImage
summary: Returns whether the DocumentLink instance's Kind is an image.
description: >-
  The `IsImage()` method returns whether the **DocumentLink** instance's **Kind** is an image.
---

## Overloads

[`IsImage()`](#isimage)
: Returns whether the **DocumentLink** instance's **Kind** is an image.

## `IsImage()`

Returns whether the [**DocumentLink**][01] instance's [**Kind**][02] is an image.

```powershell
[ParsedDocument] IsImage()
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

The following example demonstrates retrieving the list of image links from a parsed document.

```powershell
$Doc = Get-Document ./README.md
$Doc.Links | Where-Object -FilterScript { $_.IsImage() }
```

<!-- Link Reference Definitions -->
[01]: ../../
[02]: ../../properties#kind
[03]: ../../../../enums/linkkind#imageinline
[04]: ../../../../enums/linkkind#imageselfreference
[05]: ../../../../enums/linkkind#imageusingreference
