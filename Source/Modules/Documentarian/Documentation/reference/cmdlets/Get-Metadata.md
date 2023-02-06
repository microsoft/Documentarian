---
external help file: sdwheeler.DocsHelpers-help.xml
Module Name: sdwheeler.DocsHelpers
ms.date: 09/09/2021
schema: 2.0.0
---

# Get-Metadata

## Synopsis
Get the metadata frontmatter from a Markdown file.

## Syntax

```
Get-Metadata [[-Path] <String>] [-Recurse] [-AsObject] [<CommonParameters>]
```

## Description

Get the metadata frontmatter from a Markdown file. By default the data is returned as a
**hashtable** object. It can also be returned as a **PSObject**.

## Examples

### Example 1 - Get the metadata header as a hashtable

```powershell
Get-Metadata .\install\Installing-PowerShell-Core-on-Windows.md
```

```Output
Name                           Value
----                           -----
description                    Information about installing PowerShell on Windows
title                          Installing PowerShell on Windows
ms.date                        08/02/2021
```

### Example 2 - Get the metadata header as an object

```powershell
Get-Metadata .\install\Installing-PowerShell-Core-on-Windows.md -AsObject | Format-list
```

```Output
description : Information about installing PowerShell on Windows
file        : C:\Git\PS-Docs\PowerShell-Docs\reference\docs-conceptual\install\Installing-PowerShell-Core-on-Windows.md
title       : Installing PowerShell on Windows
ms.date     : 08/02/2021
```

## Parameters

### -AsObject

Returns the metadata as a **PSObject**. Unlike the hashtable, the object include the original file
path as a property.

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

[Get-YamlBlock](Get-YamlBlock.md)

[Remove-Metadata](Remove-Metadata.md)

[Set-Metadata](Set-Metadata.md)

[Update-Metadata](Update-Metadata.md)

[hash2yaml](hash2yaml.md)
