---
external help file: Documentarian.ModuleAuthor-help.xml
Locale: en-US
Module Name: Documentarian.ModuleAuthor
online version: https://microsoft.github.io/Documentarian/modules/moduleauthor/reference/cmdlets/invoke-newmdhelp
schema: 2.0.0
title: Invoke-NewMDHelp
---

# Invoke-NewMDHelp

## SYNOPSIS

Creates Markdown help files for the cmdlets in a module.

## SYNTAX

```
Invoke-NewMDHelp [-Module] <Object> [-OutPath] <Object>
```

## DESCRIPTION

This cmdlet is a wrapper for the `New-MarkdownHelp` cmdlet from the **PlatyPS** module. It runs
`New-MarkdownHelp` with the standard set of parameters we use for our documentation at Microsoft.

The target module must be loaded in your current session and you must have the **PlatyPS** module
installed.

## EXAMPLES

### Example 1

```powershell
Invoke-NewMDHelp -Module Documentarian -OutPath .\Documentarian
```

## PARAMETERS

### -Module

The name of the module that you want to document.

```yaml
Type: System.Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutPath

The location where you want to write the Markdown files.

```yaml
Type: System.Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### None

## OUTPUTS

### None

## NOTES

## RELATED LINKS

[PlatyPS](https://learn.microsoft.com/powershell/utility-modules/platyps/overview)
