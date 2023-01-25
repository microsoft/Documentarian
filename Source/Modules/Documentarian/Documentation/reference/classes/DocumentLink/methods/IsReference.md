---
title: IsReference
summary: Returns whether the DocumentLink instance's Kind is a reference definition.
description: >-
  The `IsReference()` method returns whether the **DocumentLink** instance's **Kind** is a reference
  definition.
---

## Overloads

[`IsReference()`](#isreference)
: Returns whether the **DocumentLink** instance's **Kind** is a reference definition.

## `IsReference()`

Returns whether the [**DocumentLink**][01] instance's [**Kind**][02] is a reference definition.

```powershell
[ParsedDocument] IsReference()
```

### Parameters

None.

### Returns

Type
: {{% xref "System.Boolean" %}}
{ .pwsh-metadata }

The method returns `$true` if the [**Kind**][02] is [`ReferenceDefinition`][03] or `$false` if not.

### Exceptions

None.

### Examples

The following example demonstrates retrieving the list of reference link definitions from a parsed
document.

```powershell
$Doc = Get-Document ./README.md
$Doc.Links | Where-Object -FilterScript { $_.IsReference() }
```

<!-- Link Reference Definitions -->
[01]: ../../
[02]: ../../properties#kind
[03]: ../../../../enums/linkkind#referencedefinition
