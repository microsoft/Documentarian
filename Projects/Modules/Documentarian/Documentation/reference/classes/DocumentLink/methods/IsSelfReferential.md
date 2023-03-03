---
title: IsSelfReferential
summary: Returns whether the DocumentLink instance's Kind is self-reference.
description: >-
  The `IsSelfReferential()` method returns whether the **DocumentLink** instance's **Kind** is self-reference.
---

## Overloads

[`IsSelfReferential()`](#isselfreferential)
: Returns whether the **DocumentLink** instance's **Kind** is self-reference.

## `IsSelfReferential()`

Returns whether the [**DocumentLink**][01] instance's [**Kind**][02] is self-reference.

```powershell
[ParsedDocument] IsSelfReferential()
```

### Parameters

None.

### Returns

Type
: {{% xref "System.Boolean" %}}
{ .pwsh-metadata }

The method returns `$true` if the [**Kind**][02] is [`ImageSelfReference`][03] or
[`TextSelfReference`][04], or `$false` if not.

### Exceptions

None.

### Examples

The following example demonstrates retrieving the list of reference links whose **ReferenceID** is
also their text from a parsed document.

```powershell
$Doc = Get-Document ./README.md
$Doc.Links | Where-Object -FilterScript { $_.IsSelfReferential() }
```

<!-- Link Reference Definitions -->
[01]: ../../
[02]: ../../properties#kind
[03]: ../../../../enums/linkkind#imageselfreference
[04]: ../../../../enums/linkkind#textselfreference
