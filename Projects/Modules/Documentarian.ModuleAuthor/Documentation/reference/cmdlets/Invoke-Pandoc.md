---
external help file: Documentarian.ModuleAuthor-help.xml
Locale: en-US
Module Name: Documentarian.ModuleAuthor
online version: https://microsoft.github.io/Documentarian/modules/moduleauthor/reference/cmdlets/invoke-pandoc
schema: 2.0.0
title: Invoke-Pandoc
---

# Invoke-Pandoc

## SYNOPSIS
Invokes Pandoc to convert Markdown files to plain text files.

## SYNTAX

```
Invoke-Pandoc [[-Path] <String[]>] [[-OutputPath] <String>] [-Recurse]
```

## DESCRIPTION

This cmdlet is a wrapper for **Pandoc**, a command-line tool that converts documents from one format
to another. The cmdlet runs `pandoc.exe` with the standard set of parameters we use for our
documentation at Microsoft. **Pandoc** is the tool we use to convert PowerShell `about_*.md` files
to plain text, which is the format required by the PowerShell help system.

This cmdlet requires that you have **Pandoc** installed on your system.

## EXAMPLES

### Example 1 - Convert a Markdown file to plain text

This example converts the `about_ANSI_Terminals.md` file to plain text.

```powershell
Invoke-Pandoc .\reference\5.1\Microsoft.PowerShell.Core\About\about_ANSI_Terminals.md
```

```Output
    Directory: D:\Git\PS-Docs\PowerShell-Docs

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---            2/7/2023  1:16 PM           1475 about_ANSI_Terminals.help.txt
```

The cmdlet shows the newly created plain text file. The name of the text file is formatted to
support the PowerShell help system.

## PARAMETERS

### -OutputPath

The location where you want to write the plain text files. The default location is the current
directory.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

The location of the Markdown files you want to convert. This parameter supports wildcards.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -Recurse

When provided, the cmdlet also search all subfolders matching the pattern provided by the **Path**
parameter.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

### None

## OUTPUTS

### System.IO.FileInfo

## NOTES

The plain text file is created with a name compatible with the PowerShell help system. For an input
file named `about_subject.md`, the output filename is `about_subject.help.txt`.

## RELATED LINKS

[Pandoc](https://pandoc.org)
