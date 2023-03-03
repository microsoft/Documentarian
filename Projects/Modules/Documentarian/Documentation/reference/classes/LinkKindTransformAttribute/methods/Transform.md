---
title: Transform
summary: Converts the input object into one or more matching LinkKind enums.
description: >-
  The `Transform()` method converts the input object into one or more matching **LinkKind** enums,
  raising an exception if the input can't be converted.
---

## Overloads

[`Transform(EngineIntrinsics, Object)`](#transformengineintrinsics-object)
: Converts the input object into one or more matching **LinkKind** enums, raising an exception if
  the input can't be converted.

## `Transform(EngineIntrinsics, Object)`

Converts the input object into one or more matching [**LinkKind**][01] enums, raising an exception
if the input can't be converted.

```powershell
[LinkKindTransformAttribute] Transform(
    [EngineIntrinsics] $engineIntrinsics,
    [Object] $inputData
)
```

### Parameters

#### `engineIntrinsics`

Type
: {{% xref "System.Management.Automation.EngineIntrinsics" %}}
{.pwsh-metadata}

The PowerShell engine APIs for the context under which the prerequisite is being evaluated.

#### `inputData`

Type
: {{% xref "System.Object" %}}
{.pwsh-metadata}

The value of the argument to transform into one or more [**LinkKind**][01] enums. When this value
is a a **LinkKind**, that value is passed through. When this value is a string, the value is
compared to the list of valid **LinkKind** enums with the [`-like` operator][02] and returns every
value that matches the input string.

### Exceptions

- {{% xref "system.Management.Automation.ArgumentTransformationMetadataException" %}}

  **Transform** raises this exception when the input data is not a [**LinkKind**][01] or a string
  that matches at least one **LinkKind**.

<!-- Link Reference Definitions -->
[01]: ../../../../enums/linkkind
[02]: https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_comparison_operators#-like-and--notlike
