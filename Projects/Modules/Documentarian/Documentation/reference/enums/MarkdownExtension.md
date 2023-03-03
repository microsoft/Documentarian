---
title: MarkdownExtension
summary: Distinguishes the type of source file for processing.
description: >-
  The **MarkdownExtension** enum distinguishes the type of source file for processing.
---

## Definition

{{% src path="Public/Enums/MarkdownExtension.psm1" title="Source Code" /%}}

## Fields

### `Class`

Value
: 0
{ .pwsh-metadata }

Indicates that the source file or folder is for a PowerShell classes.

### `Enum`

Value
: 1
{ .pwsh-metadata }

Indicates that the source file or folder is for a PowerShell enums.

### `Function`

Value
: 2
{ .pwsh-metadata }

Indicates that the source file or folder is for a PowerShell functions.
