---
title: Parse
summary: Inspects a Markdown document for any links inside it.
description: >-
  The **Parse** static method inspects a Markdown document for any links inside it.
---

## Overloads

[`Parse(String)`](#parsestring)
: Inspects a string for any instances of Markdown link syntaxes, returning an instance of the
  **DocumentLink** class for every parsed link.

[`Parse(System.IO.FileInfo)`](#parsesystemiofileinfo)
: Inspects a file's content for any instances of Markdown link syntaxes, returning an instance of
  the **DocumentLink** class for every parsed link.

## `Parse(String)`

Inspects a string for any instances of Markdown link syntaxes, returning an instance of the
[**DocumentLink**][01] class for every parsed link.

```powershell
Parse([string]$Markdown)
```

### Parameters

#### `Markdown`

Type
: {{% xref "System.String" %}}
{.pwsh-metadata}

The string of Markdown text to parse for links.

### Returns

Type
: [**DocumentLink**][01]
{.pwsh-metadata}

Zero or more instances representing every parsed link from the text.

### Exceptions

None.

#### 1. Parsing a string for links

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

## `Parse(System.IO.FileInfo)`

Inspects a file's content for any instances of Markdown link syntaxes, returning an instance of the
[**DocumentLink**][01] class for every parsed link.

```powershell
Parse([System.IO.FileInfo]$FileInfo)
```

### Parameters

#### `Markdown`

Type
: {{% xref "System.IO.FileInfo" %}}
{.pwsh-metadata}

The file whose content to parse for Markdown links.

### Returns

Type
: [**DocumentLink**][01]
{.pwsh-metadata}

Zero or more instances representing every parsed link from the file.

### Exceptions

None.

### Examples

#### 1. Parsing a document for links

This example demonstrates parsing a Markdown file for links.

```powershell
$Readme = Get-Item -Path ./README.md
[DocumentLink]::Parse($Readme)
```

[01]: ../../
