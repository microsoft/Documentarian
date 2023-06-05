# Source

The files and folders here contain the content that's pulled together for publishing to the
PowerShell Gallery. Information on the files and folders are included below.

- [`Private`](#private)
- [`Public`](#public)

## Private

This folder has the private classes, enums, and functions used by this module as well as their
unit tests.

During module composition, the code in this folder (except for the tests) is placed into the
generated `Documentarian.MarkdownBuilder.Private.psm1` file.

For more information, see [the folder's readme](Private/readme.md).

## Public

This folder has the public classes, enums, and functions used by this module as well as their
unit tests.

During module composition, the code in this folder (except for the tests) is placed into the
generated `Documentarian.MarkdownBuilder.psm1` file.

For more information, see [the folder's readme](Public/readme.md).
