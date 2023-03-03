---
title: SourceScope
summary: Distinguishes the scope of source file for processing.
description: >-
  The **SourceScope** enum distinguishes the visibility and availability of a source file for processing.
---

## Definition

{{% src path="Public/Classes/SourceScope.psm1" title="Source Code" /%}}

## Fields

### `Private`

Value
: 0
{ .pwsh-metadata }

Indicates that the source file or folder is for private code, which is used only inside the module.
Private code isn't imported or visible when a user imports the module.

### `Public`

Value
: 1
{ .pwsh-metadata }

Indicates that the source file or folder is for public code, which is automatically imported and
visible when a user imports the module.
