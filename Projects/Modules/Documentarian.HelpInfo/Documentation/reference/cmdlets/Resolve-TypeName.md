---
external help file: Documentarian.AstInfo-help.xml
Locale: en-US
Module Name: Documentarian.AstInfo
online version: https://microsoft.github.io/Documentarian/modules/astinfo/reference/cmdlets/resolve-typename
schema: 2.0.0
title: Resolve-TypeName
---

# Resolve-TypeName

## SYNOPSIS
Resolves a TypeName object to the type's full name through reflection.

## SYNTAX

```
Resolve-TypeName [-TypeName] <Object> [<CommonParameters>]
```

## DESCRIPTION

The `Resolve-TypeName` function resolves a **System.Management.Automation.Language.TypeName** or
**System.Management.Automation.Language.ArrayTypeName** object to the type's full name as a string.

This is useful for retrieving a type's full name through reflection. If the function can't
successfully retrieve the full type name from reflection, it implies the type is unknown. In that
case, the function returns the type name as a string, but without the assurance that it's the full
type name.

When you're inspecting an AST, parameters and properties have their type information as an
attribute that has the **TypeName** property. You can use this function to fully resolve those
type names from the AST.

## EXAMPLES

### Example 1

This example shows how you can resolve the type name of a parameter from the AST.

```powershell
$parameter = Find-Ast -Type Parameter -Recurse -ScriptBlock {
    param([string]$x)
}
$parameter
$parameter.Attributes
Resolve-TypeName -TypeName $parameter.Attributes[0].TypeName
```

```output
Attributes   : {string}
Name         : $x
DefaultValue :
StaticType   : System.String
Extent       : [string]$x
Parent       : param([string]$x)

TypeName : string
Extent   : [string]
Parent   : [string]$x

System.String
```

## PARAMETERS

### -TypeName

The **TypeName** or **ArrayTypeName** to resolve to a full type name.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
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

### System.String

This function returns the resolved full type name of the input object as a string.

## NOTES

## RELATED LINKS
