# Documentarian.MarkdownBuilder

The **Documentarian.MarkdownBuilder** module includes classes and functions to make it easier for
you to construct Markdown documents and snippets in your code. It includes the **MarkdownBuilder**
class as an extended wrapper around the [**StringBuilder**][01] class, with handling for code
fences and line endings.

The included functions present a friendly interface over the **MarkdownBuilder** class so you can
write Markdown in your functions and scripts.

For example, you can create a document with multiple headings and nested code blocks:

```powershell
$mdb = Add-Heading -Content 'Example Document' -Level 1 |
    Add-Line 'A **MarkdownBuilder** example.' |
    Add-Line |
    Add-Heading -Content Codeblocks -Level 2 |
    Add-Line 'This section shows nested code blocks.' |
    Start-CodeFence -Language markdown |
    Add-line '- first' |
    Add-Line '- second' |
    Add-Line |
    Start-CodeFence -Language powershell |
    Add-Line 'gci -recurse' |
    Stop-CodeFence |
    Stop-CodeFence |
    Add-Line 'Last line of the document.' -PassThru

$mdb.toString()
```

``````markdown
# Example Document

A **MarkdownBuilder** example.

## Codeblocks

This section shows nested code blocks.

````markdown
- first
- second

```powershell
gci -recurse
```

````

Last line of the document.

``````

## Requirements

- PowerShell 5.1+

[01]: https://learn.microsoft.com/dotnet/api/system.text.stringbuilder
