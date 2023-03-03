---
title: ToString
summary: Returns the string representation of a position.
description: >-
  The `ToString()` method returns the string representation of a position.
---

## Overloads

[`ToString()`](#tostring)
: Returns the string representation of a position.

## `ToString()`

Returns the string representing a **Position**. It combines the **FullName** property of the
position's **FileInfo**, the **LineNumber**, and the **StartColumn**.

```powershell
[ParsedDocument] ToString()
```

### Parameters

None.

### Returns

Type
: {{< xref "System.String" >}}
{ .pwsh-metadata }

A string including the the **FullName** property of the position's **FileInfo**, its
**LineNumber**, and its **StartColumn**. The values are separated by colons (`:`). If the
position's **FileInfo** property is `$null`, only the **LineNumber** and **StartColumn** values are
included.

### Exceptions

None.

### Examples

The following example demonstrates viewing a position as a string with and without the **FileInfo**.

```powershell
[Position]$Position = [Position]@{
    LineNumber  = 5
    StartColumn = 10
}
$Position.ToString()
```

```output
5:10
```

```powershell
[Position]$Position = [Position]@{
    FileInfo    = Get-Item ./README.md
    LineNumber  = 5
    StartColumn = 10
}
$Position.ToString()
```

```output
C:\code\pwsh\Documentarian\README.md:5:10
```
