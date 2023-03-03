---
title: ValidatePowerShellScriptPath
summary: Validates that a specified value is a path pointing to a PowerShell script file path.
description: >-
  Ensures that a value is a path pointing to a PowerShell file.
---

## Definition

Inherits From
: {{% xref "System.Management.Automation.ValidateArgumentsAttribute" %}}
{.pwsh-metadata}

{{% src path="Public/Classes/ValidatePowerShellScriptPath.psm1" title="Source Code" /%}}

The **ValidatePowerShellScriptPath** attribute ensures that a specified argument points to a
PowerShell file that exists. It's used for commands and scripts that need to act on a PowerShell
code file.

This attribute rejects values when:

- The value is `$null`.
- The value is for a path to a file that doesn't exist.
- The value is for a path to a file that isn't recognized as a PowerShell code file. The attribute
  only recognizes files with the `ps1`, `psd1`, and `psm1` extensions as PowerShell code files.

## Examples

### Example 1: Validating a variable

```powershell
[ValidatePowerShellScriptPath()]$Test = 'not-a-pwsh-file.txt'
```

### Example 2: Validating a parameter

```powershell
function Get-PwshContent {
  [cmdletbinding()]
  param (
    [ValidatePowerShellScriptPath()]$Path
  )

  process {
    Get-Content -Path $Path
  }
}
```

## Constructors

### `ValidatePowerShellScriptPath()`

The default constructor takes no input.

## Methods

### `Validate(Object, EngineIntrinsics)`

#### Parameters

##### `Arguments`

Type
: {{% xref "System.Object" %}}
{.pwsh-metadata}

The value of the argument to validate as a PowerShell script file path.

##### `EngineIntrinsics`

Type
: {{% xref "System.Management.Automation.EngineIntrinsics" %}}
{.pwsh-metadata}

The PowerShell engine APIs for the context under which the prerequisite is being evaluated.

#### Exceptions

- {{% xref "System.ArgumentNullException" %}}

  **Validate** raises this exception when the argument is null.
- {{% xref "System.ArgumentNullException" %}}

  **Validate** raises this exception when the argument is null.
- {{% xref "System.IO.FileNotFoundException" %}}

  **Validate** raises this exception when the argument points to a file that doesn't exist.
- {{% xref "System.ArgumentException" %}}

  **Validate** raises this exception when the argument points to a file that doesn't have a valid
  extension for a PowerShell code file.

## Properties

None.
