# Private Source

This folder contains the private classes, enums, and functions used by this module as well as their
unit tests.

During module composition, the code in this folder (except for the tests) is placed into the
generated `Documentarian.DevX.Private.psm1` file.

- [Classes]
- [Enums]
- [Functions]

## Classes

This folder contains the private classes used by this module and their unit tests.

The [`.LoadOrder.jsonc`](Classes/.LoadOrder.jsonc) file determines the order the classes should be
loaded during composition; this is critical to ensure nothing breaks.

<!--
When one or more classes are added, this comment should be replaced with a list of the current
classes with a synopsis and any important notes for maintainers. For example:
- [`Foo`](Classes/Foo.ps1): Used to represent the foo datatype for processing.
  - Currently experimental and unstable, excluded from the build process.
-->

## Enums

This folder contains the private enums used by this module and their unit tests.

The [`.LoadOrder.jsonc`](Enums/.LoadOrder.jsonc) file determines the order the enums should be
loaded during composition; this is critical to ensure nothing breaks.

<!--
When one or more enums are added, this comment should be replaced with a list of the current enums
with a synopsis and any important notes for maintainers. For example:
- [`Bar`](Enums/Bar.ps1): Used for the known-valid values for the Bar property of the Foo datatype.
  - Needs to be updated periodically as the upstream datatype is modified.
-->

## Functions

This folder contains the private functions used by this module and their unit tests.

<!--
When one or more functions are added, this comment should be replaced with a list of the current
functions with a synopsis and any important notes for maintainers. For example:
- [`Get-Foo`](Functions/Foo.ps1): Used to retrieve Foo objects for processing.
  - Currently experimental and unstable, excluded from the build process.
-->
