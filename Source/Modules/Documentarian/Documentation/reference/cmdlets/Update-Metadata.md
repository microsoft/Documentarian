---
external help file: sdwheeler.DocsHelpers-help.xml
Module Name: sdwheeler.DocsHelpers
ms.date: 09/09/2021
schema: 2.0.0
---

# Update-Metadata

## Synopsis
Updates or adds metadata to a Markdown file.

## Syntax

```
Update-Metadata [[-Path] <String>] [[-NewMetadata] <Hashtable>] [-Recurse] [<CommonParameters>]
```

## Description

Updates or adds metadata to a Markdown file. The existing keys in the frontmatter are update with
the new values. New keys are added to the frontmatter.

## Examples

### Example 1 - Update the **ms.date** metadata for all Markdown files

```powershell
Update-Metadata *.md -NewMetadata @{'ms.date' = Get-Date -Format 'MM/dd/yyyy' }
```

## Parameters

### -NewMetadata

This is a hashtable of key-value pairs to be written to the Markdown file.

```yaml
Type: System.Collections.Hashtable
Parameter Sets: (All)
Aliases:

Required: False
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

Required: False
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

[Remove-Metadata](Update-Metadata.md)

[Set-Metadata](Set-Metadata.md)
