---
external help file: Documentarian-help.xml
Module Name: Documentarian
ms.date: 02/07/2023
schema: 2.0.0
title: Set-Metadata
---

# Set-Metadata

## SYNOPSIS
Overwrites the metadata frontmatter in a Markdown file.

## SYNTAX

```
Set-Metadata [[-Path] <String>] [[-NewMetadata] <Hashtable>] [-Recurse] [<CommonParameters>]
```

## DESCRIPTION

Overwrites the metadata frontmatter in a Markdown file. The existing frontmatter is replaced with
the values in the **NewMetadata** hashtable.

## EXAMPLES

### Example 1 - Replace the existing metadata with new values

```powershell
$newvalues = @{
    'ms.date' = Get-Date -Format 'MM/dd/yyyy'
    test='foo'
}
Update-Metadata .\docs\*.md -NewMetadata $newvalues
```

## PARAMETERS

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

[Get-Metadata](Get-Metadata)

[Remove-Metadata](Remove-Metadata.md)

[Update-Metadata](Update-Metadata.md)
