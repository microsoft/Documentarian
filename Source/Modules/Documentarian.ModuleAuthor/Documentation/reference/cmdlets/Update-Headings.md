---
external help file: sdwheeler.DocsHelpers-help.xml
Module Name: sdwheeler.DocsHelpers
online version:
schema: 2.0.0
---

# Update-Headings

## Synopsis
Changes the standard headings in `about_` files and cmdlet reference so title case.

## Syntax

```
Update-Headings [-Path] <String> [-Recurse] [<CommonParameters>]
```

## Description

Changes the standard headings in `about_` files and cmdlet reference so title case.

## Examples

### Example 1 - Update the heading for all files in a folder tree

```powershell
Update-Headings -Path ./reference/5.1/Microsoft.PowerShell.Core/*.md -Recurse
```

## Parameters

### -Path

The path the the Markdown files to be updated. Wildards are supported.

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
