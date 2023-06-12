---
external help file: Documentarian.AstInfo-help.xml
Locale: en-US
Module Name: Documentarian.AstInfo
online version: https://microsoft.github.io/Documentarian/modules/astinfo/reference/cmdlets/test-isasttype
schema: 2.0.0
title: Test-IsAstType
---

# Test-IsAstType

## SYNOPSIS
Determines if a type is an AST type.

## SYNTAX

```
Test-IsAstType [[-Type] <Type>] [<CommonParameters>]
```

## DESCRIPTION

The `Test-IsAstType` function verifies whether a given type is an AST type. If the type inherits
from **System.Management.Automation.Language.Ast**, the function returns `$true`. If it isn't, the
function returns `$false`.

## EXAMPLES

### Example 1

This example shows testing arbitrary types.

```powershell
Test-IsAstType -Type ([System.Management.Automation.Language.AttributeAst])
Test-IsAstType -Type ([string])
```

```output
True
False
```

## PARAMETERS

### -Type

A **System.Type** object to check as an AST type.

```yaml
Type: Type
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
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

### System.Boolean

This function returns `$true` if the input object is a valid AST type and `$false` otherwise.

## NOTES

## RELATED LINKS
