# Public Source

This folder contains the public classes, enums, and functions used by this module as well as their
unit tests.

During module composition, the code in this folder (except for the tests) is placed into the
generated `Documentarian.AstInfo.psm1` file.

- [Classes]
- [Enums]
- [Functions]
  - [Completion]
  - [Configuration]
  - [General]

## Classes

This folder contains the public classes used by this module and their unit tests. During
composition, these classes are also included in the generated `Init.ps1` file, which enables
automatic import of the public classes into the caller's session for direct use.

The [`.LoadOrder.jsonc`][c01] file determines the order the classes should be
loaded during composition; this is critical to ensure nothing breaks.

- [**AstInfo**][c02] - Represents a parsed AST with tokens and parse errors.
- [**AstTypeTransformAttribute**][c03] - Transforms an input object into an AST type.
- [**ValidatePowerShellScriptPathAttribute**][c04] - Ensures the argument is the path to a
  PowerShell script file that exists.

## Enums

This folder contains the public enums used by this module and their unit tests. During composition,
these enums are also included in the generated `Init.ps1` file, which enables automatic import of
the public enums into the caller's session for direct use.

The [`.LoadOrder.jsonc`](Enums/.LoadOrder.jsonc) file determines the order the classes should be
loaded during composition; this is critical to ensure nothing breaks.

<!--
When one or more enums are added, this comment should be replaced with a list of the current enums
with a synopsis and any important notes for maintainers. For example:
- [`Bar`](Enums/Bar.ps1): Used for the known-valid values for the Bar property of the Foo datatype.
  - Needs to be updated periodically as the upstream datatype is modified.
-->

## Functions

This folder contains the public functions used by this module and their unit tests.

<!--
When one or more functions are added, this comment should be replaced with a list of the current
functions with a synopsis and any important notes for maintainers. For example:
- [`Test-GitHubToken`](Functions/General/Test-GitHubToken.ps1): Used to validate a github token.
  - Makes live calls to GitHub; be mindful when testing.
-->

- [`Find-Ast`][f01] - Finds ASTs by type or predicate in a script block, file, or AST.
- [`Get-AstInfo`][f02] - Gets an **AstInfo** object from a script block, file, or text.
- [`Get-AstType`][f03] - Gets AST types from the current AppDomain with optional filters.
- [`New-AstPredicate`][f04] - Returns a scriptblock predicate for finding ASTs of a particular
  type.
- [`Resolve-TypeName`][f05] - Resolves a **TypeName** or **ArrayTypeName** to the type's full name.
- [`Test-IsAstType`][f06] - Determines if a type is an AST type.

[c01]: Classes/.LoadOrder.jsonc
[c02]: Classes/AstInfo.psm1
[c03]: Classes/AstTypeTransformAttribute.psm1
[c04]: Classes/ValidatePowerShellScriptPathAttribute.psm1
[f01]: Functions/Find-Ast.ps1
[f02]: Functions/Get-AstInfo.ps1
[f03]: Functions/Get-AstType.ps1
[f04]: Functions/New-AstPredicate.ps1
[f05]: Functions/Resolve-TypeName.ps1
[f06]: Functions/Test-IsAstType.ps1
