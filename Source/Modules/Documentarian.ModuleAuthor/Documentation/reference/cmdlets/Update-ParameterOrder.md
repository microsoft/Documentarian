---
external help file: sdwheeler.DocsHelpers-help.xml
Module Name: sdwheeler.DocsHelpers
ms.date: 02/24/2023
schema: 2.0.0
title: Sort-Parameters
---

# Update-ParameterOrder

## SYNOPSIS
Sorts the H3 parameter blocks of a cmdlet Markdown file.

## SYNTAX

```
Sort-Parameters [-Path] <string[]> [<CommonParameters>]
```

## DESCRIPTION

The PowerShell-Docs style guide recommends that the H3 parameter blocks of a cmdlet Markdown file be
sorted alphabetically with the **Confirm** and **WhatIf** parameters at the end of the list.
However, much of the existing reference content was created before this recommendation. Therefore,
not all cmdlet files are ordered this way.

This cmdlet allows you to easily reorder the parameters.

## EXAMPLES

### Example 1 - Sort the parameter blocks of all Markdown files in a folder

```powershell
Sort-Parameters .\7.1\Microsoft.PowerShell.Utility\*-*.md
```

## PARAMETERS

### -Path

The path to the Markdown file. This can be a path to a folder containing Markdown files. Wildcards
are allowed.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### COMMONPARAMETERS

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.IO.FileInfo

This cmdlet returns the **FileInfo** object for each Markdown file processed.

## NOTES

## RELATED LINKS
