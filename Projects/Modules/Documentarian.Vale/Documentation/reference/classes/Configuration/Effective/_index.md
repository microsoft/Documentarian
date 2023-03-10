---
title: ValeConfigurationEffective
linktitle: Effective
summary: Does something.
description: >-
  The **ValeConfigurationEffective** class does something.
no_list: true
---

## Definition

{{% src path="Public/Classes/ValeConfigurationEffective.psm1" title="Source Code" /%}}

An instance of the **ValeConfigurationEffective** class represents the effective configuration for
Vale as returned by the [`Get-ValeConfiguration`][01] command.

## Examples

### 1. Reviewing the effective configuration for Vale in a workspace

```powershell
Get-ValeConfiguration -OutVariable c

$c | Format-List
```

<!-- markdownlint-disable MD013-->
```output
RootIniPath                          StylesPath                                MinimumAlertLevel GlobalBaseStyles  Vocabularies
-----------                          ----------                                ----------------- ----------------  ------------
C:\code\pwsh\Documentarian/.vale.ini C:/code/pwsh/Documentarian/.vscode/styles Suggestion        {PowerShell-Docs} {Base}


BlockIgnores                    :
Checks                          : {PowerShell-Docs.Passive, Vale.Spelling, PowerShell-Docs.Passive, Vale.Spelling…}
FormatTypeAssociations          : {ValeConfigurationFormatTypeAssociation}
AsciidoctorAttributes           : {}
FormatLanguageAssociations      :
GlobalBaseStyles                : {PowerShell-Docs}
GlobalChecks                    : {[PowerShell-Docs.Passive, False], [Vale.Spelling, False]}
IgnoredClasses                  :
IgnoredScopes                   :
MinimumAlertLevel               : Suggestion
Vocabularies                    : {Base}
RuleToLevel                     :
SyntaxBaseStyles                : {[*.md, System.Object[]]}
SyntaxChecks                    : {[*.md, System.Management.Automation.OrderedHashtable]}
SkippedScopes                   :
FormatTransformationStylesheets :
StylesPath                      : C:/code/pwsh/Documentarian/.vscode/styles
TokenIgnores                    :
WordTemplate                    :
RootIniPath                     : C:\code\pwsh\Documentarian/.vale.ini
DictionaryPath                  :
NlpEndpoint                     :
```
<!-- markdownlint-enable MD013-->

## Constructors

[`ValeConfigurationEffective()`][02]
: Initializes a new instance of the **ValeConfigurationEffective** class.

[`ValeConfigurationEffective(System.Management.Automation.OrderedHashtable)`][03]
: Initializes a new instance of the **ValeConfigurationEffective** class from the output of the
  `vale ls-config` command.

## Properties

[**AsciidoctorAttributes**][04]
: Represents a set of key-value pairs to use when processing AsciiDoc files.

[**BlockIgnores**][05]
: Represents a set of patterns Vale ignores when processing block-level sections of text that don't
  have an associated HTML tag.

[**Checks**][06]
: Represents the full list of checks for Vale to use when linting prose.

[**DictionaryPath**][07]
: Represents the path to the folder that contains dictionaries for Vale to use when checking spelling.

[**FormatLanguageAssociations**][08]
: Represents a set of file formats to use a specified language for when checking spelling.

[**FormatTransformationStylesheets**][09]
: Represents a set of file pattern associations for Vale to transform with a specific XSLT before
  linting their prose.

[**FormatTypeAssociations**][10]
: Represents a set of file formats to treat as a different type when linting their prose.

[**GlobalBaseStyles**][11]
: Represents the set of Vale styles to apply when linting prose, regardless of the file's syntax.

[**GlobalChecks**][12]
: Represents the set of specific checks and their setting for Vale to use when linting prose,
  regardless of the file's syntax.

[**IgnoredClasses**][13]
: Represents a list of classes to identify HTML elements for Vale to ignore when linting prose.

[**IgnoredScopes**][14]
: Represents a list of inline HTML tags for Vale to ignore when linting prose.

[**MinimumAlertLevel**][15]
: Represents the minimum severity of the checks for Vale to report failures for when linting prose.

[**NlpEndpoint**][16]
: Represents the URL to an natural language processing (NLP) service for Vale to use when linting
  prose.

[**RootIniPath**][17]
: Represents the file path to the root configuration file for Vale.

[**RuleToLevel**][18]
: Represents a set of rules for Vale to override with their specified setting.

[**SkippedScopes**][19]
: Represents a list of block-level HTML tags for Vale to ignore when linting prose.

[**StylesPath**][20]
: Represents the path to folder that contains the styles for Vale to use when linting prose.

[**SyntaxBaseStyles**][21]
: Represents a set of file patterns for specific markup syntaxes and base styles for Vale to use
  with those files when linting their prose.

[**SyntaxChecks**][22]
: Represents a set of file patterns for specific markup syntaxes and the specific checks for Vale to
  apply when linting their prose.

[**TokenIgnores**][23]
: Represents a set of patterns Vale ignores when processing inline text that doesn't have an
  associated HTML tag.

[**Vocabularies**][24]
: Represents the set of custom vocabularies for Vale to use when checking spelling.

[**WordTemplate**][25]
: Represents the pattern for Vale to use when parsing a file to find individual words.

<!-- Reference Link Definitions -->

[01]: ../../../cmdlets/Get-ValeConfiguration
[02]: ./constructors#valeconfigurationeffective
[03]: ./constructors#valeconfigurationeffectivesystemmanagementautomationorderedhashtable
[04]: ./properties#asciidoctorattributes
[05]: ./properties#blockignores
[06]: ./properties#checks
[07]: ./properties#dictionarypath
[08]: ./properties#formatlanguageassociations
[09]: ./properties#formattransformationstylesheets
[10]: ./properties#formattypeassociations
[11]: ./properties#globalbasestyles
[12]: ./properties#globalchecks
[13]: ./properties#ignoredclasses
[14]: ./properties#ignoredscopes
[15]: ./properties#minimumalertlevel
[16]: ./properties#nlpendpoint
[17]: ./properties#rootinipath
[18]: ./properties#ruletolevel
[19]: ./properties#skippedscopes
[20]: ./properties#stylespath
[21]: ./properties#syntaxbasestyles
[22]: ./properties#syntaxchecks
[23]: ./properties#tokenignores
[24]: ./properties#vocabularies
[25]: ./properties#wordtemplate
