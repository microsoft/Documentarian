---
title: ValeConfigurationFormatTypeAssociation
linktitle: TypeAssociation
summary: Maps a given file format to another.
description: >-
  The **ValeConfigurationFormatTypeAssociation** class maps a given file format to
  another.
no_list: true
---

## Definition

{{% src path="Public/Classes/ValeConfigurationFormatTypeAssociation.psm1" title="Source Code" /%}}

An instance of the **ValeConfigurationFormatTypeAssociation** class maps a given file format to
another. This enables Vale to treat different files, such as code files, like specific document
formats.

## Constructors

[`ValeConfigurationFormatTypeAssociation()`][01]
: Initializes a new instance of the **ValeConfigurationFormatTypeAssociation** class.

## Properties

[**ActualFormat**][02]
: Represents the file format to associate as a different format.

[**EffectiveFormat**][03]
: Specifies the format to treat the associated file format as.

<!-- Reference Link Definitions -->
[01]: ./constructors#valeconfigurationformattypeassociation
[02]: ./properties#actualformat
[03]: ./properties#effectiveformat
