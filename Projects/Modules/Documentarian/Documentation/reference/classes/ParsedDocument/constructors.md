---
title: Constructors
summary: Constructors for the ParsedDocument class
description: >-
  Defines the constructors for the **ParsedDocument** class.
---

## Overloads

[`ParsedDocument()`](#parseddocument)
: Initializes a new instance of the [**ParsedDocument**][01] class.

## `ParsedDocument()`

Initializes a new instance of the [**ParsedDocument**][01] class.

```powershell
[ParsedDocument]::new()
```

You can create a [**ParsedDocument**][01] by either casting a hash table of the class's properties
to a variable with the `[ParsedDocument]` type or using the [`Get-Document`][02] cmdlet to find and
parse a document.

<!-- Link Reference Definitions -->
[01]: ../
[02]: ../../../cmdlets/get-document
