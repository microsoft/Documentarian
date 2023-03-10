---
title: ToString
summary: Returns the string representation of a ValeApplicationInfo instance.
description: >-
  The `ToString()` method returns the string representation of a **ValeApplicationInfo** instance.
---

## Overloads

[`ToString()`](#tostring)
: Returns the string representation of a **ValeApplicationInfo** instance.

## `ToString()`

Returns the string representation of a [**ValeApplicationInfo**][01] instance.

```powershell
[ParsedDocument] ToString()
```

### Parameters

None.

### Returns

Type
: {{% xref "System.String" %}}
{ .pwsh-metadata }

The method returns the full path to the Vale application.

### Exceptions

None.

### Examples

The following example demonstrates the **ValeApplicationInfo** object interpolated into a string.

```powershell
"Vale is installed at: '$(Get-Vale)'"
```

```output
Vale is installed at: 'C:\code\pwsh\Documentarian\.vale\vale.exe'
```

<!-- Link Reference Definitions -->
[01]: ../../
