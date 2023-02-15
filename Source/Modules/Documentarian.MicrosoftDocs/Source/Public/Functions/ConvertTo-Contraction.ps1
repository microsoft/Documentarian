# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function ConvertTo-Contraction {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [SupportsWildcards()]
        [string[]]$Path,

        [switch]$Recurse
    )

    ### This function converts common word pairs to contractions. It doesn't handle all possible
    ### cases and it is not aware of code blocks.

    $contractions = @{
        lower = @{
            '([\s\n])are([\s\n])not([\s\n])'    = "`$1aren't`$3"
            '([\s\n])cannot([\s\n])'            = "`$1can't`$2"
            '([\s\n])could([\s\n])not([\s\n])'  = "`$1couldn't`$3"
            '([\s\n])did([\s\n])not([\s\n])'    = "`$1didn't`$3"
            '([\s\n])do([\s\n])not([\s\n])'     = "`$1don't`$3"
            '([\s\n])does([\s\n])not([\s\n])'   = "`$1doesn't`$3"
            '([\s\n])has([\s\n])not([\s\n])'    = "`$1hasn't`$3"
            '([\s\n])have([\s\n])not([\s\n])'   = "`$1haven't`$3"
            '([\s\n])is([\s\n])not([\s\n])'     = "`$1isn't`$3"
            '([\s\n])it([\s\n])is([\s\n])'      = "`$1it's`$3"
            '([\s\n])should([\s\n])not([\s\n])' = "`$1shouldn't`$3"
            '([\s\n])that([\s\n])is([\s\n])'    = "`$1that's`$3"
            '([\s\n])they([\s\n])are([\s\n])'   = "`$1they're`$3"
            '([\s\n])was([\s\n])not([\s\n])'    = "`$1wasn't`$3"
            '([\s\n])what([\s\n])is([\s\n])'    = "`$1what's`$3"
            '([\s\n])we([\s\n])are([\s\n])'     = "`$1we're`$3"
            '([\s\n])we([\s\n])have([\s\n])'    = "`$1we've`$3"
            '([\s\n])were([\s\n])not([\s\n])'   = "`$1weren't`$3"
        }
        upper = @{
            '([\s\n])Are([\s\n])not([\s\n])'    = "`$1Aren't`$3"
            '([\s\n])Cannot([\s\n])'            = "`$1Can't`$2"
            '([\s\n])Could([\s\n])not([\s\n])'  = "`$1Couldn't`$3"
            '([\s\n])Did([\s\n])not([\s\n])'    = "`$1Didn't`$3"
            '([\s\n])Do([\s\n])not([\s\n])'     = "`$1Don't`$3"
            '([\s\n])Does([\s\n])not([\s\n])'   = "`$1Doesn't`$3"
            '([\s\n])Has([\s\n])not([\s\n])'    = "`$1Hasn't`$3"
            '([\s\n])Have([\s\n])not([\s\n])'   = "`$1Haven't`$3"
            '([\s\n])Is([\s\n])not([\s\n])'     = "`$1Isn't`$3"
            '([\s\n])It([\s\n])is([\s\n])'      = "`$1It's`$3"
            '([\s\n])Should([\s\n])not([\s\n])' = "`$1Shouldn't`$3"
            '([\s\n])That([\s\n])is([\s\n])'    = "`$1That's`$3"
            '([\s\n])They([\s\n])are([\s\n])'   = "`$1They're`$3"
            '([\s\n])Was([\s\n])not([\s\n])'    = "`$1Wasn't`$3"
            '([\s\n])What([\s\n])is([\s\n])'    = "`$1what's`$3"
            '([\s\n])We([\s\n])are([\s\n])'     = "`$1We're`$3"
            '([\s\n])We([\s\n])have([\s\n])'    = "`$1We've`$3"
            '([\s\n])Were([\s\n])not([\s\n])'   = "`$1Weren't`$3"
        }
    }

    foreach ($filepath in $Path) {
        Get-ChildItem -Path $filepath -Recurse:$Recurse | ForEach-Object {
            Write-Host $_.name
            $mdtext = Get-Content $_ -Raw
            foreach ($key in $contractions.lower.keys) {
                $mdtext = $mdtext -creplace $key, $contractions.lower[$key]
            }
            foreach ($key in $contractions.upper.keys) {
                $mdtext = $mdtext -creplace $key, $contractions.upper[$key]
            }
            Set-Content -Path $_ -Value $mdtext -Encoding utf8 -Force
        }
    }

}
