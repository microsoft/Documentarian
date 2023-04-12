---
title: Changelog
weight: 0
description: |
  All notable changes to the **Documentarian.Vale** module are documented in this file.

  This changelog's format is based on [Keep a Changelog][01] and this project adheres to
  [Semantic Versioning][02].

  For releases before `1.0.0`, this project uses the following convention:

  - While the major version is `0`, the code is considered unstable.
  - The minor version is incremented when a backwards-incompatible change is introduced.
  - The patch version is incremented when a backwards-compatible change or bug fix is introduced.

  [01]: https://keepachangelog.com/en/1.0.0/
  [02]: https://semver.org/spec/v2.0.0.html
release_links:
  source_path: Projects/Modules/Documentarian.Vale
  with_labels:
    - Documentarian.Vale
  skip_labels:
    - maintenance
---

## Unreleased

Related Links
: {{< changelog/link/prs after="2023-04-06" >}}

## 0.1.0 - 2023-04-06

Related Links
: {{< changelog/link/source tag="Documentarian.Vale/v0.1.0" >}}
: {{< changelog/link/prs after="2023-03-27" before="2023-04-06" >}}

### Changed

- Renamed `Install-WorkspaceVale` to [`Install-Vale`] and added the **Scope** parameter, enabling
  users to install Vale to their home directory as well as the workspace. This change ensures that
  the other module commands are also able to use Vale when installed to your home directory, not
  just the `PATH` or workspace.
- Updated the logic for discovering Vale in the workspace to recursively search up the file tree
  from the current working directory instead of only searching the current directory. This makes
  the commands available from arbitrarily deep folders when using Vale installed to the workspace.

## 0.0.1 - 2023-03-27

Related Links
: {{< changelog/link/source tag="Documentarian.Vale/v0.0.1" >}}

### Added

- Initial release.

<!-- Link Reference Definitions -->
[`Install-Vale`]: /modules/vale/reference/cmdlets/install-vale
