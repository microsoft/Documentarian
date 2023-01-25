---
title: Properties
summary: Properties for the ParsingPatterns class.
description: >-
  The static properties for the **ParsingPatterns** class.
---

## ClosingMultiLineHtmlComment

Type
: {{% xref "System.String" %}}

A regular expression string for finding the closing of a comment block and the text on either side
of the closure. It has three capture groups:

- `InComments` for the text that is still inside the HTML comment before it closes
- `CloseComment` for the syntax that closes the HTML comment
- `AfterComment` for the text that follows the closing HTML comment syntax

## HtmlCommentBlock

Type
: {{% xref "System.String" %}}

A regular expression string for finding the opening of a comment block on a line and whether it
closes on that line. It has three capture groups:

- `OpenComment` for the syntax that closes the HTML comment
- `InComments` for the text that is inside the HTML comment
- `CloseComment` for the syntax that closes the HTML comment

## LineLead

Type
: {{% xref "System.String" %}}

A regular expression string for finding the leading characters of a line of Markdown before the
actual content. It has several capture groups:

- `Lead` for all of the characters before the first non-leading character
- `LeadingWhiteSpace` for all of the leading whitespace before any block notation or non-leading
  character
- `BlockNotation` for the list and block quote syntax and associated whitespace after leading
  whitespace and before the first non-leading character
- `BlockQuoteBefore` for the characters of zero or more block quote syntaxes after the leading
  whitespace and before any list notation or non-leading character
- `ListNotation` for any list notation before the first non-leading character
- `OrderedList` for the list notation if it's an ordered list
- `UnorderedList` for the list notation if it's an unordered list
- `BlockQuoteAfter` for the characters of zero or more block quote syntaxes after all other leading
  syntaxes and before the first non-leading character

## Link

Type
: {{% xref "System.String" %}}

A regular expression for finding a Markdown link in a given line of text. It has several capture
groups:

- `IsImage` - for the `!` if the link is an image link
- `Text` - for the text in square brackets that makes up the link text for text-kind links and the
  alt text for image-kind links
- `Destination` - for the URL that is the href for a text-kind link or source for an image-kind
  link if the syntax is an inline link
- `Title` - for the optional title text inside quotes if the syntax is an inline link
- `ReferenceID` - for the ID of the reference link definition if the syntax is using a reference
  link

## LinkDefinition

Type
: {{% xref "System.String" %}}

A regular expression for parsing the destination and title of a Markdown link or link reference
definition. It has two capture groups:

- `Destination` for the URL that is the href for a text-kind link or source for an image-kind link
- `Title` - for the optional title text inside quotes

## LinkReferenceDefinition

Type
: {{% xref "System.String" %}}

A regular expression for parsing a line of Markdown for a link reference definition. It has several
capture groups:

- `Lead` for all of the characters before the first non-leading character
- `LeadingWhiteSpace` for all of the leading whitespace before any block notation or non-leading
  character
- `BlockNotation` for the list and block quote syntax and associated whitespace after leading
  whitespace and before the first non-leading character
- `BlockQuoteBefore` for the characters of zero or more block quote syntaxes after the leading
  whitespace and before any list notation or non-leading character
- `ListNotation` for any list notation before the first non-leading character
- `OrderedList` for the list notation if it's an ordered list
- `UnorderedList` for the list notation if it's an unordered list
- `BlockQuoteAfter` for the characters of zero or more block quote syntaxes after all other leading
  syntaxes and before the first non-leading character
- `ReferenceID` for the ID of the definition in square brackets that is used by referencing links
- `Destination` for the URL that is the href for a text-kind link or source for an image-kind link
- `Title` - for the optional title text inside quotes

## MultitickInlineCode

Type
: {{% xref "System.String" %}}

A regular expression for finding text inside of two or more wrapping backticks and a space. The
`Text` capture group contains all of the content inside the wrapping backticks.

## OpenCodeFence

Type
: {{% xref "System.String" %}}

A regular expression for finding the opening of a code fence in a line of Markdown. It has several
capture groups:

- `Lead` for all of the characters before the first non-leading character
- `LeadingWhiteSpace` for all of the leading whitespace before any block notation or non-leading
  character
- `BlockNotation` for the list and block quote syntax and associated whitespace after leading
  whitespace and before the first non-leading character
- `BlockQuoteBefore` for the characters of zero or more block quote syntaxes after the leading
  whitespace and before any list notation or non-leading character
- `ListNotation` for any list notation before the first non-leading character
- `OrderedList` for the list notation if it's an ordered list
- `UnorderedList` for the list notation if it's an unordered list
- `BlockQuoteAfter` for the characters of zero or more block quote syntaxes after all other leading
  syntaxes and before the first non-leading character
- `Fence` for the characters that make up the fence opening syntax, which is three or more
  backticks (`` ``` ``) or tildes (`~~~`).
