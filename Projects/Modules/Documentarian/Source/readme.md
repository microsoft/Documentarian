# Source

The files and folders here contain the content that is pulled together for publishing to the
PowerShell Gallery. Information on the files and folders are included below.

- [`Documentarian.psd1`](#documentarianpsd1)
- [`Documentarian.psm1`](#documentarianpsm1)
- [`Private`](#Private)
- [`Public`](#Public)

## Private

This folder contains the private classes, enums, and functions used by this module as well as their
unit tests.

During module composition, the code in this folder (except for the tests) is placed into the
generated `Documentarian.Private.psm1` file.

For more information, see [the folder's readme](Private/readme.md).

## Public

This folder contains the public classes, enums, and functions used by this module as well as their
unit tests.

During module composition, the code in this folder (except for the tests) is placed into the
generated `Documentarian.psm1` file.

For more information, see [the folder's readme](Public/readme.md).
