---
external help file: Documentarian.AstInfo-help.xml
Locale: en-US
Module Name: Documentarian.AstInfo
online version: https://microsoft.github.io/Documentarian/modules/astinfo/reference/cmdlets/get-asttype
schema: 2.0.0
title: Get-AstType
---

# Get-AstType

## SYNOPSIS
Gets AST types from the current AppDomain with optional filters.

## SYNTAX

### ByPattern (Default)

```
Get-AstType -Pattern <String> [<CommonParameters>]
```

### ByName

```
Get-AstType -Name <String[]> [<CommonParameters>]
```

## DESCRIPTION

The `Get-AstType` function returns a list of AST types, optionally filtered. You can filter the list
of known AST types by type name or a regular expression pattern against the type name.

## EXAMPLES

### Example 1

This example shows filtering AST types by a regular expression pattern.

```powershell
Get-AstType -Pattern Type*
```

```output
IsPublic IsSerial Name              BaseType
-------- -------- ----              --------
True     False    TypeConstraintAst System.Management.Automation.Language.AttributeBaseAst
True     False    TypeDefinitionAst System.Management.Automation.Language.StatementAst
True     False    TypeExpressionAst System.Management.Automation.Language.ExpressionAst
```

## PARAMETERS

### -Name

Specify a name to look for in the list of AST types; the "Ast" suffix is optional

```yaml
Type: String[]
Parameter Sets: ByName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Pattern

Specify a valid regular expression pattern to match in the list of AST types.

```yaml
Type: String
Parameter Sets: ByPattern
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

### System.Type[]

This function returns one or more objects representing the type information of the filtered AST
types.

## NOTES

## RELATED LINKS
