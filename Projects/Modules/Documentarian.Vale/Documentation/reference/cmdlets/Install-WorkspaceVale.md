---
external help file: Documentarian.Vale-help.xml
Module Name: Documentarian.Vale
online version: https://microsoft.github.io/Documentarian/modules/vale/reference/cmdlets/Install-WorkspaceVale
schema: 2.0.0
title: Install-WorkspaceVale
---

## SYNOPSIS

Installs Vale to the current working directory.

## SYNTAX

```
Install-WorkspaceVale [[-Version] <String>] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION

The `Install-WorkspaceVale` cmdlet is a helper for installing Vale into a project folder. When used,
it installs Vale into the `.vale` folder of the current directory.

This cmdlet is useful for installing Vale in CI or when you only need it for a specific project. It
isn't a full alternative to using a package manager.

## EXAMPLES

### Example 1: Install the latest version of Vale

```powershell
Install-Vale
```

### Example 1: Install a specific version of Vale

```powershell
Install-Vale -Version 'v2.21.3'
```

## PARAMETERS

### -PassThru

When this parameter is specified, the cmdlet returns the **FileInfo** for the installed binary. By
default, the cmdlet returns no output.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Version

Specify the version of Vale to install. By default, the cmdlet installs the latest version.

```yaml
Type: String
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
-InformationAction, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`,
`-Verbose`, -WarningAction, and `-WarningVariable`. For more information, see
[about_CommonParameters][acp].

## INPUTS

### None

This cmdlet doesn't support any pipeline input.

## OUTPUTS

### None

By default, this cmdlet returns no output.

### {{< xref "System.IO.FileInfo" >}}

If the **PassThru** parameter is specified, the cmdlet returns the **FileInfo** for the installed
binary.

## NOTES

## RELATED LINKS

<!-- Link reference definitions -->
[acp]: http://go.microsoft.com/fwlink/?LinkID=113216
