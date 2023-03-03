---
title: ToDecoratedString
summary: Returns the VT100-encoded string representing the rendered markdown for the document.
description: >-
  The `ToDecoratedString()` method returns the VT100-encoded string representing the rendered
  markdown for the document.
---

## Overloads

[`ToDecoratedString()`](#todecoratedstring)
: Returns the VT100-encoded string representing the rendered markdown for the document.

## `ToDecoratedString()`

Returns the [VT100-encoded][01] string representing the rendered markdown for the document. This
allows you to review the rendered Markdown in the console.

```powershell
[ParsedDocument] ToDecoratedString()
```

### Parameters

None.

### Returns

Type
: {{< xref "System.String" >}}
{ .pwsh-metadata }

The Markdown rendered to a [VT100-encoded][01] string.

### Exceptions

None.

### Examples

The following example demonstrates viewing a document's rendered Markdown in the console.

```powershell
$Doc = Get-Document ./README.md
$Doc.ToDecoratedString()
```

<!-- Link Reference Definitions -->
[01]: https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h2-VT100-Mode
