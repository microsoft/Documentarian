# Documentarian Modules

The Documentarian Modules are an open source toolkit for documentarians and community contributors
to reduce friction and provide a delightful experience for contributing to and maintaining
documentation.

Proposed modules include:

- 🛠 **Documentarian**: A module for managing Markdown documentation in general. Parsing,
  organizing, restructuring, and exporting documentation.

- 🛠 **Documentarian.DevX**: A module for reducing the friction for authoring the Documentarian
  modules, including shared tools and workflows.

- 🛠 **Documentarian.Vale**: A module for linting the _prose_ of a document, rather than its syntax,
  with the [Vale][01] command-line tool. Eases the installation, updating, configuration, and
  calling of `vale` from PowerShell.

- 🔮 **Documentarian.MarkdownLint**: A module for linting the _syntax_ of a document, rather than
  its prose, with the [markdownlint][02] command-line tool. Eases the installation, updating,
  configuration, and calling of `markdownlint` from PowerShell.

- 🛠 **Documentarian.ModuleAuthor**: A module for writing and maintaining PowerShell module
  documentation as a supplement to **PlatyPS**.
  - Depends on **PlatyPS**, **Documentarian**, **Documentarian.Vale**, and
    **Documentarian.MarkdownLint**.

- 🛠 **Documentarian.MicrosoftDocs**: A module for maintainers and contributors to Microsoft
  documentation, including [learn.microsoft.com][03] specific syntax, rules, and
  workflows.
  - Depends on **Documentarian**, **Documentarian.Vale**, and **Documentarian.MarkdownLint**

> Modules marked 🛠 are already under active development. Modules marked 🔮 are planned for future
> work.

<!-- Reference Links -->

[01]: https://vale.sh
[02]: https://github.com/DavidAnson/markdownlint
[03]: https://learn.microsoft.com/
