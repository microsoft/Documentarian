---
external help file: Documentarian.AstInfo-help.xml
Locale: en-US
Module Name: Documentarian.AstInfo
online version: https://microsoft.github.io/Documentarian/modules/astinfo/reference/cmdlets/new-astpredicate
schema: 2.0.0
title: New-AstPredicate
---

# New-AstPredicate

## SYNOPSIS
Returns a scriptblock predicate for finding ASTs of a particular type.

## SYNTAX

```
New-AstPredicate [[-Type] <Type>] [<CommonParameters>]
```

## DESCRIPTION

The `New-AstPredicate` returns a valid scriptblock you can use to search a PowerShell abstract
syntax tree (AST) for the specified type.

## EXAMPLES

### Example 1

This example shows creating a predicate to search for a variable expression in a script block.

```powershell
$predicate = New-AstPredicate -Type VariableExpression
Find-Ast -Predicate $predicate -ScriptBlock {
    [ValidateNotNull]$x = 5
}
```

```output
VariablePath : x
Splatted     : False
StaticType   : System.Object
Extent       : $x
Parent       : [ValidateNotNull]$x
```

## PARAMETERS

### -Type

The AST type to create a predicate to search for in an AST. The type must be a valid AST type or
the name of a valid AST type as a string. The `Ast` suffix is optional when the value is a string.

```yaml
Type: Type
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`,
`-InformationAction`, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`,
`-Verbose`, `-WarningAction`, and `-WarningVariable`. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.ScriptBlock

The function returns a scriptblock that you can use as the predicate to search an AST for the
specified type.

## NOTES

## RELATED LINKS
