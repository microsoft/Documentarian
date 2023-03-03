---
title: NotInsideInlineCode
summary: >-
  Returns whether a string of text is inside any inline code blocks for a given line of Markdown.
description: >-
  The `NotInsideInlineCode()` static method returns whether a string of text is inside any inline
  code blocks for a given line of Markdown.
---

## Overloads

[`NotInsideInlineCode(string, string)`](#notinsideinlinecodestring-string)
: Returns whether a string of text is inside any inline code blocks for a given line of Markdown.

## `NotInsideInlineCode(string, string)`

Returns whether a string of text is inside any inline code blocks for a given line of Markdown.

```powershell
NotInsideInlineCode([string]$Line, [string]$FullMatch)
```

### Parameters

#### Line

Type
: {{% xref "System.String" %}}
{ .pwsh-metadata }

Specifies the line of Markdown text to check for inline code.

#### FullMatch

Type
: {{% xref "System.String" %}}
{ .pwsh-metadata }

Specifies the full text to check for inside inline code on the given line.

### Returns

Type
: {{% xref "System.Boolean" %}}
{ .pwsh-metadata }

The value is `$true` if the value of `$FullMatch` isn't inside an inline-code block in the `$Line`
string and `$false` if it is.

### Exceptions

None.

### Examples

The following example demonstrates checking a line of Markdown to see whether a link's syntax is
inside an inline code block.

```powershell
$Line = @'
This `` link is [invalid](in-code.md) ``, but [this one](is.md "okay").
'@

[ParsingPatterns]::NotInsideInlineCode($Line, '[invalid](in-code.md)')

[ParsingPatterns]::NotInsideInlineCode($Line, '[this one](is.md "okay")')
```

```output
False

True
```

<!-- Link Reference Definitions -->
