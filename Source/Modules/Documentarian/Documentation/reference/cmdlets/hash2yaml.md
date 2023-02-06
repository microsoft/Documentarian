---
external help file: sdwheeler.DocsHelpers-help.xml
Module Name: sdwheeler.DocsHelpers
ms.date: 09/09/2021
schema: 2.0.0
---

# hash2yaml

## Synopsis
Converts a hashtable containing metadata key-value pairs into YAML frontmatter.

## Syntax

```
hash2yaml [[-MetaHash] <Hashtable>] [<CommonParameters>]
```

## Description

The helper function converts a hashtable containing metadata key-value pairs into YAML frontmatter.
The output is suitable for copying into the frontmatter of a Markdown file.

## Examples

### Example 1 - Convert metadata hashtable to YAML

```powershell
$metadata = @{
    'ms.date' = Get-Date -Format 'MM/dd/yyyy'
    description = 'Information about installing PowerShell on Windows'
    title = 'Installing PowerShell on Windows'
}
hash2yaml $metadata
```

```Output
---
description: Information about installing PowerShell on Windows
ms.date: 09/09/2021
title: Installing PowerShell on Windows
---
```

## Parameters

### -MetaHash

The hashtable containing the metadata key-value pairs.

```yaml
Type: System.Collections.Hashtable
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

[Get-YamlBlock](Get-YamlBlock.md)
