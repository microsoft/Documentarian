---
external help file: Documentarian.MicrosoftDocs-help.xml
Module Name: Documentarian.MicrosoftDocs
online version: https://microsoft.github.io/Documentarian/modules/microsoftdocs/reference/cmdlets/get-cmdletxref
schema: 2.0.0
title: Get-CmdletXref
---

# Get-CmdletXref

## SYNOPSIS
Gets a cross-reference link for a command.

## SYNTAX

```
Get-CmdletXref [-Name] <System.String[]> [<CommonParameters>]
```

## DESCRIPTION

Outputs a Learn platform cross-reference hyperlink for a command in Markdown syntax. The command can
be an alias, the name of a proxy command, or the name of a cmdlet published in a module. The module
must be installed on the local system.

## EXAMPLES

### Example 1: Get a cross-reference link for some commands

```powershell
Get-CmdletXref Get-Command, Get-Help
```

```Output
[Get-Command](xref:Microsoft.PowerShell.Core.Get-Command)
[Get-Help](xref:Microsoft.PowerShell.Core.Get-Help)
```

### Example 2: Pipe multiple commands to Get-CmdletXref

In this example, `oss` and `help` are proxy commands for the `Out-String` and `Get-Help` cmdlets.

```powershell
'oss','help','gcm', 'git', 'foo' | Get-CmdletXref -Verbose
```

```Output
[Out-String](xref:Microsoft.PowerShell.Utility.Out-String)
[Get-Help](xref:Microsoft.PowerShell.Core.Get-Help)
VERBOSE: gcm is an alias for Get-Command
[Get-Command](xref:Microsoft.PowerShell.Core.Get-Command)
VERBOSE: git.exe is a(n) Application
WARNING: Unable to find command foo
```

The cross-reference links for successfully resolved commands are written to the **Success** output
stream.

### Example 3: Pipe results to the clipboard

In this example, `oss` and `help` are proxy commands for the `Out-String` and `Get-Help` cmdlets.

```powershell
'oss','help','gcm', 'git', 'foo' | Get-CmdletXref -Verbose | Set-Clipboard
```

```Output
VERBOSE: gcm is an alias for Get-Command
VERBOSE: git.exe is a(n) Application
WARNING: Unable to find command foo
```

The cross-reference links for successfully resolved commands are written to the **Success** output
stream and copied to the clipboard.

## PARAMETERS

### -Name

The name of the command to get a cross-reference link for.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:
Accepted values:

Required: True (All) False (None)
Position: 0
Default value:
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## OUTPUTS

### System.String[]

## NOTES

## RELATED LINKS
