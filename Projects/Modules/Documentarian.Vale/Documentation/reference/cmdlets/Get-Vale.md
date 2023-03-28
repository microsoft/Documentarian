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
Gets the command info for Vale installed in a workspace, user's home folder, or on a machine.

## SYNTAX

```
Get-Vale [<CommonParameters>]
```

## DESCRIPTION

The `Get-Vale` cmdlet returns a **System.Management.Automation.ApplicationInfo** object for the
`vale` binary if it's available. It first checks for the `vale` application in the following order,
returning the first discovered application:

1. It checks the `.vale` folder in the current working directory.
1. It walks the directory tree up from the current working directory, checking the `.vale` folder
   in each parent directory.
1. It checks the `.vale` folder in the user's home directory.
1. It checks the folders listed in the `PATH` environment variable.

The cmdlet returns an error if it doesn't find the `vale` application.

This cmdlet is a convenience helper for using Vale when installed to the workspace or user's home
directory, as with the [Install-Vale](/modules/vale/reference/cmdlets/install-vale) cmdlet.

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

[Install-Vale](../install-vale)
