---
title: Get-DocumentLink
summary: Retrieves links from a Markdown document with their metadata.
external help file: Documentarian-help.xml
Module Name: Documentarian
online version: https://microsoft.github.io/Documentarian/modules/documentarian/reference/cmdlets/get-documentlink
schema: 2.0.0
---

# Get-DocumentLink

## SYNOPSIS

Retrieves links from a Markdown document with their metadata.

## SYNTAX

### FilterByKind (Default)

```pwsh-syntax
Get-DocumentLink
 [-Path <String[]>]
 [-Document <ParsedDocument[]>]
 [-IncludeKind <LinkKind[]>]
 [-ExcludeKind <LinkKind[]>]
 [-MatchMarkdown <Regex>]
 [-MatchText <Regex>]
 [-MatchDestination <Regex>]
 [-MatchReferenceID <Regex>]
 [-NotMatchMarkdown <Regex>]
 [-NotMatchText <Regex>]
 [-NotMatchDestination <Regex>]
 [-NotMatchReferenceID <Regex>]
 [<CommonParameters>]
```

### FilterByOnly

```pwsh-syntax
Get-DocumentLink
 [-Path <String[]>]
 [-Document <ParsedDocument[]>]
 [-Only <String>]
 [-MatchMarkdown <Regex>]
 [-MatchText <Regex>]
 [-MatchDestination <Regex>]
 [-MatchReferenceID <Regex>]
 [-NotMatchMarkdown <Regex>]
 [-NotMatchText <Regex>]
 [-NotMatchDestination <Regex>]
 [-NotMatchReferenceID <Regex>]
 [<CommonParameters>]
```

## DESCRIPTION

The `Get-DocumentLink` cmdlet gets the links in a Markdown document with their metadata, including
the [**Kind**][01] of each link and its [**Position**][02]. You can use it to get the links
directly from one or more files with the **Path** parameter or pass it a set of parsed documents
(as returned by the [`Get-Document`][03] cmdlet) with the **Document** parameter.

You can use the remaining parameters to filter the list of links for the one's you're looking for,
such as inline links or links with undefined references.

## EXAMPLES

### Example 1: Get links from a file

This example retrieves the list of links from the project changelog. The results show the **Kind**,
**Position**, and actual **Markdown** for every link. They also show the relevant metadata for the
link as defined in the document.

```powershell
Get-DocumentLink -Path ./CHANGELOG.md
```

```pwsh-output-list
Kind        : TextUsingReference
Text        : Keep a Changelog
Destination :
Title       :
ReferenceID : 01
Position    : C:\code\pwsh\Documentarian\CHANGELOG.md:5:24
Markdown    : [Keep a Changelog][01]

Kind        : TextUsingReference
Text        : Semantic Versioning
Destination :
Title       :
ReferenceID : 02
Position    : C:\code\pwsh\Documentarian\CHANGELOG.md:6:1
Markdown    : [Semantic Versioning][02]

Kind        : TextUsingReference
Text        : Documentarian
Destination :
Title       :
ReferenceID : 03
Position    : C:\code\pwsh\Documentarian\CHANGELOG.md:16:3
Markdown    : [Documentarian][03]

Kind        : TextUsingReference
Text        : Documentarian.DevX
Destination :
Title       :
ReferenceID : 04
Position    : C:\code\pwsh\Documentarian\CHANGELOG.md:17:3
Markdown    : [Documentarian.DevX][04]

Kind        : ReferenceDefinition
Text        :
Destination : https://keepachangelog.com/en/1.0.0/
Title       :
ReferenceID : 01
Position    : C:\code\pwsh\Documentarian\CHANGELOG.md:19:0
Markdown    : [01]: https://keepachangelog.com/en/1.0.0/

Kind        : ReferenceDefinition
Text        :
Destination : https://semver.org/spec/v2.0.0.html
Title       :
ReferenceID : 02
Position    : C:\code\pwsh\Documentarian\CHANGELOG.md:20:0
Markdown    : [02]: https://semver.org/spec/v2.0.0.html

Kind        : ReferenceDefinition
Text        :
Destination : Source/Modules/Documentarian/CHANGELOG.md
Title       :
ReferenceID : 03
Position    : C:\code\pwsh\Documentarian\CHANGELOG.md:21:0
Markdown    : [03]: Source/Modules/Documentarian/CHANGELOG.md

Kind        : ReferenceDefinition
Text        :
Destination : Source/Modules/Documentarian.DevX/CHANGELOG.md
Title       :
ReferenceID : 04
Position    : C:\code\pwsh\Documentarian\CHANGELOG.md:22:0
Markdown    : [04]: Source/Modules/Documentarian.DevX/CHANGELOG.md
```

### Example 2: Get count of inline links from a folder

In this example, `Get-DocumentLink` lists all of the inline links from documents in a folder, then
groups them by filename and lists their count.

```powershell
Get-DocumentLink -Path .\reference\ -Only Inline |
    Group-Object -Property { $_.Position.FileInfo.FullName } |
    Select-Object -Property Count, Name
```

```pwsh-output-table
Count  Name
-----  ----
    3  C:\docs\reference\classes\DocumentLink\constructors.md
    1  C:\docs\reference\classes\DocumentLink\methods\HasReference.md
    1  C:\docs\reference\classes\DocumentLink\methods\IsImage.md
    1  C:\docs\reference\classes\DocumentLink\methods\IsReference.md
    1  C:\docs\reference\classes\DocumentLink\methods\IsSelfReferential.md
    1  C:\docs\reference\classes\DocumentLink\methods\IsText.md
    2  C:\docs\reference\classes\DocumentLink\methods\Parse.md
    1  C:\docs\reference\classes\LinkKindTransformAttribute\constructors.md
    1  C:\docs\reference\classes\LinkKindTransformAttribute\methods\Transform.md
    1  C:\docs\reference\classes\ParsedDocument\constructors.md
    1  C:\docs\reference\classes\ParsedDocument\methods\InlineLinks.md
    2  C:\docs\reference\classes\ParsedDocument\methods\ParsedLinks.md
    1  C:\docs\reference\classes\ParsedDocument\methods\ToDecoratedString.md
    1  C:\docs\reference\classes\ParsedDocument\methods\UndefinedReferenceLinks.md
    1  C:\docs\reference\classes\ParsedDocument\methods\UnusedReferenceLinkDefinitions.md
    1  C:\docs\reference\classes\ParsedDocument\methods\ValidReferenceLinksAndDefinitions.md
    1  C:\docs\reference\classes\ParsingPatterns\methods\InsideSingleBacktick.md
    2  C:\docs\reference\classes\ParsingPatterns\methods\InSquareBrackets.md
    1  C:\docs\reference\classes\ParsingPatterns\methods\NotInsideInlineCode.md
    1  C:\docs\reference\classes\Position\constructors.md
    1  C:\docs\reference\classes\Position\methods\ToString.md
    1  C:\docs\reference\cmdlets\_index.md
    1  C:\docs\reference\cmdlets\Get-Document.md
    1  C:\docs\reference\cmdlets\Get-DocumentLink.md
```

### Example 3: Get reference links from a list of documents

In this example, `Get-Document` is used to parse every Markdown document in the reference folder and
save it to the `$docs` variable. Then, `Get-DocumentLink` gets every reference link and definition
from those parsed documents, grouping the results by **Kind**.

```powershell
$docs = Get-Document -Path .\reference
Get-DocumentLink -Document $docs -Only References |
    Group-Object -Property Kind |
    Select-Object -Property Name, Count
```

```pwsh-output-table
Name                Count
----                -----
TextSelfReference       8
TextUsingReference    132
ReferenceDefinition   121
```

### Example 4: Get external links

In this example, `Get-Document` is used to parse every Markdown document in the reference folder and
save it to the `$docs` variable. Then, `Get-DocumentLink` uses the **MatchDestination** parameter to
filter for only those links and reference link definition whose **Destination** starts with `http:`
or `https:`.

```powershell
$docs = Get-Document -Path .\reference
Get-DocumentLink -Document $docs -MatchDestination '^https?:'
```

```pwsh-output-list
Kind        : ReferenceDefinition
Text        :
Destination : https://learn.microsoft.com/powershell/module/microsoft.powershell
              .core/about/about_comparison_operators#-like-and--notlike
Title       :
ReferenceID : 02
Position    : C:\docs\reference\classes\LinkKindTransformAttribute\methods\
              Transform.md:49:0
Markdown    : [02]: https://learn.microsoft.com/powershell/module/microsoft
              .powershell.core/about/about_comparison_operators#-like-and--notlike

Kind        : ReferenceDefinition
Text        :
Destination : https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h2-VT100-Mode
Title       :
ReferenceID : 01
Position    : C:\docs\reference\classes\ParsedDocument\methods\ToDecoratedString.md:41:0
Markdown    : [01]: https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h2-VT100-Mode

Kind        : ReferenceDefinition
Text        :
Destination : https://learn.microsoft.com/dotnet/api/system.text.regularexpressions
              .regex.escape
Title       :
ReferenceID : 01
Position    : C:\docs\reference\classes\ParsingPatterns\methods\InsideSingleBacktick
              .md:67:0
Markdown    : [01]: https://learn.microsoft.com/dotnet/api/system.text
              .regularexpressions.regex.escape

Kind        : TextInline
Text        : about_CommonParameters
Destination : http://go.microsoft.com/fwlink/?LinkID=113216
Title       :
ReferenceID :
Position    : C:\docs\reference\cmdlets\Get-Document.md:41:244
Markdown    : [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216)

Kind        : TextInline
Text        : about_CommonParameters
Destination : http://go.microsoft.com/fwlink/?LinkID=113216
Title       :
ReferenceID :
Position    : C:\docs\reference\cmdlets\Get-DocumentLink.md:408:1
Markdown    : [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216)
```

## PARAMETERS

### -Document { .pwsh-param }

Specify one or more [**ParsedDocument**][04] object, as output by the [`Get-Document`][03] cmdlet,
to return get links from.

```yaml
Type: ParsedDocument[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ExcludeKind { .pwsh-param }

Specify one or more [**LinkKind**][05] enums to exclude from the list of returned links. If you
specify a wildcard character, such as `*`, the cmdlet filters all matching **LinkKind** enums.

Only links whose [**Kind**][01] property is not in the list of enums specified by this parameter
are returned.

```yaml
Type: LinkKind[]
Parameter Sets: FilterByKind
Aliases:
Accepted values: TextInline, TextSelfReference, TextUsingReference, ImageInline, ImageSelfReference, ImageUsingReference, ReferenceDefinition

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -IncludeKind { .pwsh-param }

Specify one or more [**LinkKind**][05] enums to include for the list of returned links. If you
specify a wildcard character, such as `*`, the cmdlet filters all matching **LinkKind** enums.

Only links whose [**Kind**][01] property is in the list of enums specified by this parameter are
returned.

```yaml
Type: LinkKind[]
Parameter Sets: FilterByKind
Aliases:
Accepted values: TextInline, TextSelfReference, TextUsingReference, ImageInline, ImageSelfReference, ImageUsingReference, ReferenceDefinition

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -MatchDestination { .pwsh-param }

Specify a regular expression to check against the value of the [**Destination**][06] property for
the links. Only links with a **Destination** property whose value matches the regular expression
are returned.

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -MatchMarkdown { .pwsh-param }

Specify a regular expression to check against the value of the [**Markdown**][07] property for the
links. Only links with a **Markdown** property whose value matches the regular expression are
returned.

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -MatchReferenceID { .pwsh-param }

Specify a regular expression to check against the value of the [**ReferenceID**][08] property for
the links. Only links with a **ReferenceID** property whose value matches the regular expression
are returned.

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -MatchText { .pwsh-param }

Specify a regular expression to check against the value of the [**Text**][09] property for the
links. Only links with a **Text** property whose value matches the regular expression are returned.

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -NotMatchDestination { .pwsh-param }

Specify a regular expression to check against the value of the [**Destination**][06] property for
the links. Only links with a **Destination** property whose value doesn't match the regular
expression are returned.

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -NotMatchMarkdown { .pwsh-param }

Specify a regular expression to check against the value of the [**Markdown**][07] property for the
links. Only links with a **Markdown** property whose value doesn't match the regular expression are
returned.

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -NotMatchReferenceID { .pwsh-param }

Specify a regular expression to check against the value of the [**ReferenceID**][08] property for
the links. Only links with a **ReferenceID** property whose value doesn't match the regular
expression are returned.

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -NotMatchText { .pwsh-param }

Specify a regular expression to check against the value of the [**Text**][09] property for
the links. Only links with a **Text** property whose value doesn't match the regular
expression are returned.

```yaml
Type: Regex
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -Only { .pwsh-param }

Specify a preset filter for the links to return. Valid options include:

- `Inline` - return only the links that are defined inline
- `References` - return only reference links and definitions
- `UndefinedReferences` - return only reference links that don't have a matching definition
- `UnusedReferences` - return only reference link definitions that don't have a matching link
- `ValidReferences` - return only reference links that have definitions and reference link
  definitions that are used.

```yaml
Type: String
Parameter Sets: FilterByOnly
Aliases:
Accepted values: Inline, References, UndefinedReferences, UnusedReferences, ValidReferences

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -Path { .pwsh-param }

Specify the path to one or more files or folders. The cmdlet parses the specified values for
Markdown documents and returns the links defined in them.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: FullName

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: True
```

### CommonParameters

This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`,
`-InformationAction`, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`,
`-Verbose`, `-WarningAction`, and `-WarningVariable`. For more information, see
[about_CommonParameters][99].

## INPUTS

### System.String[]

You can pass a list of file and folder paths to this cmdlet to parse for Markdown links.

### ParsedDocument[]

You can pass a list of [**ParsedDocument**][04] objects to this cmdlet to return links from.

## OUTPUTS

### DocumentLink

This cmdlet returns [**DocumentLink**][10] objects.

## NOTES

## RELATED LINKS

[Get-Document][03]

<!-- Reference Link Definitions -->
[01]: ../../classes/documentlink/properties#kind
[02]: ../../classes/position
[03]: ../get-documentlink
[04]: ../../classes/parseddocument/
[05]: ../../enums/LinkKind.md
[06]: ../../classes/documentlink/properties#destination
[07]: ../../classes/documentlink/properties#markdown
[08]: ../../classes/documentlink/properties#referenceid
[09]: ../../classes/documentlink/properties#text
[10]: ../../classes/documentlink
[99]: http://go.microsoft.com/fwlink/?LinkID=113216
