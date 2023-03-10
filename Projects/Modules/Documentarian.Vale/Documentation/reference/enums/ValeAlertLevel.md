---
title: ValeAlertLevel
summary: Defines the severity of a Vale rule violation.
description: >-
  The **ValeAlertLevel** enum defines the severity of a Vale rule violation.
---

## Definition

{{% src path="Public/Enums/ValeAlertLevel.psm1" title="Source Code" /%}}

## Fields

### `Suggestion`

Value
: 0
{ .pwsh-metadata }

Indicates that the violation represents a suggestion to change the prose. Suggestions are the least
serious violation type.

Suggestions may be resolved by the context of the violation. For example.

### `Warning`

Value
: 1
{ .pwsh-metadata }

Indicates that the violation represents a warning about the prose.

### `Error`

Value
: 2
{ .pwsh-metadata }

Indicates that the violation represents a structural or style error in the prose.
