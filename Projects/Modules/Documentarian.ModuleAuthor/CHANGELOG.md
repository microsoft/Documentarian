---
title: Changelog
weight: 0
description: |
  All notable changes to the **Documentarian.ModuleAuthor** module are documented in this file.

  This changelog's format is based on [Keep a Changelog][01] and this project adheres to
  [Semantic Versioning][02].

  For releases before `1.0.0`, this project uses the following convention:

  - While the major version is `0`, the code is considered unstable.
  - The minor version is incremented when a backwards-incompatible change is introduced.
  - The patch version is incremented when a backwards-compatible change or bug fix is introduced.

  [01]: https://keepachangelog.com/en/1.0.0/
  [02]: https://semver.org/spec/v2.0.0.html
release_links:
  source_path: Projects/Modules/Documentarian.ModuleAuthor
  with_labels:
    - Documentarian.ModuleAuthor
  skip_labels:
    - maintenance
---

## Unreleased

Related Links
: {{< changelog/link/prs after="2023-03-27" >}}

### Added

- Update `Get-ParameterInfo` and `Find-ParameterWithAttribute` to support three more parameter
  attributes:

  - {{% xref "System.Management.Automation.CredentialAttribute" %}}
  - {{% xref "System.Management.Automation.PSDefaultValueAttribute" %}}
  - {{% xref "System.ObsoleteAttribute" %}}

- Added the [`Test-HelpInfoUri`] command to validate updateable help XML files for a module. You
  can use this command to check which modules have updateable help and verify your own published
  modules.

### Fixed

- Corrected the behavior for [`Get-ParameterInfo`] for parameters that belong to multiple parameter
  sets. Previously, the `Accept pipeline input` key wrote invalid metadata. Now, the metadata is
  valid.
- Fixed logic for handling default value of SwitchParameter types in `Get-ParameterInfo` and some
  minor code cleanup.

## 0.0.1 - 2023-03-27

Related Links
: {{< changelog/link/source tag="Documentarian.ModuleAuthor/v0.0.1" >}}

### Added

- Initial release.

<!-- Link Reference Definitions -->
[`Test-HelpInfoUri`]:  /modules/moduleauthor/reference/cmdlets/test-helpinfouri/
[`Get-ParameterInfo`]: /modules/moduleauthor/reference/cmdlets/get-parameterinfo/
