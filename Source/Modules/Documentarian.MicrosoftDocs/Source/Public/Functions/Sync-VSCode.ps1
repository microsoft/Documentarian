# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function Sync-VSCode {

    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Path
    )

    ### Get-GitStatus comes from the posh-git module.
    $gitStatus = Get-GitStatus
    if ($gitStatus) {
        $reponame = $GitStatus.RepoName
    } else {
        'Not a git repo.'
        return
    }
    $repoPath = $global:git_repos[$reponame].path
    $ops = Get-Content $repoPath\.openpublishing.publish.config.json | ConvertFrom-Json -Depth 10 -AsHashtable
    $srcPath = $ops.docsets_to_publish.build_source_folder
    if ($srcPath -eq '.') { $srcPath = '' }
    $basePath = Join-Path $repoPath $srcPath '\'
    $mapPath = Join-Path $basePath $ops.docsets_to_publish.monikerPath
    $monikers = Get-Content $mapPath | ConvertFrom-Json -Depth 10 -AsHashtable
    $startPath = (Get-Item $Path).fullname

    $vlist = $monikers.keys | ForEach-Object { $monikers[$_].packageRoot }
    if ($startpath) {
        $relPath = $startPath -replace [regex]::Escape($basepath)
        $version = ($relPath -split '\\')[0]
        foreach ($v in $vlist) {
            if ($v -ne $version) {
                $target = $startPath -replace [regex]::Escape($version), $v
                if (Test-Path $target) {
                    Start-Process -Wait -WindowStyle Hidden 'code' -ArgumentList '--diff', '--wait', '--reuse-window', $startpath, $target
                }
            }
        }
    } else {
        "Invalid path: $Path"
    }

}
