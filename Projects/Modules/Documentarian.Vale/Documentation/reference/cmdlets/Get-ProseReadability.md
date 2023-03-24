---
external help file: Documentarian.Vale-help.xml
Module Name: Documentarian.Vale
online version: https://microsoft.github.io/Documentarian/modules/vale/reference/cmdlets/get-prosereadability
schema: 2.0.0
ms.date: 03/13/2023
title: Get-ProseReadability
---

# Get-ProseReadability

## SYNOPSIS
Returns the readability score of a markdown using Vale.

## SYNTAX

### ByRule (Default)

```
Get-Readability
 [-Path] <String[]>
 [[-ReadabilityRule] <ValeReadabilityRule[]>]
 [-Threshold <Single>]
 [-ProblemsOnly]
 [<CommonParameters>]
```

### Preset

```
Get-Readability
 [-Path] <String[]>
 [-Preset <String>]
 [-ProblemsOnly]
 [<CommonParameters>]
```

### AllRules

```
Get-Readability
 [-Path] <String[]>
 [-All]
 [-ProblemsOnly]
 [<CommonParameters>]
```

## DESCRIPTION

This cmdlet uses the Vale linter to get the readability score of a Markdown file.

## EXAMPLES

### Example 1 - Get the FleschKincaid score of a file

```powershell
Get-Readability reference\7.2\CimCmdlets\Get-CimAssociatedInstance.md FleschKincaid
```

```Output
Rule                   Score                Threshold            File
----                   -----                ---------            ----
FleschKincaid          11th Grade           8th Grade            Get-CimAssociatedInstance.md
```

## PARAMETERS

### -All

Indicates that the cmdlet should return the readability scores for all known rules.

```yaml
Type: SwitchParameter
Parameter Sets: AllRules
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

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

### -Preset

Indicates that the cmdlet should return readability scores for a predefined group of rules. Specify
`GradeLevels` to return only the readability scores for rules that map to US school grade levels.
Specify `Numericals` to return only the readability scores for rules that don't map to a grade
level.

```yaml
Type: String
Parameter Sets: Preset
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProblemsOnly

Indicates that the cmdlet should only return readability scores when the score doesn't meet the
rule's defined threshold.

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

### -ReadabilityRule

Specify the name of one or more readability rules to run. The default value is
`AutomatedReadability`.

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

### -Recurse

Indicates that the cmdlet should get the readability scores for the Markdown files in child folders.

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

### -Threshold

Specify an alternative target to check the readability score against. When specified with more than
one rule, this value overwrites them all.

Every rule has its own pre-defined **Threshold**.

```yaml
Type: Single
Parameter Sets: ByRule
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`,
`-InformationAction`, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`,
`-Verbose`, `-WarningAction`, and `-WarningVariable`. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### ValeReadability

### ValeMetricsAutomatedReadability

### ValeMetricsColemanLiau

### ValeMetricsFleschKincaid

### ValeMetricsFleschReadingEase

### ValeMetricsGunningFog

### ValeMetricsLIX

### ValeMetricsSMOG

## NOTES

## RELATED LINKS

[Get-ProseMetric](Get-ProseMetric.md)
