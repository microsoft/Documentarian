---
title: Documentarian.MarkdownBuilder
linkTitle: MarkdownBuilder
summary: |
  The **Documentarian.MarkdownBuilder** module provides functions for writing Markdown through the
  **MarkdownBuilder** object, which provides a friendly wrapper around the
  **System.Text.StringBuilder** class.
description: >-
  Commands and helpers for interacting with a specialized string builder for Markdown.
weight: 99
cascade:
  pwsh:
    source:
      root: /includes/source/
      lang: powershell
      munging:
        partials:
          - pwsh/src/munge/
  gh_feedback:
    issues:
      # module: Documentarian # ineffective, see: https://github.com/community/community/discussions/5288
      labels: Documentarian.MarkdownBuilder
---

The **Documentarian.MarkdownBuilder** module provides functions for writing Markdown through the
**MarkdownBuilder** object, which provides a friendly wrapper around the
**{{% xref "System.Text.StringBuilder" %}}** class.

You can use it to write Markdown programmatically in your scripts and functions. It supports
chaining writing statements in the pipeline, like chaining methods on **StringBuilder**.

The **MarkdownBuilder** supports defining and overriding default values for how it writes new lines
and code fences. It tracks code fences as you open and close them, automatically ensuring that your
codeblocks remain valid even when you add a nested code block.
