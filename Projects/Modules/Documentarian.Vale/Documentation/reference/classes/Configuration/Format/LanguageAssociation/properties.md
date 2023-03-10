---
title: Properties
summary: Properties for the ValeConfigurationFormatLanguageAssociation class
description: >-
  Defines the properties for the **ValeConfigurationFormatLanguageAssociation** class.
---

## GlobPattern

Represents the file-matching pattern to associate with a specific language. For example, `[*]`
matches all files while `[*.{md,txt}]` only matches files with the `.md` or `.txt` extension.

Type
: {{% xref "System.String" %}}
{.pwsh-metadata}

## LanguageID

Specifies the language the **GlobPattern** maps to. By default, all files map to `en`. This value
is used for Vale's spelling checks.

Type
: {{% xref "System.String" %}}
{.pwsh-metadata}

<!-- Reference Link Definitions -->
