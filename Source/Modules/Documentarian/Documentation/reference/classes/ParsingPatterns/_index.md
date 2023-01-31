---
title: ParsingPatterns
summary: Defines a parsed Markdown document with metadata and convenience methods.
description: >-
  The **ParsingPatterns** static class defines a parsed Markdown document with its text, metadata,
  and convenience methods.
no_list: true
---

## Definition

{{% src path="Public/Classes/ParsingPatterns.psm1" title="Source Code" /%}}

The **ParsingPatterns** static class provides a quick way to retrieve different regular expression
strings for parsing Markdown syntax. The properties and methods never need an instance to be
created.

## Examples

### 1. Finding whether text is inside inline code

This example demonstrates checking a line of Markdown to see whether specific strings are inside an
inline code block syntax.

```powershell
$Line = @'
We sell `` apples ``, `bagels`, and cookies.
'@

$CheckTexts = @('apples', 'bagels', 'cookies')

foreach ($Text in $CheckTexts) {
    if ([ParsingPatterns]::NotInsideInlineCode($Line, $Text)) {
        "The text '$Text' isn't inside an inline code block."
    } else {
        "The text '$Text' is inside an inline code block."
    }
}
```

```output
The text 'apples' is inside an inline code block.
The text 'bagels' is inside an inline code block.
The text 'cookies' isn't inside an inline code block.
```

### 2. Finding an HTML comment

This example demonstrates parsing a line of Markdown for an HTML comment block.

```powershell
$Line = @'
This is <!-- an html comment --> and the text after it.
'@

if ($Line -match [ParsingPatterns]::HtmlCommentBlock) {
    $Matches
}
```

```output
Name                           Value
----                           -----
OpenComment                    <!--
CloseComment                   -->
InComments                      an html comment
0                              <!-- an html comment -->
```

## Methods

[`InsideSingleBacktick(string)`][01]
: Returns a pattern for finding the value wrapped in backticks in another string.

[`InSquareBrackets()`][02]
: Returns a standard pattern for finding everything inside square brackets.

[`InSquareBrackets(string)`][03]
: Returns a pattern for finding everything inside square brackets using named balance groups.

[`NotInsideInlineCode(string, string)`][04]
: Returns whether a string of text is inside any inline code blocks for a given line of Markdown.

## Properties

[**ClosingMultiLineHtmlComment**][05]
: A regular expression string for finding the closing of a comment block and the text on either side
  of the closure.

[HtmlCommentBlock][06]
: A regular expression string for finding the opening of a comment block on a line and whether it
  closes on that line.

[LineLead][07]
: A regular expression string for finding the leading characters of a line of Markdown before the
  actual content.

[Link][08]
: A regular expression for finding a Markdown link in a given line of text.

[LinkDefinition][09]
: A regular expression for parsing the destination and title of a Markdown link or link reference
  definition.

[LinkReferenceDefinition][10]
: A regular expression for parsing a line of Markdown for a link reference definition.

[MultitickInlineCode][11]
: A regular expression for finding text inside of two or more wrapping backticks and a space.

[OpenCodeFence][12]
: A regular expression for finding the opening of a code fence in a line of Markdown.

<!-- Reference Link Definitions -->
[01]: ./methods/InsideSingleBacktick#insidesinglebacktickstring
[02]: ./methods/InSquareBrackets#insquarebrackets
[03]: ./methods/InSquareBrackets#insquarebracketsstring
[04]: ./methods/NotInsideInlineCode#notinsideinlinecodestring-string
[05]: ./properties#closingmultilinehtmlcomment
[06]: ./properties#htmlcommentblock
[07]: ./properties#linelead
[08]: ./properties#link
[09]: ./properties#linkdefinition
[10]: ./properties#linkreferencedefinition
[11]: ./properties#multitickinlinecode
[12]: ./properties#opencodefence
