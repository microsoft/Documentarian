---
title: Style Configuration
linktitle: Configuration
weight: 10
summary: Reference documentation for the Vale style configuration in the PowerShell-Docs style package.
description: >-
  Reference documentation for the Vale style configuration in the **PowerShell-Docs** style package.
resources:
  - src: .vale.ini
---

{{% src path="/includes/source/styles/psdocs/.vale.ini" title="Definition" lang="ini" /%}}

The **PowerShell-Docs** style package includes a `.vale.ini` configuration. The configuration
definition allows the **PowerShell-Docs** style to build on the **Microsoft** and **alex** styles.
When you specify **PowerShell-Docs** in the `BasedOnStyles` key for your own configuration, these
other styles are included automatically.

The configuration also turns off existing rules in those styles as they are replaced or not needed
when working on documentation for PowerShell projects.
