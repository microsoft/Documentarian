---
external help file: Documentarian.ModuleAuthor-help.xml
Locale: en-US
Module Name: Documentarian.ModuleAuthor
online version: https://microsoft.github.io/Documentarian/modules/moduleauthor/reference/cmdlets/update-headings
schema: 2.0.0
title: Update-Headings
---

# Update-Headings

## SYNOPSIS
Changes the standard headings in `about_` files and cmdlet reference to title case.

## SYNTAX

```
Update-Headings [-Path] <String> [-Recurse] [<CommonParameters>]
```

## DESCRIPTION

Changes the standard headings in `about_` files and cmdlet reference to title case.

## EXAMPLES

### Example 1 - Update the heading for all files in a folder tree

```powershell
Update-Headings -Path ./reference/5.1/Microsoft.PowerShell.Core/*.md -Recurse
```

## PARAMETERS

### -Path

The path to the Markdown files to be updated. Wildards are supported.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -Recurse

Use this parameter to search all subfolders of the specified **Path**.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
