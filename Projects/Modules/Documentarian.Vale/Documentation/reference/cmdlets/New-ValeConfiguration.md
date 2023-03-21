---
external help file: Documentarian.Vale-help.xml
Locale: en-US
Module Name: Documentarian.Vale
online version: https://microsoft.github.io/Documentarian/modules/vale/reference/cmdlets/new-valeconfiguration
schema: 2.0.0
title: New-ValeConfiguration
---

# New-ValeConfiguration

## SYNOPSIS
Create a minimal configuration file for Vale.

## SYNTAX

```
New-ValeConfiguration
 [[-FilePath] <String>]
 [[-StylesPath] <String>]
 [[-MinimumAlertLevel] <ValeAlertLevel>]
 [[-StylePackage] <String[]>]
 [-Force]
 [-PassThru]
 [-NoSpelling]
 [-NoSync]
 [<CommonParameters>]
```

## DESCRIPTION

The `New-ValeConfiguration` cmdlet is a helper function for creating a basic Vale configuration
file. By default, it creates the `.vale.ini` file in the working directory with the same settings
as Vale's own [configuration generator](https://vale.sh/generator/) and then immediately syncs the
newly created configuration.

You can use the **FilePath** parameter to create the configuration file in a different location or
with a different name. You can use the **StylesPath** to change where style packages are placed when
you use the `Sync-Vale` command.

The **StylePackage** parameter can automatically complete values for known Vale style packages. It
can also handle arbitrary packages, like those published to a URL or included in a local zip folder.

You can use the **NoSpelling** switch to prevent the new configuration from including Vale's
built-in spell checking. Use the **NoSync** switch if you don't want to sync the styles immediately.

## EXAMPLES

### Example 1: Create a basic Vale configuration

In this example, the `New-ValeConfiguration` cmdlet creates the `.vale.ini` file in the working
directory. It immediately syncs the `Microsoft` package, downloading it into the `.vscode/styles`
folder.

```powershell
New-ValeConfiguration -StylesPath '.vscode/styles' -StylePackage Microsoft
Get-Content -Path ./.vale.ini
Get-ValeStyle
```

```output
Packages=Microsoft
StylesPath=.vscode/styles
MinAlertLevel=suggestion
[*]
BasedOnStyles=Vale, Microsoft

Name      Path                                  Rules
----      ----                                  -----
Microsoft C:\code\temp\.vscode\styles\Microsoft {Accessibility, Acronyms, Adverbs, AMPM…}
```

The output from `Get-ValeStyle` shows that the `Microsoft` style has been synced and can be used.

## PARAMETERS

### -FilePath

Specify the path to the configuration file to create. By default, the cmdlet creates the
`.vale.ini` file in the current working directory.

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

### -Force

Specify whether the cmdlet should replace an existing configuration file if one exists at the same
path. By default, the cmdlet throws an exception when the configuration file already exists.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinimumAlertLevel

Specify the minimum alert level for the configuration file. This affects whether Vale ignores any
rules. The default value is `Suggestion`, which ensures all violations are reported.

```yaml
Type: ValeAlertLevel
Parameter Sets: (All)
Aliases:
Accepted values: Suggestion, Warning, Error

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoSpelling

Use this parameter to prevent the configuration from including Vale's built-in spell checking. By
default, new configurations use Vale to check spelling.

If you use this parameter, you must also use the **StylePackage** parameter to specify one or more
style packages to include in the configuration. Vale won't work without at least one style when
spelling is disabled.

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

### -NoSync

Use this parameter to avoid immediately syncing the specified style packages. By default, this
cmdlet sync the newly created configuration so it can be used immediately. Most Vale commands fail
when a configuration hasn't been synced.

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

### -PassThru

Use this parameter to specify that this cmdlet should return the created configuration file as a
**System.IO.FileInfo** object. By default, this cmdlet returns no output.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -StylePackage

Use this parameter to specify any number of Vale style packages to use when linting prose. By
default, no packages are included. This cmdlet includes an argument completer for well-known
Vale packages, but you can use any valid style package.

To use a local style package, specify the value as the path to the `.zip` archive containing it. The
archive must have the same name as the style. The path can be relative to the new configuration file
or absolute.

To use a remote style package, specify the value as the url to the `.zip` archive containing it. The
archive must have the same name as the style.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StylesPath

Specify the folder for Vale to store the style packages. The default value is the `styles` folder
in the same directory as the configuration file. If this value is a relative path, the path is
relative to the configuration file, not the current working directory.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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

### None

This cmdlet doesn't support any pipeline input.

## OUTPUTS

### None

By default, this cmdlet returns no output.

### System.IO.FileSystemInfo

If the **PassThru** parameter is specified, the cmdlet returns the **FileInfo** for the created
configuration file.

## NOTES

## RELATED LINKS
