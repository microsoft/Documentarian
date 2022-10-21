# Conventional Commits

This one-pager describes the [conventional commit][01] methodology and proposes an implementation
for our work.

## Why we use conventional commits

Conventional commits provide a standard semantic way to read and understand change history. For a
large project, particularly a monorepo, this standard can reduce cognitive load and help maintainers
to orient themselves when reviewing changes and history.

## What conventional commits are

Conventional commits are ones that adhere to the following structure:

```text
<type>[(<scope>)][<breaking-change>]: <synopsis>

[<body>]

[<footers>]
```

For example:

```text
fix(pwsh.DevX): Respect source code headers

Prior to this change, the `*-SourceFile` cmdlets didn't respect the license
and copyright headers in source files. They were munged or lost instead and
the composed module files didn't reliably include them.

This change ensures that discovered license and copyright headers are
placed and preserved as naively expected.
```

## Syntax Components

### Types

The following types are supported, with their weight listed in parentheses:

- `build` (6): Changes affecting a build system or process
- `ci` (5): Changes to the CI configuration/scripting
- `deps` (7): Changes the dependency graph of a source project
- `docs` (3): Changes only for documentation
- `feat` (11): Change introduces new functionality or features
- `fix` (10): Change solves a problem with code
- `perf` (4): Change improves performance
- `refactor` (8): Change doesn't introduce new functionality or fix a problem
- `revert` (9): Change removes previous work
- `style` (1): Change only effects source file readability/syntax, not functionality
- `test` (2): Change only effects test definitions

If a commit can support more than one scope, follow one of these two processes:

1. Decompose the commit into at least one commit for each type. This makes for smaller commits that
   are easier to review, revert, and understand. This is _preferred_ for complex changes and
   **required** for changes that include a `revert`.
1. Use the highest-weighted type for the commit and clarify changes in the body. It may not be
   uncommon to have a `feat` or `fix` that also includes `docs`, `test`, etc changes.

### Scopes

Scopes help orient _what_ the change affects. For the Documentarian project, we use these scopes:

- `pwsh[.<id>]` - For the PowerShell modules. If no ID is specified, the commit applies to the main
  **Documentarian** module. To specify the ID, include the module name without the `Documentarian`
  prefix, like `pwsh.DevX` for the **Documentarian.DevX** module.
- `hugo[.<id>]` - For the Hugo module code. If no ID is specified, the commit applies to
  `docsy-pwsh` by default.
- `vale[.<id>]` - For the Vale style packages. If no ID is specified, the commit applies to the
  `PowerShell-Docs` package.
- `dict[.<id>]` - For the cSpell dictionaries. If no ID is specified, the commit applies to the
  `PowerShell-Docs` dictionary.
- `site` - For the site configuration and source files.

### Breaking Change

If a commit introduces a breaking change---one that isn't backwards compatible---then the commit
header must be postfixed with an exclamation mark (`!`) to visually identify this. The commit's
[footer](#footers) should also clearly state how and why this is a breaking change.

### Synopsis

Every commit should have a brief summary of the changes it makes as an imperative statement. For
example:

```text
Add `Get-Foo` cmdlet
```

```text
Handle license headers in source code
```

### Body

When the **Synopsis** alone isn't enough to explain and detail the changes for a commit, write a
body paragraphs for that purpose. The preferred structure for the body is:

1. **Prior to this change**... describes the context that made this change necessary.
1. **This change**... describes how and why this commit addresses the prior context.

Write the body in Markdown. This ensures automatic formatting on GitHub.

Limit the line length of the body to 80 characters. This makes it easier to read the commits in the
console and in CI tools.

Use link-references for any necessary links. This makes it easier to read the content of the body
without the interruptions of link definitions.

#### Example Body

```text
Prior to this change, the project depended on [SomeProject v3.2][01]. There is
a [security bug][02] in that version, which we need to resolve for our own
users.

This change updates the dependency to [v3.3][03], which includes the patch for
the vulnerability.

[01]: https://github.com/SomeGroup/SomeProject/releases/v3.2.5
[02]: https://SomeGroup.github.io/SomeProject/announcements/security#3.2.5
[03]: https://github.com/SomeGroup/SomeProject/releases/v3.3.0
```

### Footers

Footers follow the body. The supported footers include:

- Breaking Changes
- References
- Resolutions

#### Breaking Changes

Use the following syntax to identify breaking changes:

```text
BREAKING CHANGE: <Synopsis>

[<Body>]
```

The rules for **Synopsis** and **Body** in the footer are the same as for the commit message as a
whole.

#### Work Items

Use this footer to list work items that provide additional context for the commit or that the commit
fixes, closes, or resolves. This section should always:

- Start with `Work Items:` followed by a blank line.
- Include an unordered list of work items, each starting with a dash (`-`), followed by a space,
  and then the entry.
- Use a hash mark (`#`) followed by the numeral id of the issue, pull request, or discussion, not a
  link to the same.

  Good:

  ```text
  - #123
  - <organization>/<repository>#234
  ```

  Bad:

  ```text
  - [123](https://github.com/microsoft/Documentarian/issues/123)
  ```

- Use the appropriate [keyword][02] if the commit closes, fixes, or resolves the work item

For example:

```text
Work Items:

- #123
- Fixes #234
- Resolves Foo/Bar#345
```

[01]: https://www.conventionalcommits.org/en/v1.0.0/
[02]: https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue#linking-a-pull-request-to-an-issue-using-a-keyword
