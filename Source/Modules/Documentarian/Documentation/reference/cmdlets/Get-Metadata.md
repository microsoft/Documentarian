---
external help file: Documentarian-help.xml
Module Name: Documentarian
ms.date: 02/07/2023
schema: 2.0.0
title: Get-Metadata
---

# Get-Metadata

## SYNOPSIS

Get the metadata frontmatter from a Markdown file.

## SYNTAX

### AsHash

```
Get-Metadata [-Path] <string> [-Recurse] [<CommonParameters>]
```

### AsObject

```
Get-Metadata [-Path] <string> -AsObject [-Recurse] [<CommonParameters>]
```

### AsYaml

```
Get-Metadata [-Path] <string> -AsYaml [-Recurse] [<CommonParameters>]
```

## DESCRIPTION

Get the metadata frontmatter from a Markdown file. By default the data is returned as a
**hashtable** object. It can also be returned as a **PSObject** or as raw Yaml formatted text.

## EXAMPLES

### Example 1 - Get the metadata header as a hashtable

```powershell
Get-Metadata .\install\Installing-PowerShell-on-Windows.md
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
Get-Metadata .\install\Installing-PowerShell-on-Windows.md -AsObject | Format-list
```

```Output
description : Information about installing PowerShell on Windows
file        : C:\Git\PS-Docs\PowerShell-Docs\reference\docs-conceptual\install\Installing-PowerShell-on-Windows.md
title       : Installing PowerShell on Windows
ms.date     : 08/02/2021
```

### Example 3 - Get the metadata header as raw Yaml

```powershell
Get-Metadata .\install\Installing-PowerShell-on-Windows.md -AsYaml
```

```Output
description: Information about installing PowerShell on Windows
ms.date: 01/09/2023
title: Installing PowerShell on Windows
```

## PARAMETERS

### -AsObject

Returns the metadata as a **PSObject**. Unlike the hashtable, the object includes the original file
path as a property.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: AsObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsYaml

Returns the raw Yaml metadata frontmatter.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: AsYaml
Aliases:

Required: True
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

### CommonParameters

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

[Remove-Metadata](Remove-Metadata.md)

[Set-Metadata](Set-Metadata.md)

[Update-Metadata](Update-Metadata.md)
