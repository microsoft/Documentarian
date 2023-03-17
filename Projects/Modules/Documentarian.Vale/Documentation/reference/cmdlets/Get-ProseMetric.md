---
external help file: Documentarian.Vale-help.xml
Locale: en-US
Module Name: Documentarian.Vale
online version: https://microsoft.github.io/Documentarian/modules/vale/reference/cmdlets/get-prosemetric
schema: 2.0.0
title: Get-ProseMetric
---

# Get-ProseMetric

## SYNOPSIS
Returns metrics about the prose in a document.

## SYNTAX

```
Get-ProseMetric [[-Path] <String[]>] [<CommonParameters>]
```

## DESCRIPTION

The `Get-ProseMetric` cmdlet returns various metrics for a document's prose as an object. The
metrics include counts for characters, syllables, words, and more. You can use these metrics to
investigate the complexity of your documents.

## EXAMPLES

### Example 1: Get the metrics for a file

```powershell
Get-ProseMetric -Path ./README.md
```

```output-pwsh-list
characters         : 2198
complex_words      : 83
heading_h2         : 5
heading_h3         : 4
list               : 8
long_words         : 139
paragraphs         : 28
polysyllabic_words : 96
sentences          : 38
syllables          : 755
words              : 419
FileName           : C:\code\pwsh\Documentarian\README.md
```

### Example 2: Get the word count for files and folders

```pwsh
Get-ProseMetric .\README.md, .\CHANGELOG.md, .\Documentation\reference\cmdlets\ |
    Format-Table -Property Words, FileName
```

```output-pwsh-table
words FileName
----- --------
   17 C:\code\README.md
    3 C:\code\CHANGELOG.md
   33 C:\code\Documentation\reference\cmdlets\_index.md
  153 C:\code\Documentation\reference\cmdlets\Convert-MDLinks.md
   94 C:\code\Documentation\reference\cmdlets\Get-ContentWithoutHeader.md
   98 C:\code\Documentation\reference\cmdlets\Get-Document.md
  721 C:\code\Documentation\reference\cmdlets\Get-DocumentLink.md
  131 C:\code\Documentation\reference\cmdlets\Get-Metadata.md
  144 C:\code\Documentation\reference\cmdlets\Remove-Metadata.md
  107 C:\code\Documentation\reference\cmdlets\Set-Metadata.md
  116 C:\code\Documentation\reference\cmdlets\Update-Metadata.md
```

## PARAMETERS

### -Path

Specify the path to one or more files or folders to get the metrics for. If you specify a folder,
the cmdlet returns metrics for every Markdown file in that folder.

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
-InformationAction, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`,
`-Verbose`, -WarningAction, and `-WarningVariable`. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

This cmdlet doesn't support any pipeline input.

## OUTPUTS

### ValeMetrics

This cmdlet returns a **ValeMetrics** object containing various counts for different components of
the prose, like words and paragraphs.

## NOTES

## RELATED LINKS
