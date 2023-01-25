---
title: InSquareBrackets
summary: Returns a standard pattern for finding everything inside square brackets.
description: >-
  The `InSquareBrackets()` static method returns a standard pattern for finding everything inside
  square brackets.
---

## Overloads

[`InSquareBrackets()`](#insquarebrackets)
: Returns a standard pattern for finding everything inside square brackets.

[`InSquareBrackets(string)`](#insquarebracketsstring)
: Returns a pattern for finding everything inside square brackets using named balance groups.

## `InSquareBrackets()`

Returns a standard pattern for finding everything inside square brackets.

```powershell
InSquareBrackets()
```

### Parameters

None.

### Returns

Type
: {{% xref "System.String" %}}
{ .pwsh-metadata }

A string representing a regular expression for finding text nested inside one or more pairs of
square brackets.

### Exceptions

None.

### Examples

The following example demonstrates parsing a string for the text in square brackets. The matching
text is in the `Close` capture group.

```powershell
$Text = 'This is [some text with [nested brackets][01]][02].'

if ($Text -match [ParsingPatterns]::InSquareBrackets()) {
    $Matches
}
```

```output
Name                           Value
----                           -----
Close                          some text with [nested brackets][01]
0                              [some text with [nested brackets][01]]
```

## `InSquareBrackets(string)`

Returns a pattern for finding everything inside square brackets using named balance groups.

```powershell
InSquareBrackets([string]$BalanceGroupName)
```

### Parameters

#### BalanceGroupName

The name to use for the closing group and suffix for the open group. This enables you to combine
regular expressions for more than one set of square-bracketed text. If the value is an empty
string, the default closing group is named `Close` and the opening group is `Open` without any
suffix.

Type
: {{% xref "System.String" %}}

### Returns

Type
: {{% xref "System.String" %}}
{ .pwsh-metadata }

A string representing a regular expression for testing if the given pattern is nested inside
backticks (`` ` ``).

### Exceptions

None.

### Examples

The following example demonstrates returning a string for finding text inside of square brackets
where the closing group, which contains the matching text, is called `LinkText`:

```powershell

$Text = 'This is [some text with [nested brackets][01]][02].'

if ($Text -match [ParsingPatterns]::InSquareBrackets('LinkText')) {
    $Matches
}
```

```output
Name                           Value
----                           -----
LinkText                       some text with [nested brackets][01]
0                              [some text with [nested brackets][01]]
```

<!-- Link Reference Definitions -->
