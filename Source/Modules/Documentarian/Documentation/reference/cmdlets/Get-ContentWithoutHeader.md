---
external help file: sdwheeler.DocsHelpers-help.xml
Module Name: sdwheeler.DocsHelpers
ms.date: 09/09/2021
schema: 2.0.0
---

# Get-ContentWithoutHeader

## Synopsis
Gets the content of a Markdown file without the YAML frontmatter.

## Syntax

```
Get-ContentWithoutHeader [[-Path] <String>] [<CommonParameters>]
```

## Description

The cmdlet gets the content of a Markdown file without the YAML frontmatter. This is useful when
updating the metadata of the file or for passing Markdown text to another command for processing.

## Examples

### Example 1 - Render the Markdown file as HTML

This example passes the Markdown content to `ConvertFrom-Markdown` to convert it to HTML.

```powershell
Get-ContentWithoutHeader .\Update-Metadata.md |
    ConvertFrom-Markdown |
    Select-Object -ExpandProperty Html
```

## Parameters

### -Path

The path to the Markdown file.

```yaml
Type: System.Object
Parameter Sets: (All)
Aliases:

Required: False
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

## Inputs

### None

## Outputs

### System.Object

## Notes

See the source code for `Update-Metadata` for another example.

## Related links
