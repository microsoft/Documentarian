---
title: Style Rules
linktitle: Rules
weight: 10
summary: Reference documentation for the Vale style rules in the PowerShell-Docs style package.
description: >-
  Reference documentation for the Vale style rules in the **PowerShell-Docs** style package.
---
<!-- vale off -->

## Avoid

Consider replacing "by using" with "using" - the leading "by" is redundant.

{{< vale/rule "styles.psdocs.Avoid" >}}

### Examples

Incorrect
: The cmdlet changes the file by using the passed parameters.

Correct
: The cmdlet changes the file using the passed parameters.

## Cliches

Avoid using clichés. They're particularly difficult to translate and usually require
locale-specific knowledge of English to understand.

{{< vale/rule "styles.psdocs.Cliches" >}}

### Examples

Incorrect
: What this boils down to is that the function won't work in any PS Drive other than the registry.

Correct
: The function only works in a registry PS Drive.

## EmDash

{{< vale/rule "styles.psdocs.EmDash" >}}

## EnDash

{{< vale/rule "styles.psdocs.EnDash" >}}

## EndOfLine

{{< vale/rule "styles.psdocs.EndOfLine" >}}

## Exclamation

{{< vale/rule "styles.psdocs.Exclamation" >}}

## HeadingDepth

{{< vale/rule "styles.psdocs.HeadingDepth" >}}

## InternalLinkCase

{{< vale/rule "styles.psdocs.InternalLinkCase" >}}

## InternalLinkExtension

{{< vale/rule "styles.psdocs.InternalLinkExtension" >}}

## Latin

{{< vale/rule "styles.psdocs.Latin" >}}

## LyHyphens

{{< vale/rule "styles.psdocs.LyHyphens" >}}

## MergeConflictMarkers

{{< vale/rule "styles.psdocs.MergeConflictMarkers" >}}

## OptionalPlurals

{{< vale/rule "styles.psdocs.OptionalPlurals" >}}

## Parens

{{< vale/rule "styles.psdocs.Parens" >}}

## Passive

{{< vale/rule "styles.psdocs.Passive" >}}

## Periods

{{< vale/rule "styles.psdocs.Periods" >}}

## Repetition

{{< vale/rule "styles.psdocs.Repetition" >}}

## Semicolons

{{< vale/rule "styles.psdocs.Semicolons" >}}

## Slang

{{< vale/rule "styles.psdocs.Slang" >}}

## So

{{< vale/rule "styles.psdocs.So" >}}

## Spacing

{{< vale/rule "styles.psdocs.Spacing" >}}

## Spelling

{{< vale/rule "styles.psdocs.Spelling" >}}

## TODO

{{< vale/rule "styles.psdocs.TODO" >}}

## TooWordy

{{< vale/rule "styles.psdocs.TooWordy" >}}

## Weasel

{{< vale/rule "styles.psdocs.Weasel" >}}

## WhichComma

{{< vale/rule "styles.psdocs.WhichComma" >}}

## WhichThat

{{< vale/rule "styles.psdocs.WhichThat" >}}

## Will

{{< vale/rule "styles.psdocs.Will" >}}

## WordList

{{< vale/rule "styles.psdocs.WordList" >}}
