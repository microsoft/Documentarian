---
external help file: Documentarian.AstInfo-help.xml
Locale: en-US
Module Name: Documentarian.AstInfo
online version: https://microsoft.github.io/Documentarian/modules/astinfo/reference/cmdlets/find-ast
schema: 2.0.0
title: Find-Ast
---

# Find-Ast

## SYNOPSIS
Finds ASTs by type or predicate in a script block, file, or AST.

## SYNTAX

### FromtAstInfo (Default)

```
Find-Ast [-Recurse] [<CommonParameters>]
```

### FromAstInfoWithType

```
Find-Ast -AstInfo <AstInfo> -Type <Type> [-Recurse] [<CommonParameters>]
```

### FromAstInfoWithPredicate

```
Find-Ast -AstInfo <AstInfo> -Predicate <ScriptBlock> [-Recurse] [<CommonParameters>]
```

### FromPathWithType

```
Find-Ast -Path <String> -Type <Type> [-Recurse] [<CommonParameters>]
```

### FromPathWithPredicate

```
Find-Ast -Path <String> -Predicate <ScriptBlock> [-Recurse] [<CommonParameters>]
```

### FromScriptBlockWithType

```
Find-Ast -ScriptBlock <ScriptBlock> -Type <Type> [-Recurse] [<CommonParameters>]
```

### FromScriptBlockWithPredicate

```
Find-Ast -ScriptBlock <ScriptBlock> -Predicate <ScriptBlock> [-Recurse] [<CommonParameters>]
```

### FromTargetAstWithType

```
Find-Ast -TargetAst <Ast> -Type <Type> [-Recurse] [<CommonParameters>]
```

### FromTargetAstWithPredicate

```
Find-Ast -TargetAst <Ast> -Predicate <ScriptBlock> [-Recurse] [<CommonParameters>]
```

## DESCRIPTION

The `Find-Ast` function looks searches an AST. You can specify the AST to search as an **AstInfo**
object, the path to a PowerShell script file, a script block, or a literal AST object. You can
either provide your own predicate, which is a scriptblock that determines whether the inspected AST
child object is one you're looking for, or the function can create one for you.

If you're not providing your own predicate, the function can only search by AST type.

## EXAMPLES

### Example 1

This example searches a scriptblock for an **AttributeAst**.

```powershell
Find-Ast -Type AttributeAst -ScriptBlock { [ValidateNotNull()]$x = 5 }
```

```output
PositionalArguments : {}
NamedArguments      : {}
TypeName            : ValidateNotNull
Extent              : [ValidateNotNull()]
Parent              : [ValidateNotNull()]$x
```

## PARAMETERS

### -AstInfo

The **AstInfo** object to search.

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

### -Path

The path to a PowerShell script file to parse and search.

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

### -Predicate

A scriptblock that returns `$true` if the inspected AST object meets your search criteria and
`$false` if it doesn't.

```yaml
Type: ScriptBlock
Parameter Sets: FromAstInfoWithPredicate, FromPathWithPredicate, FromScriptBlockWithPredicate, FromTargetAstWithPredicate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recurse

Whether to recursively search the children of AST objects. By default, the function searches only
the top level of the provided AST.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScriptBlock

The scriptblock to parse and search.

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

### -TargetAst

The literal AST object to search.

```yaml
Type: Ast
Parameter Sets: FromTargetAstWithType, FromTargetAstWithPredicate
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type

The type of AST object you're looking for. You can specify this parameter instead of writing your
own scriptblock for the **Predicate** parameter.

```yaml
Type: Type
Parameter Sets: FromAstInfoWithType, FromPathWithType, FromScriptBlockWithType, FromTargetAstWithType
Aliases:

Required: True
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

## OUTPUTS

### System.Management.Automation.Language.Ast[]

This function returns any **Ast** objects it finds in the provided AST that meet the criteria of
the specified **Type** or **Predicate** parameters.

## NOTES

## RELATED LINKS
