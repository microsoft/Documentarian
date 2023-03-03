---
title: IsText
summary: Returns whether the DocumentLink instance's Kind is text.
description: >-
  The `IsText()` method returns whether the **DocumentLink** instance's **Kind** is text.
---

## Overloads

[`IsText()`](#istext)
: Returns whether the **DocumentLink** instance's **Kind** is text.

## `IsText()`

Returns whether the [**DocumentLink**][01] instance's [**Kind**][02] is text.

```powershell
[ParsedDocument] IsText()
```

### Parameters

None.

### Returns

Type
: {{% xref "System.Boolean" %}}
{ .pwsh-metadata }

The method returns `$true` if the [**Kind**][02] is [`TextInline`][03], [`TextSelfReference`][04],
or [`TextUsingReference`][05] or `$false` if not.

### Exceptions

None.

### Examples

The following example demonstrates retrieving the list of text links from a parsed document.

```powershell
$Doc = Get-Document ./README.md
$Doc.Links | Where-Object -FilterScript { $_.IsText() }
```

<!-- Link Reference Definitions -->
[01]: ../../
[02]: ../../properties#kind
[03]: ../../../../enums/linkkind#textinline
[04]: ../../../../enums/linkkind#textselfreference
[05]: ../../../../enums/linkkind#textusingreference
