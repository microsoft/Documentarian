---
title: DocumentLink
summary: Defines a parsed Markdown link.
description: >-
  The **DocumentLink** class defines a parsed Markdown link.
no_list: true
---

## Definition

{{% src path="Public/Classes/DocumentLink.psm1" title="Source Code" /%}}

An instance of the **DocumentLink** class is represents a parsed Markdown link. The
[**ParsedDocument**][01] class makes a document's links available as an array of **DocumentLink**
objects, and the static [**Parse**][02] method returns a list of **DocumentLink** objects from a
given file or string.

## Examples

### 1. Parsing a string for links

This example demonstrates parsing a Markdown file for links.

```powershell
$Content = @'
This is a [markdown](/concepts/markdown.md) file.

You can add links like:

> ```md
> [<text>](url 'title')
> ```

[another](one), with [a third](too 'even a caption').
'@
[DocumentLink]::Parse($Content)
```

```output
Kind        : TextInline
Text        : markdown
Destination : /concepts/markdown.md
Title       :
ReferenceID :
Position    : 1:11
Markdown    : [markdown](/concepts/markdown.md)

Kind        : TextInline
Text        : another
Destination : one
Title       :
ReferenceID :
Position    : 9:1
Markdown    : [another](one)

Kind        : TextInline
Text        : a third
Destination : too
Title       : even a caption
ReferenceID :
Position    : 9:22
Markdown    : [a third](too 'even a caption')
```

### 2. Filtering a list of links by position

This example demonstrates selecting only links in the first 50 lines of a file.

```powershell
$Readme = Get-Item -Path ./README.md
[DocumentLink]::Parse($Readme) | Where-Object -FilterScript {
    $_.Position.LineNumber -le 50
}
```

## Constructors

[`DocumentLink()`][03]
: Initializes a new instance of the **DocumentLink** class.

[`DocumentLink(System.Text.RegularExpressions.Group)`][04]
: Initializes a new instance of the **DocumentLink** class from a regular expression match.

[`DocumentLink(System.Text.RegularExpressions.Group, int)`][05]
: Initializes a new instance of the **DocumentLink** class from a regular expression match and a
  given line number.

## Methods

[`HasReference()`][06]
: Returns whether the **DocumentLink** instance's [**Kind**][14] is a reference link.

[`IsImage()`][07]
: Returns whether the **DocumentLink** instance's [**Kind**][14] is an image.

[`IsReference()`][08]
: Returns whether the **DocumentLink** instance's [**Kind**][14] is a reference definition.

[`IsSelfReferential()`][09]
: Returns whether the **DocumentLink** instance's [**Kind**][14] is self-reference.

[`IsText()`][10]
: Returns whether the **DocumentLink** instance's [**Kind**][14] is text.

[`Parse(String)`][11]
: Inspects a string for any instances of Markdown link syntaxes, returning an instance of the
  **DocumentLink** class for every parsed link.

[`Parse(System.IO.FileInfo)`][12]
: Inspects a file's content for any instances of Markdown link syntaxes, returning an instance of
  the **DocumentLink** class for every parsed link.

## Properties

[**Destination**][13]
: Represents the `href` value for a text link or the `src` value for an image link.

[**Kind**][14]
: Distinguishes what sort of link the instance represents.

[**Markdown**][15]
: Represents the raw Markdown syntax of the link in the document it was parsed from.

[**Position**][16]
: Represents where in the Markdown the link was parsed from.

[**ReferenceID**][17]
: The document-unique ID for a reference definition.

[**Text**][18]
: Represents the displayed text for a text link and the alt text for an image link.

[**Title**][19]
: Represents the `title` attribute for a link, if specified.

<!-- Reference Link Definitions -->
[01]: ../../parseddocument/
[02]: ./methods/parse
[03]: ./constructors#documentlink
[04]: ./constructors#documentlinksystemtextregularexpressionsgroup
[05]: ./constructors#documentlinksystemtextregularexpressionsgroup-int
[06]: ./methods/hasreference
[07]: ./methods/isimage
[08]: ./methods/isreference
[09]: ./methods/isselfreferential
[10]: ./methods/istext
[11]: ./methods/parse#parsestring
[12]: ./methods/parse#parsesystemiofileinfo
[13]: ./properties#destination
[14]: ./properties#kind
[15]: ./properties#markdown
[16]: ./properties#position
[17]: ./properties#referenceid
[18]: ./properties#text
[19]: ./properties#title
