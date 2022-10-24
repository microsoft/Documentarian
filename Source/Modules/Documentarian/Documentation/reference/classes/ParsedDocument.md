---
title: ParsedDocument
summary: Validates that a specified value is a path pointing to a PowerShell script file path.
description: >-
  Ensures that a value is a path pointing to a PowerShell file.
---

## Definition

{{% src path="Public/Classes/ParsedDocument.psm1" title="Source Code" /%}}

The **ParsedDocument** class...

## Examples

### Example 1

```powershell

```

## Constructors

### `ParsedDocument()`

The default constructor takes no input.

## Methods

### `ToDecoratedString()`

## Properties

### `FileInfo`

Type
: {{% xref "System.IO.FileInfo" %}}
{.pwsh-metadata}

### `RawContent`

Type
: {{% xref "System.String" %}}
{.pwsh-metadata}

### `ParsedMarkdown`

Type
: {{% xref "Markdig.Syntax.MarkdownDocument" %}}
{.pwsh-metadata}

### `FrontMatter`

Type
: {{% xref "System.Collections.Specialized.OrderedDictionary" %}}
{.pwsh-metadata}

### `Body`

Type
: {{% xref "System.String" %}}
{.pwsh-metadata}
