---
title: Get-AstType
summary: Get-AstType...
external help file: Documentarian.DevX-help.xml
Module Name: Documentarian.DevX
online version:
schema: 2.0.0
---

# Get-AstType

## Synopsis

{{ Fill in the Synopsis }}

## SYNTAX

### ByPattern (Default)

```powershell
Get-AstType
 -Pattern <String>
 [<CommonParameters>]
```

### ByName

```powershell
Get-AstType
 -Name <String[]>
 [<CommonParameters>]
```

## Description

{{ Fill in the Description }}

## Examples

### Example 1

```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## Parameters

### `-Name`

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

### `-Pattern`

Specify a valid regex pattern to match in the list of AST types

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
-InformationAction, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`,
`-Verbose`, `-WarningAction`, and `-WarningVariable`. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## Inputs

### None

## Outputs

### `System.Type`

## Notes

## Related Links
