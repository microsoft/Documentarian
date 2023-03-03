# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Get-LocaleFreshness {

    [CmdletBinding()]
    [OutputType('DocumentLocaleInfo')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [uri]$Uri,

        [Parameter(Position = 1)]
        [ValidatePattern('[a-z]{2}-[a-z]{2}')]
        [string[]]$Locales = (
            'en-us', 'cs-cz', 'de-de', 'es-es', 'fr-fr', 'hu-hu', 'id-id', 'it-it',
            'ja-jp', 'ko-kr', 'nl-nl', 'pl-pl', 'pt-br', 'pt-pt', 'ru-ru', 'sv-se',
            'tr-tr', 'zh-cn', 'zh-tw'
        )
    )

    $locale = $uri.Segments[1].Trim('/')
    if ($locale -notmatch '[a-z]{2}-[a-z]{2}') {
        Write-Error "URL does not contain a valid locale: $locale"
        return
    } else {
        $url = $uri.OriginalString
        $Locales | ForEach-Object {
            $locPath = $_
            $result = Get-HtmlMetaTags ($url -replace $locale, $locPath) |
                Select-Object @{n = 'locpath'; e = { $locPath } }, locale, 'ms.contentlocale',
                'ms.translationtype', 'ms.date', 'loc_version', 'updated_at', 'loc_source_id',
                'loc_file_id', 'original_content_git_url'
                $result.pstypenames.Insert(0, 'DocumentLocaleInfo')
                $result
            } | Sort-Object 'updated_at', 'ms.contentlocale'
    }

}
