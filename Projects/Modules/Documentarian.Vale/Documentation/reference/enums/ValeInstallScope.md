---
title: ValeInstallScope
summary: Defines where `Install-Vale` should install the application
description: >-
  The **ValeInstallScope** enum defines where `Install-Vale` should install the application.
---

## Definition

{{% src path="Public/Enums/ValeInstallScope.psm1" title="Source Code" /%}}

## Fields

### `User`

Value
: 0
{ .pwsh-metadata }

Indicates that Vale should be installed into the user's home directory in the `.vale` folder.

### `Workspace`

Value
: 1
{ .pwsh-metadata }

Indicates that Vale should be installed into the current working directory in the `.vale` folder.
