---
external help file: sdwheeler.ContentUtils-help.xml
Module Name: sdwheeler.ContentUtils
online version:
ms.date: 02/15/2023
schema: 2.0.0
---

# ConvertTo-Contraction

## SYNOPSIS
Converts common word pairs to contractions in a Markdown document.

## SYNTAX

```
ConvertTo-Contraction [-Path] <String[]> [-Recurse] [<CommonParameters>]
```

## DESCRIPTION

The Microsoft Style Guide recommends using contractions in our documentation. The cmdlet updates
markdown files by replacing common word pairs with contractions. You can update multiple files by
specifying a comma-separated list of paths to file or folders and include wildcards.

## EXAMPLES

### Example 1 - Update all files in a folder

For this example, assume you are in the root of the **azure-docs-pr** repository. The following
command updates all the markdown files in the `articles\cloud-shell` folder.

```powershell
ConvertTo-Contraction -Path articles\cloud-shell\*.md
```

## PARAMETERS

### -Path

The path to one or more files or folders containing files. The parameter supports wildcards.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -Recurse

When provided the cmdlet search subfolders for files that match the **Path** parameter value.

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

### None

## NOTES

## RELATED LINKS
