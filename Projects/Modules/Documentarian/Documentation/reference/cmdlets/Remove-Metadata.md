---
external help file: Documentarian-help.xml
Locale: en-US
Module Name: Documentarian
online version: https://microsoft.github.io/Documentarian/modules/documentarian/reference/cmdlets/remove-metadata
schema: 2.0.0
title: Remove-Metadata
---

# Remove-Metadata

## SYNOPSIS
Removes metadata key-value pairs from the YAML frontmatter of a Markdown file.

## SYNTAX

```
Remove-Metadata [-Path] <string> [-KeyName] <string[]> [-Recurse] [<CommonParameters>]
```

## DESCRIPTION

Removes metadata key-value pairs from the YAML frontmatter of a Markdown file. List the keys names
you want to remove from the frontmatter. This is useful for removing obsolete metadata values.

## EXAMPLES

### Example 1 - Remove obsolete metadata values

In this example, the target Markdown file contains two obsolete keys: **keywords** and
**ms.assetid**.

```powershell
Get-Metadata .\install\Installing-PowerShell-Core-on-Windows.md
```

```Output
Name                           Value
----                           -----
description                    Information about installing PowerShell on Windows
keywords                       powershell, cmdlets
title                          Installing PowerShell on Windows
ms.date                        08/02/2021
ms.assetid                     3a0fc6a8-dfe3-4852-bda4-2ea4a7a1917f
```

```powershell
Remove-Metadata -KeyName keywords,'ms.assetid'
Get-Metadata .\install\Installing-PowerShell-Core-on-Windows.md
```

```Output
Name                           Value
----                           -----
description                    Information about installing PowerShell on Windows
title                          Installing PowerShell on Windows
ms.date                        08/02/2021
```

## PARAMETERS

### -KeyName

The name of the metadata key to be removed. This can be a comma-delimited list of names.

```yaml
Type: System.String[]
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

[Get-Metadata](Get-Metadata.md)

[Set-Metadata](Set-Metadata.md)

[Update-YamlBlock](Update-Metadata.md)
