# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ..\Classes\LearnLocales.psm1

function Get-LocaleFreshness {

    [CmdletBinding()]
    [OutputType('DocumentLocaleInfo')]
    param(
        [Parameter(Mandatory, Position = 0)]
        [uri]$Uri,

        [Parameter(Position = 1)]
        [ValidateScript({ $_ -in [LearnLocales]::SupportedLocales })]
        [string[]]$Locale = [LearnLocales]::CommonLocales
    )

    $localeInUrl = $uri.Segments[1].Trim('/')
    if ($localeInUrl -notin [LearnLocales]::SupportedLocales) {
        Write-Error "URL does not contain a supported locale: $localeInUrl"
        return
    } else {
        $url = $uri.OriginalString
        if ($Locale -notcontains 'en-us') { $Locale += 'en-us' }
        $Locale | ForEach-Object {
            $locPath = $_
            $result = Get-HtmlMetaTags ($url -replace $localeInUrl, $locPath) |
                Select-Object @{n = 'locpath'; e = { $locPath } }, locale, 'ms.contentlocale',
                'ms.translationtype', 'ms.date', updated_at, loc_version,
                loc_source_id, loc_file_id, original_content_git_url
                $result.pstypenames.Insert(0, 'DocumentLocaleInfo')
                $result
            } | Sort-Object 'updated_at', 'ms.contentlocale'
    }

}
