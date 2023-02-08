---
external help file: Documentarian-help.xml
Module Name: Documentarian
ms.date: 02/07/2023
schema: 2.0.0
title: Convert-MDLinks
---

# Convert-MDLinks

## SYNOPSIS

Converts Markdown hyperlinks to numbered link references.

## SYNTAX

```
Convert-MDLinks [-Path] <string[]> [-PassThru] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet finds all hyperlinks and link references in a Markdown file then replaces all links with
numbered link references. The link reference definitions are added to the end of the file. Existing
link reference definitions aren't removed. You must edit the updated Markdown file to remove them.
This gives you the opportunity to inspect the new link definitions to ensure accuracy.

## EXAMPLES

### Example 1 - Convert links in a single file

```powershell
Convert-MDLinks .\overview.md
```

### Example 2 - Convert links in a multiple file

```powershell
Convert-MDLinks .\*.md
```

### Example 3 - Show information about the hyperlinks in a file

When you use the **PassThru** parameter, the cmdlet return information about the hyperlinks in the
Markdown file but does not change the file.

```powershell
Convert-MDLinks .\README.md -PassThru
```

```Output
mdlink  : [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/)
target  : https://opensource.microsoft.com/codeofconduct/
ref     :
label   : Microsoft Open Source Code of Conduct
newlink : [Microsoft Open Source Code of Conduct][05]

mdlink  : [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/)
target  : https://opensource.microsoft.com/codeofconduct/faq/
ref     :
label   : Code of Conduct FAQ
newlink : [Code of Conduct FAQ][06]

mdlink  : [opencode@microsoft.com](mailto:opencode@microsoft.com)
target  : mailto:opencode@microsoft.com
ref     :
label   : opencode@microsoft.com
newlink : [opencode@microsoft.com][09]

mdlink  : [![Build Status](https://apidrop.visualstudio.com/Content%20CI/_apis/build/status/PROD/CabGen(PowerShell_Upda
          table_Help)
target  : https://apidrop.visualstudio.com/Content%20CI/_apis/build/status/PROD/CabGen(PowerShell_Updatable_Help
ref     :
label   : ![Build Status
newlink : [![Build Status][03]

mdlink  : [learn.microsoft.com]([https://learn.microsoft.com/powershell/scripting/)
target  : [https://learn.microsoft.com/powershell/scripting/
ref     :
label   : learn.microsoft.com
newlink : [learn.microsoft.com][01]

mdlink  : [Contribution License Agreement](https://cla.microsoft.com/)
target  : https://cla.microsoft.com/
ref     :
label   : Contribution License Agreement
newlink : [Contribution License Agreement][04]

mdlink  : [contributor's guide](https://aka.ms/PSDocsContributor)
target  : https://aka.ms/PSDocsContributor
ref     :
label   : contributor's guide
newlink : [contributor's guide][02]
```

## PARAMETERS

### -PassThru

Outputs information about the hyperlinks in a file without altering the file.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

An array of one or more paths to Markdown files. This parameter support wildcards.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

This cmdlet produces no output unless you use the **PassThru** parameter.

## NOTES

## RELATED LINKS
