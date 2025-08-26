---
title: Changelog
weight: 0
description: |
  All notable changes to the **Documentarian** module are documented in this file.

  This changelog's format is based on [Keep a Changelog][01] and this project adheres to
  [Semantic Versioning][02].

  For releases before `1.0.0`, this project uses the following convention:

  - While the major version is `0`, the code is considered unstable.
  - The minor version is incremented when a backwards-incompatible change is introduced.
  - The patch version is incremented when a backwards-compatible change or bug fix is introduced.

  [01]: https://keepachangelog.com/en/1.0.0/
  [02]: https://semver.org/spec/v2.0.0.html
release_links:
  source_path: Projects/Modules/Documentarian
  with_labels:
    - Documentarian
  skip_labels:
    - maintenance
---

## Unreleased

- Fixed bug in `Update-Metadata` and properly handle missing front matter
- Updated `*-Metadata` cmdlets to use `Get-Document` to parse the content of markdown files
- Added **AsJson** parameter to `Get-Metadata` to output the results as a JSON object

Related Links
: {{< changelog/link/prs after="2023-03-27" >}}

### Changed

- Replaced dependency on the [PowerShell-yaml] module with [YaYaml] - this resolves the YamlDotNet
  dependency conflict that prevents the module from being used with PlatyPS. Only the dependency is
  changed, not the functionality.

### Fixed

- [`Convert-MDLinks`] - filter out matching patterns contained in code blocks.
- Ensure that [`Convert-MDLinks`] correctly handles all matches found by the regex patterns.

## 0.0.1 - 2023-03-27

Related Links
: {{< changelog/link/source tag="Documentarian/v0.0.1" >}}

### Added

- Initial release.

<!-- Link Reference Definitions -->
[`Convert-MDLinks`]: /modules/documentarian/reference/cmdlets/convert-mdlinks
[powershell-yaml]:   https://github.com/cloudbase/powershell-yaml
[YaYaml]:            https://github.com/jborean93/PowerShell-Yayaml
