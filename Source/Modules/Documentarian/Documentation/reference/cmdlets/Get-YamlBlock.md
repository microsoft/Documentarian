---
external help file: sdwheeler.DocsHelpers-help.xml
Module Name: sdwheeler.DocsHelpers
ms.date: 09/09/2021
schema: 2.0.0
---

# Get-YamlBlock

## Synopsis
Gets the YAML frontmatter from a Markdown file.

## Syntax

```
Get-YamlBlock [[-Path] <String>] [<CommonParameters>]
```

## Description

The cmdlet returns the YAML frontmatter from a Markdown file. The output is returned as plain text
and does not include the `---` document separator lines.

## Examples

### Example 1

```powershell
Get-YamlBlock .\install\Installing-PowerShell-Core-on-Windows.md
```

```Output
title: Installing PowerShell on Windows
description: Information about installing PowerShell on Windows
ms.date: 08/02/2021
```

## Parameters

### -Path

The path to a single Markdown file.

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

## Related links

[Get-Metadata](Get-Metadata.md)

[hash2yaml](hash2yaml.md)
