---
title: InsideSingleBacktick
summary: Returns a pattern for finding the value wrapped in backticks in another string.
description: >-
  The `InsideSingleBacktick()` static method returns a pattern for finding the value wrapped in
  backticks in another string.
---

## Overloads

[`InsideSingleBacktick(string)`](#insidesinglebacktickstring)
: Returns a pattern for finding the value wrapped in backticks in another string.

## `InsideSingleBacktick(string)`

Returns a pattern for finding the value wrapped in backticks in another string. It's a convenient
way to reuse another regular expression to see if it's inside inline code.

```powershell
InsideSingleBacktick([string]$InnerPattern)
```

### Parameters

#### InnerPattern

Type
: {{% xref "System.String" %}}
{ .pwsh-metadata }

A string representing the desired regular expression to find within a pair of backticks. To use this
with an exact match, use the [regex **Escape** static method][01] to escape the string before using
it as input to this method.

### Returns

Type
: {{% xref "System.String" %}}
{ .pwsh-metadata }

A string representing a regular expression for testing if the given pattern is nested inside
backticks (`` ` ``).

### Exceptions

None.

### Examples

The following example demonstrates checking whether a given pattern is discovered inside backticks
in a line of text.

```powershell
$Text = 'This is `some+thing` to find.'
$Pattern = "some+thing"

$Text -match [ParsingPatterns]::InsideSingleBacktick($Pattern)

$Text -match [ParsingPatterns]::InsideSingleBacktick([regex]::Escape($Pattern))

$Matches
```

```output
False

True

Name                           Value
----                           -----
0                              `some+thing`
```

<!-- Link Reference Definitions -->
[01]: https://learn.microsoft.com/dotnet/api/system.text.regularexpressions.regex.escape
