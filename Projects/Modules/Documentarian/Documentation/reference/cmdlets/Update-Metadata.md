---
external help file: Documentarian-help.xml
Locale: en-US
Module Name: Documentarian
online version: https://microsoft.github.io/Documentarian/modules/documentarian/reference/cmdlets/update-metadata
schema: 2.0.0
title: Update-Metadata
---

# Update-Metadata

## SYNOPSIS
Updates or adds metadata to a Markdown file.

## SYNTAX

```
Update-Metadata [-Path] <string> [-NewMetadata] <hashtable> [-Recurse] [<CommonParameters>]
```

## DESCRIPTION

Updates or adds metadata to a Markdown file. The existing keys in the frontmatter are update with
the new values. New keys are added to the frontmatter.

## EXAMPLES

### Example 1 - Update the **ms.date** metadata for all Markdown files

```powershell
Update-Metadata *.md -NewMetadata @{'ms.date' = Get-Date -Format 'MM/dd/yyyy' }
```

## PARAMETERS

### -NewMetadata

This is a hashtable of key-value pairs to be written to the Markdown file.

```yaml
Type: System.Collections.Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

The path to the Markdown file. This can be a path to a folder containing Markdown files. Wildcards
are allowed.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -Recurse

Cause the cmdlet to recursively search for Markdown files in the matching **Path** and all
subfolders.

```yaml
Type: System.Management.Automation.SwitchParameter
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

[Get-Metadata](Get-Metadata.md)

[Remove-Metadata](Update-Metadata.md)

[Set-Metadata](Set-Metadata.md)
