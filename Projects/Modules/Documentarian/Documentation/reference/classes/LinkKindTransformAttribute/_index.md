---
title: LinkKindTransformAttribute
summary: Transforms an input string into one or more LinkKind enums.
description: >-
  The **LinkKindTransformAttribute** converts a string with wildcard characters into one or more
  **LinkKind** enum values.
no_list: true
---

## Definition

Inherits From
: {{% xref "System.Management.Automation.ArgumentTransformationAttribute" %}}
{.pwsh-metadata}

{{% src path="Public/Classes/LinkKindTransformAttribute.psm1" title="Source Code" /%}}

The **LinkKindTransformAttribute** class is an argument transformation attribute that converts a
string with wildcard characters into one or more [**LinkKind**][01] enum values.

## Examples

### Example 1: Transforming a string variable

```powershell
[LinkKindTransform()]$Kinds = 'Text*'
$Kinds
```

```output
TextInline
TextSelfReference
TextUsingReference
```

### Example 2: Transforming a string parameter

```powershell
function Get-LinkKind {
  [cmdletbinding()]
  param (
    [LinkKindTransform()][LinkKind[]]$Kind
  )

  process {
    $Kind
  }
}

Get-LinkKind -Kind *Reference
```

```output
TextSelfReference
TextUsingReference
ImageSelfReference
ImageUsingReference
```

## Methods

[`Transform(EngineIntrinsics, Object)`][02]
: Tranforms the input object into one or more matching [**LinkKind**][01] enums.

## Properties

None.

<!-- Reference Link Definitions -->
[01]: ../enums/linkkind
[02]: ./methods/transform#transformengineintrinsics-object
