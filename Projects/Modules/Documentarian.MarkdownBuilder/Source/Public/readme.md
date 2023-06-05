# Public Source

This folder contains the public classes, enums, and functions used by this module as well as their
unit tests.

During module composition, the code in this folder (except for the tests) is placed into the
generated `Documentarian.MarkdownBuilder.psm1` file.

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

The [`.LoadOrder.jsonc`](Classes/.LoadOrder.jsonc) file determines the order the classes should be
loaded during composition; this is critical to ensure nothing breaks.

- [**CodeFenceCharacter**](Classes/CodeFenceCharacter.psm1): Represents the character used for a
  Markdown code fence. A friendly wrapper around the `CodeFenceCharacters` enum to convert the enum
  to the correct string.
- [**LineEnding**](Classes/LineEnding.psm1): Represents the character or characters used to start a
  new line. A friendly wrapper around the `LineEndings` enum to convert the enum to the correct
  string.
- [**MarkdownBuilder**](Classes/MarkdownBuilder.psm1): An extended wrapper around the
  [**System.Text.StringBuilder**][01] class, with special helpers for handling line endings, code
  blocks, and outputting the Markdown.

## Enums

This folder contains the public enums used by this module and their unit tests. During composition,
these enums are also included in the generated `Init.ps1` file, which enables automatic import of
the public enums into the caller's session for direct use.

The [`.LoadOrder.jsonc`](Enums/.LoadOrder.jsonc) file determines the order the classes should be
loaded during composition; this is critical to ensure nothing breaks.

- [**CodeFenceCharacters**](Enums/CodeFenceCharacters.psm1): A list of friendly names for the
  valid characters you can use in a Markdown code fence - `Backtick` (`` ` ``) and `Tilde` (`~`).
- [**LineEndings**](Enums/LineEndings.psm1): A list of shorthands for the valid characters you can
  use to start a new line - `CR` (`\r`), `LF` (`\n`), and `CRLF` (`\r\n`).

## Functions

This folder contains the public functions used by this module and their unit tests.

- [`Add-FrontMatter`](Functions/Add-FrontMatter.ps1): Adds a hashtable of key-value pairs to a
  **MarkdownBuilder** as YAML front matter. If a builder isn't passed to the function, it creates
  one. If the function detects that another command is called after it in the pipeline, it emits
  the builder. Otherwise, it only returns the builder if the user specifies the **PassThru**
  parameter.
- [`Add-Heading`](Functions/Add-Heading.ps1): Adds a heading to a **MarkdownBuilder**. If a builder
  isn't passed to the function, it creates one. If the function detects that another command is
  called after it in the pipeline, it emits the builder. Otherwise, it only returns the builder if
  the user specifies the **PassThru** parameter.
- [`Add-Line`](Functions/Add-Line.ps1): Adds a line of content to a **MarkdownBuilder**. If a
  builder isn't passed to the function, it creates one. If the function detects that another
  command is called after it in the pipeline, it emits the builder. Otherwise, it only returns the
  builder if the user specifies the **PassThru** parameter.
- [`New-MarkdownBuilder`](Functions/New-MarkdownBuilder.ps1):
- [`Start-CodeFence`](Functions/Start-CodeFence.ps1): Starts a new code fence in a
  **MarkdownBuilder**. If a builder isn't passed to the function, it creates one. If the function
  detects that another command is called after it in the pipeline, it emits the builder. Otherwise,
  it only returns the builder if the user specifies the **PassThru** parameter.
- [`Stop-CodeFence`](Functions/Stop-CodeFence.ps1): Closes the most recently opened code fence in a
  **MarkdownBuilder**. If a builder isn't passed to the function, it creates one. If the function
  detects that another command is called after it in the pipeline, it emits the builder. Otherwise,
  it only returns the builder if the user specifies the **PassThru** parameter.

[01]: https://learn.microsoft.com/dotnet/api/system.text.stringbuilder
