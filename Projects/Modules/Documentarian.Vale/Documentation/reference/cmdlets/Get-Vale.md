---
external help file: Documentarian.Vale-help.xml
Locale: en-US
Module Name: Documentarian.Vale
online version: https://microsoft.github.io/Documentarian/modules/vale/reference/cmdlets/get-vale
schema: 2.0.0
title: Get-Vale
---

# Get-Vale

## SYNOPSIS
Gets the command info for Vale installed in a workspace or on a machine.

## SYNTAX

```
Get-Vale [<CommonParameters>]
```

## DESCRIPTION

The `Get-Vale` cmdlet returns a **System.Management.Automation.ApplicationInfo** object for the
`vale` binary if it's available. It first checks the `PATH` environment variable and, if `vale`
isn't available, checks the `.vale` folder in the current working directory.

This cmdlet is a convenience helper for using Vale when installed to the workspace, as with the
[Install-WorkspaceVale](/modules/vale/reference/cmdlets/install-workspacevale) cmdlet.

## EXAMPLES

### Example 1: Get Vale and show its version

```powershell
$Vale = Get-Vale

& $Vale --version
```

```output
vale version 2.22.0
```

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`,
`-InformationAction`, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`,
`-Verbose`, `-WarningAction`, and `-WarningVariable`. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

This cmdlet doesn't support any pipeline input.

## OUTPUTS

### ValeApplicationInfo

This cmdlet returns a **ValeApplicationInfo** object, representing the same information as the
**System.Management.Automation.ApplicationInfo** type but with the **Version** property correctly
reflecting Vale's version.

## NOTES

## RELATED LINKS

[Install-WorkspaceVale](../install-workspacevale)
