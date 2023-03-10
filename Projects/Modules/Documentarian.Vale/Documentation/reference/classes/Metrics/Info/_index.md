---
title: ValeMetricsInfo
linktitle: Info
summary: Represents a list of counts for the prose in a document.
description: >-
  The **ValeMetricsInfo** class represents a list of counts for the prose in a
  document.
no_list: true
---

## Definition

{{% src path="Public/Classes/ValeMetricsInfo.psm1" title="Source Code" /%}}

An instance of the **ValeMetricsInfo** class represents a list of counts for the prose in a
document as returned by the [`Get-ProseMetric`][01] command.

## Examples

### 1. Checking the metrics for a document

This example shows the metrics returned for a Markdown document.

```powershell
get-proseMetric -Path ./README.md
Get-ProseMetric -Path ./README.md | Format-List
```

```output
FileInfo                             WordCount SentenceCount ParagraphCount
--------                             --------- ------------- --------------
C:\code\pwsh\Documentarian\README.md 416       38            29


FileInfo              : C:\code\pwsh\Documentarian\README.md
CharacterCount        : 2175
ComplexWordCount      : 81
HeadingCounts         : ValeMetricsHeadingCount
ListBlockCount        : 7
LongWordCount         : 139
ParagraphCount        : 29
PolysyllabicWordCount : 94
SentenceCount         : 38
SyllableCount         : 748
WordCount             : 416
```

## Constructors

[`ValeMetricsInfo()`][02]
: Initializes a new instance of the **ValeMetricsInfo** class.

[`ValeMetricsInfo(System.Collections.Hashtable)`][03]
: Initializes a new instance of the **ValeMetricsInfo** class from the output of `vale ls-metrics`

[`ValeMetricsInfo(System.Collections.Hashtable, System.IO.FileInfo)`][04]
: Initializes a new instance of the **ValeMetricsInfo** class from the output of `vale ls-metrics`
  and the file's information.

## Properties

[**CharacterCount**][05]
: Represents the number of characters in the document.

[**ComplexWordCount**][06]
: Represents the number of polysyllabic words without common suffixes in the document.

[**FileInfo**][07]
: Represents the file the metrics are for.

[**HeadingCounts**][08]
: Represents the counts for the headings in the document.

[**ListBlockCount**][09]
: Represents the number of ordered and unordered lists in the document.

[**LongWordCount**][10]
: Represents the number of words with more than 6 characters in the document.

[**ParagraphCount**][11]
: Represents the number of paragraphs in the document.

[**PolysyllabicWordCount**][12]
: Represents the number of words with more than two syllables in the document.

[**SentenceCount**][13]
: Represents the number of sentences in the document.

[**SyllableCount**][14]
: Represents the number of syllables in the document.

[**WordCount**][15]
: Represents the number of words in the document.

<!-- Reference Link Definitions -->
[01]: ../../../cmdlets/Get-ProseMetric
[02]: ./constructors#valemetricsinfo
[03]: ./constructors#valemetricsinfosystemcollectionshashtable
[04]: ./constructors#valemetricsinfosystemcollectionshashtable-systemiofileinfo
[05]: ./properties#charactercount
[06]: ./properties#complexwordcount
[07]: ./properties#fileinfo
[08]: ./properties#headingcounts
[09]: ./properties#listblockcount
[10]: ./properties#longwordcount
[11]: ./properties#paragraphcount
[12]: ./properties#polysyllabicwordcount
[13]: ./properties#sentencecount
[14]: ./properties#syllablecount
[15]: ./properties#wordcount
