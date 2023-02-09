---
external help file: Documentarian.Vale-help.xml
Module Name: Documentarian.Vale
online version: https://microsoft.github.io/Documentarian/modules/vale/reference/cmdlets/test-prose
schema: 2.0.0
title: Test-Prose
---

## SYNOPSIS

Test a document's prose with Vale rules.

## SYNTAX

```
Test-Prose [[-Path] <String[]>] [[-ConfigurationPath] <String>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet tests a document's prose with configured Vale rules, returning an object for style rule
violation. The returned object includes detailed information about where and how the document
violated a style rule.

## EXAMPLES

### Example 1: Test a specific document

```powershell
Test-Prose -Path ./README.md
```

```output-pwsh-list
Action      : @{Name=; Params=}
Span        : {18, 20}
Check       : Microsoft.Acronyms
Description :
Link        : https://docs.microsoft.com/en-us/style-guide/acronyms
Message     : 'MIT' has no definition.
Severity    : suggestion
Match       : MIT
Line        : 10
FileInfo    : C:\code\pwsh\Documentarian\README.md

Action      : @{Name=replace; Params=System.Object[]}
Span        : {5, 11}
Check       : Microsoft.ComplexWords
Description :
Link        : https://docs.microsoft.com/en-us/style-guide/word-choice/
              use-simple-words-concise-sentences
Message     : Consider using 'give' or 'offer' instead of 'provide'.
Severity    : suggestion
Match       : provide
Line        : 25
FileInfo    : C:\code\pwsh\Documentarian\README.md
```

### Example 2: Test a folder

```powershell
Test-Prose -Path ./reference/cmdlets/
```

```output-pwsh-table
Count Name
----- ----
    4 C:\Documentarian\Documentation\reference\cmdlets\Convert-MDLinks.md
    2 C:\Documentarian\Documentation\reference\cmdlets\Get-ContentWithoutHeader.md
    2 C:\Documentarian\Documentation\reference\cmdlets\Get-Document.md
   15 C:\Documentarian\Documentation\reference\cmdlets\Get-DocumentLink.md
    2 C:\Documentarian\Documentation\reference\cmdlets\Get-Metadata.md
    3 C:\Documentarian\Documentation\reference\cmdlets\Remove-Metadata.md
    2 C:\Documentarian\Documentation\reference\cmdlets\Set-Metadata.md
    2 C:\Documentarian\Documentation\reference\cmdlets\Update-Metadata.md
```

## PARAMETERS

### -ConfigurationPath

Specify the path to a Vale configuration file---typically `.vale.ini`---to use for the tests. By
default, Vale infers the configuration based on current working directory.

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

### -Path

Specify the path to one or more files or folders to test. If the value is a folder, the cmdlet tests
every Markdown file in that folder.

```yaml
Type: String[]
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

### System.Object

This cmdlet returns an object representing a rule violation for a document's prose.

## NOTES

## RELATED LINKS

<!-- Link reference definitions -->
[acp]: http://go.microsoft.com/fwlink/?LinkID=113216
