---
external help file: Documentarian-help.xml
Module Name: Documentarian
ms.date: 02/07/2023
schema: 2.0.0
title: Get-YamlBlock
---

# Get-YamlBlock

## SYNOPSIS
Gets the YAML frontmatter from a Markdown file.

## SYNTAX

```
Get-YamlBlock [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION

The cmdlet returns the YAML frontmatter from a Markdown file. The output is returned as plain text
and does not include the `---` document separator lines.

## EXAMPLES

### Example 1

```powershell
Get-YamlBlock .\install\Installing-PowerShell-Core-on-Windows.md
```

```Output
title: Installing PowerShell on Windows
description: Information about installing PowerShell on Windows
ms.date: 08/02/2021
```

## PARAMETERS

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

### COMMONPARAMETERS

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Get-Metadata](Get-Metadata.md)

[hash2yaml](hash2yaml.md)
