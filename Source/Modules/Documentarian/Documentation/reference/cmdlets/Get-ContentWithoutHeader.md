---
external help file: Documentarian-help.xml
Module Name: Documentarian
ms.date: 02/07/2023
schema: 2.0.0
title: Get-ContentWithoutHeader
---

# Get-ContentWithoutHeader

## SYNOPSIS

Gets the content of a Markdown file without the YAML frontmatter.

## SYNTAX

```
Get-ContentWithoutHeader [-Path] <string> [<CommonParameters>]
```

## DESCRIPTION

The cmdlet gets the content of a Markdown file without the YAML frontmatter. This is useful when
updating the metadata of the file or for passing Markdown text to another command for processing.

## EXAMPLES

### Example 1 - Render the Markdown file as HTML

This example passes the Markdown content to `ConvertFrom-Markdown` to convert it to HTML.

```powershell
Get-ContentWithoutHeader .\Update-Metadata.md |
    ConvertFrom-Markdown |
    Select-Object -ExpandProperty Html
```

## PARAMETERS

### -Path

The path to the Markdown file.

```yaml
Type: System.Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

See the source code for `Update-Metadata` for another example.

## RELATED LINKS
