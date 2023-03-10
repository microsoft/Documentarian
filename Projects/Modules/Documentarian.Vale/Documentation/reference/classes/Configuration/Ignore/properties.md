---
title: Properties
summary: Properties for the ValeConfigurationIgnore class
description: >-
  Defines the properties for the **ValeConfigurationIgnore** class.
---

<!-- Reference Link Definitions -->

## GlobPattern

Represents the file-matching pattern to apply the ignore to. For example, `[*]`
matches all files while `[*.{md,txt}]` only matches files with the `.md` or `.txt` extension.

Type
: {{% xref "System.String" %}}
{.pwsh-metadata}

## IgnorePatterns

Specifies one or more patterns for Vale to use when deciding whether to skip processing text.

Type
: {{% xref "System.String" %}}[]
{.pwsh-metadata}
