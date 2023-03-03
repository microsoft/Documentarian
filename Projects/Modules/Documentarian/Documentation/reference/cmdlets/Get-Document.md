---
external help file: Documentarian-help.xml
Module Name: Documentarian
ms.date: 02/07/2023
online version: https://microsoft.github.io/Documentarian/modules/documentarian/reference/cmdlets/get-document
schema: 2.0.0
summary: Parses a document as Markdown and returns it as a usable object.
title: Get-Document
---

# Get-Document

## SYNOPSIS

Parses a document as Markdown and returns it as a usable object.

## SYNTAX

```pwsh-syntax
Get-Document
 [[-Path] <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION

The `Get-Document` cmdlet parses one or more Markdown files and returns a [**ParsedDocument**][01]
object for each of them.

## EXAMPLES

### Example 1: Get a parsed Markdown document

This example parses the project changelog as a Markdown document.

```powershell
Get-Document -Path ./CHANGELOG.md
```

```pwsh-output-list
FileInfo       : C:\code\pwsh\Documentarian\CHANGELOG.md
RawContent     : # Project Changelogs

                 All notable changes to these projects are documented in a
                 changelog file in their folder.

                 The format is based on [Keep a Changelog][01], and this
                 project adheres to
                 [Semantic Versioning][02].

                 For releases before `1.0.0`, this project uses the following
                 convention:

                 - While the major version is `0`, the code is considered
                 unstable.
                 - The minor version is incremented when a
                 backwards-incompatible change is introduced.
                 - The patch version is incremented when a
                 backwards-compatible change or bug fix is introduced.

                 ## Modules

                 - [Documentarian][03]
                 - [Documentarian.DevX][04]

                 [01]: https://keepachangelog.com/en/1.0.0/
                 [02]: https://semver.org/spec/v2.0.0.html
                 [03]: Source/Modules/Documentarian/CHANGELOG.md
                 [04]: Source/Modules/Documentarian.DevX/CHANGELOG.md

ParsedMarkdown : {Markdig.Syntax.HeadingBlock, Markdig.Syntax.ParagraphBlock,
                 Markdig.Syntax.ParagraphBlock, Markdig.Syntax.ParagraphBlock…}
FrontMatter    :
Body           : # Project Changelogs

                 All notable changes to these projects are documented in a
                 changelog file in their folder.

                 The format is based on [Keep a Changelog][01], and this
                 project adheres to
                 [Semantic Versioning][02].

                 For releases before `1.0.0`, this project uses the following
                 convention:

                 - While the major version is `0`, the code is considered
                 unstable.
                 - The minor version is incremented when a
                 backwards-incompatible change is introduced.
                 - The patch version is incremented when a
                 backwards-compatible change or bug fix is introduced.

                 ## Modules

                 - [Documentarian][03]
                 - [Documentarian.DevX][04]

                 [01]: https://keepachangelog.com/en/1.0.0/
                 [02]: https://semver.org/spec/v2.0.0.html
                 [03]: Source/Modules/Documentarian/CHANGELOG.md
                 [04]: Source/Modules/Documentarian.DevX/CHANGELOG.md

Links          : {01, 02, 03, 04…}
```

### Example 2: Parse a folder of Markdown documents

This example parses every Markdown document in the `reference` folder.

```powershell
Get-Document -Path .\reference\ |
    Select-Object -Property FileInfo, FrontMatter -First 3 |
    Format-List
```

```pwsh-output-list
FileInfo    : C:\docs\reference\_index.md
FrontMatter : {[title, Reference], [summary, Reference documentation for the
              PowerShell code in the **Documentarian** module.], [description,
              Reference documentation for the PowerShell code in the
              **Documentarian** module.], [weight, 99]}

FileInfo    : C:\docs\reference\about\_index.md
FrontMatter : {[title, About Topics], [weight, 0], [summary, PowerShell `about_*`
              topics for the **Documentarian** module.], [description, PowerShell
              `about_*` topics for the **Documentarian** module.]}

FileInfo    : C:\docs\reference\classes\_index.md
FrontMatter : {[title, Classes], [summary, Reference documentation for the
              PowerShell classes in the **Documentarian** module.], [description,
              Reference documentation for the PowerShell classes in the
              **Documentarian** module.]}
```

## PARAMETERS

### -Path

Specify the path to one or more Markdown files or folders containing Markdown files.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`,
`-InformationAction`, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`,
`-Verbose`, `-WarningAction`, and `-WarningVariable`. For more information, see
[about_CommonParameters][99].

## INPUTS

### None

This cmdlet doesn't support input from the pipeline.

## OUTPUTS

### ParsedDocument

This cmdlet returns a [**ParsedDocument**][01] object for every Markdown file specified by the
**Path** parameter.

## NOTES

## RELATED LINKS

[01]: ../../classes/parseddocument/
[99]: http://go.microsoft.com/fwlink/?LinkID=113216
