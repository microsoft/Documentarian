---
external help file: Documentarian.AstInfo-help.xml
Locale: en-US
Module Name: Documentarian.AstInfo
online version: https://microsoft.github.io/Documentarian/modules/astinfo/reference/cmdlets/get-astinfo
schema: 2.0.0
title: Get-AstInfo
---

# Get-AstInfo

## SYNOPSIS
Gets an AstInfo object from a script block, file, or text.

## SYNTAX

### ByPath

```
Get-AstInfo -Path <String> [<CommonParameters>]
```

### ByScriptBlock

```
Get-AstInfo -ScriptBlock <ScriptBlock> [<CommonParameters>]
```

### ByInputText

```
Get-AstInfo -Text <String> [<CommonParameters>]
```

## DESCRIPTION

The `Get-AstInfo` function parses a PowerShell script file, a scriptblock, or an arbitrary string
of text as PowerShell and returns an **AstInfo** object. The **AstInfo** object includes the parsed
abstract syntax tree (AST), the parsed tokens, and any errors raised while parsing the input.

## EXAMPLES

### Example 1

```powershell
Get-AstInfo -ScriptBlock { [ValidateNotNull]$x = 5 }
```

```output
Ast                       Tokens                      Errors
---                       ------                      ------
 [ValidateNotNull]$x = 5  {[, ValidateNotNull, ], x…} {}
```

{{ Add example description here }}

## PARAMETERS

### -Path

The path to a PowerShell script file to parse.

```yaml
Type: String
Parameter Sets: ByPath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScriptBlock

A scriptblock to parse.

```yaml
Type: ScriptBlock
Parameter Sets: ByScriptBlock
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Text

An arbitrary string to parse as PowerShell.

```yaml
Type: String
Parameter Sets: ByInputText
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

### AstInfo

This function outputs an **AstInfo** object with the parsed information.

## NOTES

## RELATED LINKS
