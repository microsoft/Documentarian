---
title: ValeConfigurationFormatTransform
linktitle: Transform
summary: Maps a pattern of files to an XSLT file for transforming them from their source into HTML.
description: >-
  The **ValeConfigurationFormatTransform** class maps a pattern of files to an XSLT
  file for transforming them from their source into HTML.
no_list: true
---

## Definition

{{% src path="Public/Classes/ValeConfigurationFormatTransform.psm1" title="Source Code" /%}}

An instance of the **ValeConfigurationFormatTransform** class maps a pattern of files to an XSLT
file for transforming them from their source into HTML.

## Constructors

[`ValeConfigurationFormatTransform()`][01]
: Initializes a new instance of the **ValeConfigurationFormatTransform** class.

## Properties

[**GlobPattern**][02]
: Represents the file-matching pattern to apply the transformation to.

[**Path**][03]
: Specifies the path to a version 1.0 XSL Transformation (XSLT) for converting the files to HTML.

<!-- Reference Link Definitions -->
[01]: ./constructors#valeconfigurationformattransform
[02]: ./properties#globpattern
[03]: ./properties#path
