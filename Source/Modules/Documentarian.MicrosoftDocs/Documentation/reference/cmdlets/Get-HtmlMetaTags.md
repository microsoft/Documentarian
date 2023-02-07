---
external help file: Documentarian.MicrosoftDocs-help.xml
Module Name: Documentarian.MicrosoftDocs
ms.date: 02/07/2023
schema: 2.0.0
title: Get-HtmlMetaTags
---

# Get-HtmlMetaTags

## SYNOPSIS
Gets all of the HTML `<meta>` elements of a web page.

## SYNTAX

```
Get-HtmlMetaTags [[-ArticleUrl] <Uri>] [-ShowRequiredMetadata] [<CommonParameters>]
```

## DESCRIPTION

Gets all of the HTML `<meta>` elements of a web page. This is use to see the Docs metadata in the
published article.

## EXAMPLES

### Example 1 - Get the `ms.*` meta tags

```powershell
$url = 'https://docs.microsoft.com/powershell/scripting/install/installing-powershell-core-on-windows'
Get-HtmlMetaTags $url | Select-Object ms.*
```

```Output
ms.author     : sewhee
ms.date       : 08/02/2021
ms.devlang    : powershell
ms.prod       : powershell
ms.technology : powershell-conceptual
ms.tgt_pltfr  : windows, macos, linux
ms.topic      : conceptual
```

### Example 2 - Show only the require metadata

```powershell
$url = 'https://docs.microsoft.com/powershell/scripting/install/installing-powershell-core-on-windows'
Get-HtmlMetaTags $url -ShowRequiredMetadata
```

```Output
title         :
og:title      : Installing PowerShell on Windows - PowerShell
description   : Information about installing PowerShell on Windows
ms.manager    :
ms.author     : sewhee
author        : sdwheeler
ms.service    :
ms.date       : 08/02/2021
ms.topic      : conceptual
ms.subservice :
ms.prod       : powershell
ms.technology : powershell-conceptual
ms.custom     :
ROBOTS        : INDEX, FOLLOW
```

## PARAMETERS

### -ArticleUrl

The URL to the Docs article you want to inspect.

```yaml
Type: System.Uri
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowRequiredMetadata

Filters the output to show only the metadata require by the OPS publishing system.

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

### COMMONPARAMETERS

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
