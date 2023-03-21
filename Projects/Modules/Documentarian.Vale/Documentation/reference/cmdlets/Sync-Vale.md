---
external help file: Documentarian.Vale-help.xml
Locale: en-US
Module Name: Documentarian.Vale
online version: https://microsoft.github.io/Documentarian/modules/vale/reference/cmdlets/sync-vale
schema: 2.0.0
title: Sync-Vale
---

# Sync-Vale

## SYNOPSIS
Installs or updates the Vale style packages for a configuration.

## SYNTAX

```
Sync-Vale [-Path <String>] [<CommonParameters>]
```

## DESCRIPTION

The `Sync-Vale` cmdlet installs or updates the Vale style packages for a configuration. If the
style packages don't exist in the configured style path, the cmdlet installs them there. If the
style packages exist, the cmdlet updates them if needed.

By default, this cmdlet synchronizes the `.vale.ini` configuration file in the current working
directory.

You can use the **Path** parameter to install or update the Vale style packages for a configuration
in a different folder or with a different name.

## EXAMPLES

### Example 1: Sync style packages

This example installs missing style packages and updates existing ones.

```powershell
Sync-Vale
```

## PARAMETERS

### -Path

Specify the path to a Vale configuration file. If this parameter isn't specified, Vale looks for
the `.vale.ini` configuration file from the current working directory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`,
-InformationAction, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`,
`-Verbose`, -WarningAction, and `-WarningVariable`. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

This cmdlet doesn't support any pipeline input.

## OUTPUTS

### None

This cmdlet doesn't return any output.

## NOTES

## RELATED LINKS
