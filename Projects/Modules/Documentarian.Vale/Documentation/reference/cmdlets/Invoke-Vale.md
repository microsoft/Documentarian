---
external help file: Documentarian.Vale-help.xml
Module Name: Documentarian.Vale
online version: https://microsoft.github.io/Documentarian/modules/vale/reference/cmdlets/invoke-vale
schema: 2.0.0
title: Invoke-Vale
---

## SYNOPSIS

Calls the vale executable and returns the result as a PowerShell object.

## SYNTAX

```
Get-Vale -ArgumentList <String[]> [<CommonParameters>]
```

## DESCRIPTION

The `Invoke-Vale` cmdlet calls the `vale` binary and a **PSCustomObject** representing the JSON
output. It makes it simpler to retrieve structured output from Vale.

The cmdlet automatically appends the `--output JSON` flag and value to your argument list, ensuring
that Vale always returns structured output when it can.

It also has specific error-handling for common Vale errors, reducing the need for troubleshooting
and parsing strings to understand what went wrong.

The cmdlet is capable of calling Vale whether it's installed in the `PATH` environment variable or
the workspace, as with the [Install-WorkspaceVale][01] cmdlet.

## EXAMPLES

### Example 1: Invoke vale to get the effective configuration

```powershell
Invoke-Vale -ArgumentList 'ls-config'
```

```output
BlockIgnores   :
Checks         : {PowerShell-Docs.Passive, Vale.Spelling, alex.Ablist, alex.Profanity…}
Formats        :
Asciidoctor    :
FormatToLang   :
GBaseStyles    :
GChecks        :
IgnoredClasses :
IgnoredScopes  :
MinAlertLevel  : 0
Vocab          : {Base}
RuleToLevel    :
SBaseStyles    : @{*.md=System.Object[]}
SChecks        : @{*.md=}
SkippedScopes  :
Stylesheets    :
StylesPath     : C:/code/pwsh/Documentarian/.vscode/styles
TokenIgnores   :
WordTemplate   :
DictionaryPath :
NLPEndpoint
```

## PARAMETERS

### -ArgumentList

Specify one or more arguments to pass to Vale. The arguments `--output` and `JSON` are always
appended to the list and don't need to be specified.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: `-Debug`, `-ErrorAction`, `-ErrorVariable`,
`-InformationAction`, `-InformationVariable`, `-OutVariable`, `-OutBuffer`, `-PipelineVariable`,
`-Verbose`, `-WarningAction`, and `-WarningVariable`. For more information, see
[about_CommonParameters][acp].

## INPUTS

### None

This cmdlet doesn't support any pipeline input.

## OUTPUTS

### {{% xref "System.String" %}}

This cmdlet returns a string when the argument list includes the flags for displaying Vale's
version (`-v` and `--version`) or help (`-h` and `--help`). When any of those flags are used, Vale
returns strings instead of JSON.

### System.Management.Automation.OrderedHashtable

This cmdlet returns an **OrderedHashtable** for the structured output from Vale.

## NOTES

The `Invoke-Vale` cmdlet is useful for calling Vale, handling its common errors, and returning
structured output. However, the output isn't always in the most usable form. The other cmdlets in
this module return more specific and useful information. They also have parameters that are easier
to use than building an array of arguments.

## RELATED LINKS

[Install-WorkspaceVale][01]

<!-- Link reference definitions -->
[01]: ../install-workspacevale
[acp]: http://go.microsoft.com/fwlink/?LinkID=113216
