---
external help file: Documentarian.MicrosoftDocs-help.xml
Locale: en-US
Module Name: Documentarian.MicrosoftDocs
online version: https://microsoft.github.io/Documentarian/modules/microsoftdocs/reference/cmdlets/get-localefreshness
schema: 2.0.0
title: Get-LocaleFreshness
---

# Get-LocaleFreshness

## SYNOPSIS
Gets the `ms.date` metadata information of a Docs article for every locale.

## SYNTAX

```
Get-LocaleFreshness [-Uri] <uri> [[-Locale] <string[]>] [<CommonParameters>]
```

## DESCRIPTION

Gets the `ms.date` metadata information of a Docs article for every locale. The output includes the
locale information and the translation method. This is useful to see that the localization process
has picked up the latest changes made to the English version of the article.

For comparison, the output of the cmdlet always includes the English version of the article.

## EXAMPLES

### Example 1 - Get the freshness data for an article

In this example you can see that the English version of the article was updated on 08/02/2021, but
there are several localized version that still show the older version of the article.

The meaning of the values of **ms.translationtype** are:

- **HT** - human translated
- **MT** - machine translated

The **locpath** property is the target path in the URL. The values of **locpath**, **locale**, and
**ms.contentlocale** should match.

```powershell
$url = 'https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux'
Get-LocaleFreshness $url
```

```Output
locpath locale ms.contentlocale ms.translationtype ms.date    loc_version                  updated_at
------- ------ ---------------- ------------------ -------    -----------                  ----------
en-us   en-us                                      05/31/2022                              2022-05-31 10:03 PM
cs-cz   cs-cz  cs-cz            MT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
de-de   de-de  de-de            HT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
es-es   es-es  es-es            HT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
fr-fr   fr-fr  fr-fr            HT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
hu-hu   hu-hu  hu-hu            MT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
id-id   id-id  id-id            MT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
it-it   it-it  it-it            MT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
ja-jp   ja-jp  ja-jp            HT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
ko-kr   ko-kr  ko-kr            HT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
nl-nl   nl-nl  nl-nl            MT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
pl-pl   pl-pl  pl-pl            MT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
pt-br   pt-br  pt-br            HT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
pt-pt   pt-pt  pt-pt            MT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
ru-ru   ru-ru  ru-ru            HT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
sv-se   sv-se  sv-se            MT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
tr-tr   tr-tr  tr-tr            MT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
zh-cn   zh-cn  zh-cn            HT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
zh-tw   zh-tw  zh-tw            MT                 05/31/2022 2022-07-18T20:00:40.4523397Z 2022-08-17 10:12 PM
```

### Example 2 - Get the freshness data for an article for select languages

This example returns the locale freshness information of an article for the Portuguese languages.

```powershell
$url = 'https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux'
Get-LocaleFreshness $url pt-br, pt-pt
```

```Output
locpath locale ms.contentlocale ms.translationtype ms.date    loc_version                  updated_at
------- ------ ---------------- ------------------ -------    -----------                  ----------
en-us   en-us                                      01/09/2023                              2023-09-05 09:55 PM
pt-br   pt-br  pt-br            HT                 01/09/2023 2023-09-26T22:04:42.7240190Z 2023-10-13 11:23 PM
pt-pt   pt-pt  pt-pt            MT                 01/09/2023 2023-10-26T21:59:59.7444562Z 2023-10-26 11:59 PM
```

### Example 3 - Get the full freshness data for an article for select languages

This example returns the locale freshness information of an article for the Portuguese languages.

```powershell
$url = 'https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux'
Get-LocaleFreshness $url pt-br | Format-List -Property *
```

```Output
locpath                  : en-us
locale                   : en-us
ms.contentlocale         :
ms.translationtype       :
ms.date                  : 01/09/2023
loc_version              :
updated_at               : 2023-09-05 09:55 PM
loc_source_id            :
loc_file_id              :
original_content_git_url : https://github.com/MicrosoftDocs/PowerShell-Docs/blob/live/reference/docs-conceptual/install/In
                           stalling-PowerShell-on-Linux.md

locpath                  : pt-br
locale                   : pt-br
ms.contentlocale         : pt-br
ms.translationtype       : HT
ms.date                  : 01/09/2023
loc_version              : 2023-09-26T22:04:42.7240190Z
updated_at               : 2023-10-13 11:23 PM
loc_source_id            : Github-44411511#live
loc_file_id              : Github-44411511.live.PowerShell.PowerShell_PowerShell-docs_reference.docs-conceptual/install/In
                           stalling-PowerShell-on-Linux.md
original_content_git_url : https://github.com/MicrosoftDocs/PowerShell-Docs/blob/live/reference/docs-conceptual/install/In
                           stalling-PowerShell-on-Linux.md
```

## PARAMETERS

### -Locale

An array of one or more locale strings. The parameter default defaults to the following array of
values:

- `ar-sa`, `cs-cz`, `de-de`, `en-us`, `es-es`, `fr-fr`, `hu-hu`, `id-id`, `it-it`, `ja-jp`, `ko-kr`,
  `nl-nl`, `pl-pl`, `pt-br`, `pt-pt`, `ru-ru`, `sv-se`, `tr-tr`, `zh-cn`, `zh-tw`

The value can be any of the locales supported by the docs platform:

- `ar-sa`, `bg-bg`, `bs-latn-ba`, `ca-es`, `cs-cz`, `da-dk`, `de-at`, `de-ch`, `de-de`, `el-gr`,
  `en-au`, `en-ca`, `en-gb`, `en-ie`, `en-in`, `en-my`, `en-nz`, `en-sg`, `en-us`, `en-za`, `es-es`,
  `es-mx`, `et-ee`, `eu-es`, `fi-fi`, `fil-ph`, `fr-be`, `fr-ca`, `fr-ch`, `fr-fr`, `ga-ie`,
  `gl-es`, `he-il`, `hi-in`, `hr-hr`, `hu-hu`, `id-id`, `is-is`, `it-ch`, `it-it`, `ja-jp`, `ka-ge`,
  `kk-kz`, `ko-kr`, `lb-lu`, `lt-lt`, `lv-lv`, `ms-my`, `mt-mt`, `nb-no`, `nl-be`, `nl-nl`, `pl-pl`,
  `pt-br`, `pt-pt`, `ro-ro`, `ru-ru`, `sk-sk`, `sl-si`, `sr-cyrl-rs`, `sr-latn-rs`, `sv-se`,
  `th-th`, `tr-tr`, `uk-ua`, `vi-vn`, `zh-cn`, `zh-hk`, `zh-tw`

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 'ar-sa', 'en-us', 'cs-cz', 'de-de', 'es-es', 'fr-fr', 'hu-hu', 'id-id', 'it-it', 'ja-jp', 'ko-kr', 'nl-nl', 'pl-pl', 'pt-br', 'pt-pt', 'ru-ru', 'sv-se', 'tr-tr', 'zh-cn', 'zh-tw'
Accept pipeline input: False
Accept wildcard characters: False
```

### -Uri

The URL to the article being inspected. The URL must contain a supported locale.

```yaml
Type: System.Uri
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### DocumentLocaleInfo

The **locpath** property is the target path in the URL. The values of **locpath**, **locale**, and
**ms.contentlocale** should match.

The other properties are values of HTML `<meta>` tags in the published articles. The values of these
tags are set by the build system when the article is published.

## NOTES

This cmdlet depends on the `Get-HtmlMetaTags` cmdlet.

## RELATED LINKS
