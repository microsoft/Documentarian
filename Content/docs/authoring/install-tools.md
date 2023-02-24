---
title: Install Documentarian and related tools
linkTitle: Install tools
description: Guidance for installing Documentarian and related tools.
---

# Install tools

## Install PowerShell modules

Requirements:

- PowerShell version 7.2 or later
- The **PowerShell-Yaml** module. You can install it from the PowerShell Gallery:

  ```powershell
  Install-Module -Name PowerShell-Yaml
  ```

Next, you need to download the latest build from the Documentarian GitHub repository.

1. Select the latest successful workflow run for the [Build Modules GitHub Action][01].
1. In **Artifacts**, download the **Documentarian** zip file.
1. Extract the **Documentarian** module from the zip file.
1. Import the modules into your PowerShell session. For example, `Import-Module Documentarian.psd1`.

## Install VS Code extensions

- Install [Vale VS Code extension][02]
- Install [Error lens extension][03]

<!-- Link Reference Definitions -->
[01]: https://github.com/microsoft/Documentarian/actions/workflows/build.pwsh.yaml
[02]: https://marketplace.visualstudio.com/items?itemName=errata-ai.vale-server
[03]: https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens
