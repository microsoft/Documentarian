---
external help file: Documentarian.Vale-help.xml
Module Name: Documentarian.Vale
online version: https://microsoft.github.io/Documentarian/modules/vale/reference/cmdlets/
schema: 2.0.0
title: Sync-Vale
---

## SYNOPSIS

Installs or updates the Vale style packages for a configuration.

## SYNTAX

```
Sync-Vale [<CommonParameters>]
```

## DESCRIPTION

The `Sync-Vale` cmdlet installs or updates the Vale style packages for a configuration. If the
style packages don't exist in the configured style path, the cmdlet installs them there. If the
style packages exist, the cmdlet updates them if needed.

## EXAMPLES

### Example 1: Sync style packages

This example installs missing style packages and updates existing ones.

```powershell
Sync-Vale
```

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`,
-InformationAction, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`,
`-Verbose`, -WarningAction, and `-WarningVariable`. For more information, see
[about_CommonParameters][acp].

## INPUTS

### None

This cmdlet doesn't support any pipeline input.

## OUTPUTS

### System.Object

This cmdlet passes through the progress information from Vale itself.

## NOTES

## RELATED LINKS

<!-- Link reference definitions -->
[acp]: http://go.microsoft.com/fwlink/?LinkID=113216
