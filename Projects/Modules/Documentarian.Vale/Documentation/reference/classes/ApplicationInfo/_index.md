---
title: ValeApplicationInfo
linktitle: ApplicationInfo
summary: Represents the Vale binary available on a machine.
description: >-
  The **ValeApplicationInfo** represents the Vale binary available on a machine.
no_list: true
---

## Definition

{{% src path="Public/Classes/ValeApplicationInfo.psm1" title="Source Code" /%}}

An instance of the **ValeApplicationInfo** class has the same properties as the
{{< xref "System.Management.Automation.ApplicationInfo" >}} type but with the **Version** property
correctly reflecting Vale's actual version.

## Examples

### 1. Checking Vale's Version

This example shows the difference between calling `Get-Command` on a Vale binary and the output of
the `Get-Vale` command. Only the latter shows the correct version information for Vale.

```powershell
Get-Command ./.vale/vale
Get-Vale
```

```output
CommandType  Name      Version    Source
-----------  ----      -------    ------
Application  vale.exe  0.0.0.0    C:\code\pwsh\Documentarian\.vale\vale.exe
Application  vale.exe  2.24.0     C:\code\pwsh\Documentarian\.vale\vale.exe
```

## Constructors

[`ValeApplicationInfo()`][01]
: Initializes a new instance of the **ValeApplicationInfo** class.

## Methods

[`ToString()`][02]
: Returns the string representation of a **ValeApplicationInfo** instance.

## Properties

[**CommandType**][03]
: Lists the type of the command.

[**Definition**][04]
: Gets the path of the Vale program file.

[**Extension**][05]
: Gets the extension of the Vale program file.

[**Module**][06]
: This value is always null for Vale.

[**ModuleName**][07]
: This value is always null for Vale.

[**Name**][08]
: Gets the name of the Vale program file.

[**OutputType**][09]
: Gets the output type.

[**Parameters**][10]
: This value is always null for Vale.

[**ParameterSets**][11]
: This value is always null for Vale.

[**Path**][12]
: Gets the full path to the Vale program file.

[**RemotingCapability**][13]
: Gets the remoting capabilities of this cmdlet.

[**Source**][14]
: Gets the source of this command

[**Version**][15]
: Gets the version of the Vale application.

[**Visibility**][16]
: Gets the visibility of Vale.

<!-- Reference Link Definitions -->
[01]: ./constructors#valeapplicationinfo
[02]: ./methods/ToString
[03]: ./properties#commandtype
[04]: ./properties#definition
[05]: ./properties#extension
[06]: ./properties#module
[07]: ./properties#modulename
[08]: ./properties#name
[09]: ./properties#outputtype
[10]: ./properties#parameters
[11]: ./properties#parametersets
[12]: ./properties#path
[13]: ./properties#remotingcapability
[14]: ./properties#source
[15]: ./properties#version
[16]: ./properties#visibility
