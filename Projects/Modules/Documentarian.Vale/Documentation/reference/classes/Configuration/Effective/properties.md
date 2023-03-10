---
title: Properties
summary: Properties for the ValeConfigurationEffective class
description: >-
  Defines the properties for the **ValeConfigurationEffective** class.
---

## AsciidoctorAttributes

Represents a set of key-value pairs to use when processing AsciiDoc files.

Type
: {{% xref "System.Collections.Hashtable" %}}
{ .pwsh-metadata }

## BlockIgnores

Represents a set of patterns Vale ignores when processing block-level sections of text that don't
have an associated HTML tag.

Type
: [**ValeConfigurationIgnore[]**][01]
{ .pwsh-metadata }

## Checks

Represents the full list of checks for Vale to use when linting prose.

Type
: {{% xref "System.String" %}}[]
{ .pwsh-metadata }

## DictionaryPath

Represents the path to the folder that contains dictionaries for Vale to use when checking spelling.

Type
: {{% xref "System.String" %}}
{ .pwsh-metadata }

## FormatLanguageAssociations

Represents a set of file formats to use a specified language for when checking spelling.

Type
: [**ValeConfigurationFormatLanguageAssociation[]**][03]
{ .pwsh-metadata }

## FormatTransformationStylesheets

Represents a set of file pattern associations for Vale to transform with a specific XSLT before
linting their prose.

Type
: [**ValeConfigurationFormatTransform[]**][05]
{ .pwsh-metadata }

## FormatTypeAssociations

Represents a set of file formats to treat as a different type when linting their prose.

Type
: [**ValeConfigurationFormatTypeAssociation[]**][02]
{ .pwsh-metadata }

## GlobalBaseStyles

Represents the set of Vale styles to apply when linting prose, regardless of the file's syntax.

Type
: {{% xref "System.String" %}}[]
{ .pwsh-metadata }

## GlobalChecks

Represents the set of specific checks and their setting for Vale to use when linting prose,
regardless of the file's syntax.

Type
: {{% xref "System.Collections.Hashtable" %}}
{ .pwsh-metadata }

## IgnoredClasses

Represents a list of classes to identify HTML elements for Vale to ignore when linting prose.

Type
: {{% xref "System.String" %}}[]
{ .pwsh-metadata }

## IgnoredScopes

Represents a list of inline HTML tags for Vale to ignore when linting prose.

Type
: {{% xref "System.String" %}}[]
{ .pwsh-metadata }

## MinimumAlertLevel

Represents the minimum severity of the checks for Vale to report failures for when linting prose.

Type
: [**ValeAlertLevel**][04]
{ .pwsh-metadata }

## NlpEndpoint

Represents the URL to an natural language processing (NLP) service for Vale to use when linting
prose.

Type
: {{% xref "System.String" %}}
{ .pwsh-metadata }

<!-- Reference Link Definitions -->
[01]: ../../Ignore
[02]: ../../Format/TypeAssociation
[03]: ../../Format/LanguageAssociation
[04]: ../../../../enums/ValeAlertLevel
[05]: ../../Format/Transform

## RootIniPath

Represents the file path to the root configuration file for Vale. The effective configuration is
composed from the root configuration file and any configuration files included by packages the root
configuration file uses.

Type
: {{% xref "System.String" %}}
{ .pwsh-metadata }

## RuleToLevel

Represents a set of rules for Vale to override with their specified setting.

Type
: {{% xref "System.Collections.Hashtable" %}}
{ .pwsh-metadata }

## SkippedScopes

Represents a list of block-level HTML tags for Vale to ignore when linting prose.

Type
: {{% xref "System.String" %}}[]
{ .pwsh-metadata }

## StylesPath

Represents the path to folder that contains the styles for Vale to use when linting prose.

Type
: {{% xref "System.String" %}}
{ .pwsh-metadata }

## SyntaxBaseStyles

Represents a set of file patterns for specific markup syntaxes and base styles for Vale to use with
those files when linting their prose.

Type
: {{% xref "System.Collections.Hashtable" %}}
{ .pwsh-metadata }

## SyntaxChecks

Represents a set of file patterns for specific markup syntaxes and the specific checks for Vale to
apply when linting their prose.

Type
: {{% xref "System.Collections.Hashtable" %}}
{ .pwsh-metadata }

## TokenIgnores

Represents a set of patterns Vale ignores when processing inline text that doesn't have an
associated HTML tag.

Type
: [**ValeConfigurationIgnore[]**][01]
{ .pwsh-metadata }

## Vocabularies

Represents the set of custom vocabularies for Vale to use when checking spelling.

Type
: {{% xref "System.String" %}}[]
{ .pwsh-metadata }

## WordTemplate

Represents the pattern for Vale to use when parsing a file to find individual words.

Type
: {{% xref "System.String" %}}
{ .pwsh-metadata }
