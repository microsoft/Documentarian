---
external help file: Documentarian.MicrosoftDocs-help.xml
Module Name: Documentarian.MicrosoftDocs
ms.date: 02/07/2023
online version:
schema: 2.0.0
title: Sync-VSCode
---

# Sync-VSCode

## SYNOPSIS
Provides a simple way to synchronize changes across multiple versions of a Markdown file.

## SYNTAX

```
Sync-VSCode [-Path] <String>
```

## DESCRIPTION

Many docsets at Microsoft contain multiple versions of the same reference document. For example, we
support multiple versions of PowerShell cmdlets. Each version contains the same cmdlet but there may
be minor differences between the versions.

When you make a change to the documentation for one of these cmdlet, it's often necessary to make
the same change across all the supported versions.

`Sync-VSCode` reads the `monikerMapping.json` file in your repository to discover the version
monikers and the file paths they map to. Using this version information, the cmdlet opens the file
passed and one of the other versions of the same file for side-by-side comparison. When you close
the application it opens the same file and the next version of the file. This repeats until you have
opened and compared all versions.

This cmdlet is dependent on the product **Visual Studio Code (VS Code)**. **VS Code** has
a visual diff mode that makes it easy to compare two files and copy differences from one file to
the other.

## EXAMPLES

### Example 1

There are four versions PowerShell documentation: 5.1, 7.2, 7.3, and 7.4. In this example,
`Sync-VSCode` is used to compare the 7.3 version of `about_Output_Streams.md` with the same
article in the other versions.

```powershell
Sync-VSCode reference/7.3/Microsoft.PowerShell.Core/About/about_Output_Streams.md
```

The cmdlet opens the 7.3 and 5.1 versions of the file for comparison. You can copy the appropriate
changes to or from either file. When you save and close the file, the cmdlet then opens the 7.3 and
7.2 versions for comparison. This process repeats until you have compared all versions.

## PARAMETERS

### -Path

The path the updated file that is the base for your comparison. The file path must contain the
version portion of the path as defined in the `monikerMapping.json`.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
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

[Visual Studio Code](https://code.visualstudio.com)
