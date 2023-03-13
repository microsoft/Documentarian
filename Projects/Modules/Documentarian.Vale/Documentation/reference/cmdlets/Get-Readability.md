---
external help file:
Module Name: Documentarian.Vale
online version: https://microsoft.github.io/Documentarian/modules/vale/reference/cmdlets/get-readability
schema: 2.0.0
ms.date: 03/13/2023
title: Get-Readability
---

# Get-Readability

## SYNOPSIS
Returns the readability score of a markdown using Vale.

## SYNTAX

```
Get-Readability [-Path] <String[]> [[-ReadabilityRule] <String>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet uses the Vale linter to get the readability score of a Markdown file.

## EXAMPLES

### Example 1 - Get the FleschKincaid score of a file

```powershell
Get-Readability reference\7.2\CimCmdlets\Get-CimAssociatedInstance.md FleschKincaid
```

```Output
Score Message                                                         File                         Metrics
----- -------                                                         ----                         -------
11.34 Flesch-Kincaid grade level is 11.34 -  try to target 8th grade. Get-CimAssociatedInstance.md ValeMetricsInfo
```

## PARAMETERS

### -Path

The path to a markdown file or a folder containing markdown files. Wildcards are supported.

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

### -ReadabilityRule

The name of the readability rule to run. The default value is `AutomatedReadability`.

The following values are accepted:

- `AutomatedReadability`
- `ColemanLiau`
- `FleschKincaid`
- `FleschReadingEase`
- `GunningFog`
- `LIX`
- `SMOG`

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:
Accepted values: AutomatedReadability, ColemanLiau, FleschKincaid, FleschReadingEase, GunningFog, LIX, SMOG

Required: False
Position: 1
Default value: AutomatedReadability
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

### PSObject

## NOTES

## RELATED LINKS

[Get-ProseMetric](Get-ProseMetric.md)
