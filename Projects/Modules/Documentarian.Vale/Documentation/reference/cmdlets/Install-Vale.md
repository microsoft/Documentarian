---
external help file: Documentarian.Vale-help.xml
Locale: en-US
Module Name: Documentarian.Vale
online version: https://microsoft.github.io/Documentarian/modules/vale/reference/cmdlets/install-vale
schema: 2.0.0
title: Install-Vale
---

# Install-Vale

## SYNOPSIS
Installs Vale to the current working directory or the user's home folder.

## SYNTAX

```
Install-Vale
 [[-Version] <String>]
 [[-Scope] <ValeInstallScope>]
 [-PassThru]
 [<CommonParameters>]
```

## DESCRIPTION

The `Install-Vale` cmdlet is a helper for installing Vale into a project folder or the user's home
directory. When used, it installs Vale into the `.vale` folder of the current directory by default.
You can specify the **Scope** parameter as `User` to install Vale into the `.vale` folder in your
home directory instead.

This cmdlet is useful for installing Vale in CI or when you only need it for a specific project. It
isn't a full alternative to using a package manager.

## EXAMPLES

### Example 1: Install the latest version of Vale

```powershell
Install-Vale
```

### Example 2: Install a specific version of Vale

```powershell
Install-Vale -Version 'v2.21.3'
```

### Example 3: Install Vale in your home folder

```powershell
Install-Vale -Scope User
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

### -Scope

Specifies the scope to install Vale to. By default, Vale is installed in the `Workspace` scope.

- `User` - Install Vale to the user's home directory in the `.vale` folder.
- `Workspace` - Install vale to the current working directory in the `.vale` folder.

```yaml
Type: ValeInstallScope
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
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

This cmdlet doesn't support any pipeline input.

## OUTPUTS

### None

By default, this cmdlet returns no output.

### System.IO.FileInfo

If the **PassThru** parameter is specified, the cmdlet returns the **FileInfo** for the installed
binary.

## NOTES

## RELATED LINKS
