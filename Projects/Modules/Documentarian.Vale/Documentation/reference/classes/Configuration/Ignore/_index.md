---
title: ValeConfigurationIgnore
linktitle: Ignore
summary: Maps files to a set of patterns for deciding whether to skip processing text during a check.
description: >-
  The **ValeConfigurationIgnore** class maps a pattern of files to a set of patterns
  for Vale to use when deciding whether to skip processing text during a check.
no_list: true
---

## Definition

{{% src path="Public/Classes/ValeConfigurationIgnore.psm1" title="Source Code" /%}}

An instance of the **ValeConfigurationIgnore** class maps a pattern of files to a set of patterns
for Vale to use when deciding whether to skip processing text during a check.

## Constructors

[`ValeConfigurationIgnore()`][01]
: Initializes a new instance of the **ValeConfigurationIgnore** class.

## Properties

[**GlobPattern**][02]
: Represents the file-matching pattern to apply the ignore to.

[**IgnorePatterns**][03]
: Specifies one or more patterns for Vale to use when deciding whether to skip processing text.

<!-- Reference Link Definitions -->

[01]: ./constructors#valeconfigurationignore
[02]: ./properties#globpattern
[03]: ./properties#ignorepatterns
