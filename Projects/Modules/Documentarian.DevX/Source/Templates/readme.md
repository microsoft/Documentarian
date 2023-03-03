# Templates

This folder contains the templated files and folders this module provides for users. It is copied
alongside the generated module manifest, root module, private module, and init script during
composition.

<!-- Notes on how this is organized, etc. -->

## Module

Use the `Module` template folder to create a new `Documentarian` module with the `Copy-Template`
cmdlet. It scaffolds the files and folders for the new module's documentation and source code as
well as a build script, changelog, and readme file.

You can use the **TemplateData** parameter to modify the text in the copied files:

- **Name** - Specify the full name of the module with any dot-path prefixes if needed.
- **ShortName** - For module names with a dot-path prefix, specify the final segment only. For
  other modules, specify the full name again.

### Example

This example creates the `Documentarian.markdownlint` module:

```powershell
$TemplateParameters = @{
  TemplatePath    = 'Module'
  DestinationPath = './Source/Modules/Documentarian.markdownlint'
  TemplateData    = @{
    Name      = 'Documentarian.markdownlint'
    ShortName = 'markdownlint'
  }
}
Copy-Template @TemplateParameters
```
