# Source

The files and folders here contain the content that is pulled together for publishing to the
PowerShell Gallery. Information on the files and folders are included below.

- [`Private`](#private)
- [`Public`](#public)
- [`Templates`](#templates)

## Private

This folder contains the private classes, enums, and functions used by this module as well as their
unit tests.

During module composition, the code in this folder (except for the tests) is placed into the
generated `[[Name]].Private.psm1` file.

For more information, see [the folder's readme](Private/readme.md).

## Public

This folder contains the public classes, enums, and functions used by this module as well as their
unit tests.

During module composition, the code in this folder (except for the tests) is placed into the
generated `[[Name]].psm1` file.

For more information, see [the folder's readme](Public/readme.md).

## Templates

This folder contains the templated files and folders this module provides for users. It is copied
alongside the generated module manifest, root module, private module, and init script during
composition.

For more information, see [the folder's readme](Templates/readme.md).
