---
external help file: Documentarian.Vale-help.xml
Module Name: Documentarian.Vale
online version: https://microsoft.github.io/Documentarian/modules/vale/reference/cmdlets/get-valeconfiguration
schema: 2.0.0
title: Get-ValeConfiguration
---

## SYNOPSIS

Returns the current configuration for Vale as an object.

## SYNTAX

```
Get-ValeConfiguration [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION

The `Get-ValeConfiguration` cmdlet returns a Vale configuration as an object.

## EXAMPLES

### Example 1: Get the workspace Vale configuration

```powershell
Get-ValeConfiguration
```

```pwsh-output-list
BlockIgnores   :
Checks         : {PowerShell-Docs.Passive, Vale.Spelling, alex.Ablist…}
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
StylesPath     : C:/code/Documentarian/.vscode/styles
TokenIgnores   :
WordTemplate   :
DictionaryPath :
NLPEndpoint    :
```

### Example 2: Get a specific Vale configuration

```pwsh
Get-ValeConfiguration -Path /code/site/.vale.ini
```

```output-pwsh-list
BlockIgnores   : @{*.md=System.Object[]}
Checks         : {alex.Ablist, alex.Gendered, alex.ProfanityLikely, alex.ProfanityMaybe…}
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
StylesPath     : C:/code/site/.vscode/styles
TokenIgnores   : @{*.md=System.Object[]}
WordTemplate   :
DictionaryPath :
NLPEndpoint    :
```

## PARAMETERS

### -Path

Specify the path to a Vale configuration file (typically `.vale.ini`) to return as an object.

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

### System.Object

This cmdlet returns a custom object with the Vale configuration's properties.

## NOTES

## RELATED LINKS

<!-- Link reference definitions -->
[acp]: http://go.microsoft.com/fwlink/?LinkID=113216
