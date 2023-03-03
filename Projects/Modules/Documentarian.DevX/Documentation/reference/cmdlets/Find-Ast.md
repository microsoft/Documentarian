---
title: Find-Ast
summary: Find-Ast...
external help file: Documentarian.DevX-help.xml
Module Name: Documentarian.DevX
online version:
schema: 2.0.0
---

# Find-Ast

## Synopsis

{{ Fill in the Synopsis }}

## Syntax

### FromAstInfo (Default)

```powershell
Find-Ast
 [-Recurse]
 [<CommonParameters>]
```

### FromAstInfoWithType

```powershell
Find-Ast
 -AstInfo <AstInfo>
 -Type <Type[]>
 [-Recurse]
 [<CommonParameters>]
```

### FromAstInfoWithPredicate

```powershell
Find-Ast
 -AstInfo <AstInfo>
 -Predicate <ScriptBlock[]>
 [-Recurse]
 [<CommonParameters>]
```

### FromPathWithType

```powershell
Find-Ast
 -Path <String>
 -Type <Type[]>
 [-Recurse]
 [<CommonParameters>]
```

### FromPathWithPredicate

```powershell
Find-Ast
 -Path <String>
 -Predicate <ScriptBlock[]>
 [-Recurse]
 [<CommonParameters>]
```

### FromScriptBlockWithType

```powershell
Find-Ast
 -ScriptBlock <ScriptBlock>
 -Type <Type[]>
 [-Recurse]
 [<CommonParameters>]
```

### FromScriptBlockWithPredicate

```powershell
Find-Ast
 -ScriptBlock <ScriptBlock>
 -Predicate <ScriptBlock[]>
 [-Recurse]
 [<CommonParameters>]
```

## Description

{{ Fill in the Description }}

## Examples

### Example 1

```powershell
{{ Add example code here }}
```

{{ Add example description here }}

## Parameters

### `-AstInfo`

{{ Fill AstInfo Description }}

```yaml
Type: AstInfo
Parameter Sets: FromAstInfoWithType, FromAstInfoWithPredicate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-Path`

{{ Fill Path Description }}

```yaml
Type: String
Parameter Sets: FromPathWithType, FromPathWithPredicate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-Predicate`

{{ Fill Predicate Description }}

```yaml
Type: ScriptBlock[]
Parameter Sets: FromAstInfoWithPredicate, FromPathWithPredicate, FromScriptBlockWithPredicate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-Recurse`

{{ Fill Recurse Description }}

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

### `-ScriptBlock`

{{ Fill ScriptBlock Description }}

```yaml
Type: ScriptBlock
Parameter Sets: FromScriptBlockWithType, FromScriptBlockWithPredicate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### `-Type`

{{ Fill Type Description }}

```yaml
Type: Type[]
Parameter Sets: FromAstInfoWithType, FromPathWithType, FromScriptBlockWithType
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`,
-InformationAction, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`,
`-Verbose`, `-WarningAction`, and `-WarningVariable`. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## Inputs

### None

## Outputs

### `System.Management.Automation.Language.Ast`

## Notes

## Related Links
