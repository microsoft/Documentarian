---
title: Position
summary: Defines the location of text in a file
description: >-
  The **Position** class defines the location of text in a file.
no_list: true
---

## Definition

{{% src path="Public/Classes/ParsedDocument.psm1" title="Source Code" /%}}

The **Position** class is used to define the location of text in a document. This allows other
classes and cmdlets to find a specific piece of text precisely in a document instead of only
relying on matching the text's value.

It includes information about the file, if any, as well as the line and column number.

## Examples

### Example 1

```powershell
[Position]$Position = @{
    FileInfo    = Get-Item -Path ./CHANGELOG.md
    LineNumber  = 1
    StartColumn = 1
}

"The position is:`n`t$Position"
```

```output
The position is:
    C:\code\pwsh\Documentarian\Source\Modules\Documentarian\CHANGELOG.md:1:1
```

## Constructors

[`Position()`][01]
: Initializes a new instance of the **Position** class.

## Methods

[`ToString()`][02]
: Returns the string representation of a position.

## Properties

[**FileInfo**][03]
: Represents the file the **Position** exists in, if any.

[**LineNumber**][04]
: Represents the line from the text the **Position** is at.

[**StartColumn**][05]
: Represents how many characters into a line the **Position** is.

<!-- Link Reference Definitions -->
[01]: ./constructors#position
[02]: ./methods/tostring
[03]: ./properties#fileinfo
[04]: ./properties#linenumber
[05]: ./properties#startcolumn
