---
title: Changelog
weight: 0
description: |
  All notable changes to the **Documentarian.MicrosoftDocs** module are documented in this file.

  This changelog's format is based on [Keep a Changelog][01] and this project adheres to
  [Semantic Versioning][02].

  For releases before `1.0.0`, this project uses the following convention:

  - While the major version is `0`, the code is considered unstable.
  - The minor version is incremented when a backwards-incompatible change is introduced.
  - The patch version is incremented when a backwards-compatible change or bug fix is introduced.

  [01]: https://keepachangelog.com/en/1.0.0/
  [02]: https://semver.org/spec/v2.0.0.html
release_links:
  source_path: Projects/Modules/Documentarian.MicrosoftDocs
  with_labels:
    - Documentarian.MicrosoftDocs
  skip_labels:
    - maintenance
---

## Unreleased

- Add new class for `Get-LocaleFreshness` to define lists of default and supported locales.

- Added [`Get-CmdletXref`] to make it simpler to add links to cmdlet reference docs.

[`Get-CmdletXref`]: /modules/microsoftdocs/reference/cmdlets/get-cmdletxref/

Related Links
: {{< changelog/link/prs after="2023-03-27" >}}

## 0.0.1 - 2023-03-27

Related Links
: {{< changelog/link/source tag="Documentarian.MicrosoftDocs/v0.0.1" >}}

### Added

- Initial release.

<!-- Link Reference Definitions -->
