# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

$Script:UsePSResourceGet = $null -ne (Get-Module Microsoft.PowerShell.PSResourceGet -ListAvailable)
$Script:DefaultRepoName = 'Documentarian.Local'
$Script:DefaultRepoPath = Join-Path -Path (Split-Path $PSScriptRoot) -ChildPath '.repository'

$Preferences = $VerbosePreference, $DebugPreference
$VerbosePreference = $DebugPreference = 'SilentlyContinue'
if ($Script:UsePSResourceGet) {
    Import-Module -Name Microsoft.PowerShell.PSResourceGet
} else {
    Import-Module -Name PowerShellGet
}
$VerbosePreference, $DebugPreference = $Preferences


function Get-LocalRepository {
    [cmdletbinding()]
    param(
        [string]$RepoName = $Script:DefaultRepoName
    )
    $Preferences = $VerbosePreference, $DebugPreference
    $VerbosePreference = $DebugPreference = 'SilentlyContinue'
    if ($Script:UsePSResourceGet) {
        Get-PSResourceRepository | Where-Object Name -EQ $RepoName
    } else {
        Get-PSRepository | Where-Object Name -EQ $RepoName
    }
    $VerbosePreference, $DebugPreference = $Preferences
}

function Register-LocalRepository {
    [cmdletbinding()]
    param(
        [string]$RepoName = $Script:DefaultRepoName,
        [string]$RepoPath = $Script:DefaultRepoPath,
        [switch]$Clean,
        [switch]$Force
    )

    $LocalRepo = Get-LocalRepository -RepoName $RepoName

    if ($LocalRepo -and $Force) {
        Unregister-LocalRepository -RepoName $RepoName -Clean
    }

    if (!$LocalRepo -or $Force) {
        Write-Verbose "Registering local repository '$RepoName' at '$RepoPath'."

        if (-not (Test-Path -Path $RepoPath)) {
            $null = New-Item -Path $RepoPath -ItemType Directory -Force
        } elseif ($Clean -and ($null -ne (Get-ChildItem -Path $RepoPath -Recurse))) {
            Write-Verbose "Cleaning packages from local repository '$RepoName' at '$RepoPath'."
            Remove-Item -Path "$RepoPath/*" -Recurse -Force
        }
        $Preferences = $VerbosePreference, $DebugPreference
        $VerbosePreference = $DebugPreference = 'SilentlyContinue'
        if ($Script:UsePSResourceGet) {
            Register-PSResourceRepository -Name $RepoName -Uri $RepoPath -Trusted
        } else {
            Register-PSRepository -Name $RepoName -SourceLocation $RepoPath -InstallationPolicy Trusted
        }
        $VerbosePreference, $DebugPreference = $Preferences
        Write-Verbose "Registered local repository '$RepoName' at '$RepoPath'."
        $LocalRepo = Get-LocalRepository -RepoName $RepoName
    } else {
        Write-Verbose "Local repository '$RepoName' already registered."
    }

    $LocalRepo
}

function Unregister-LocalRepository {
    [cmdletbinding()]
    param(
        [string]$RepoName = $Script:DefaultRepoName,
        [switch]$Clean
    )

    $LocalRepo = Get-LocalRepository -RepoName $RepoName

    if ($LocalRepo) {
        Write-Verbose "Unregistering local repository '$RepoName'."
        $Preferences = $VerbosePreference, $DebugPreference
        $VerbosePreference = $DebugPreference = 'SilentlyContinue'
        $RepoFolder = if ($Script:UsePSResourceGet) {
            Unregister-PSResourceRepository -Name $RepoName
            $LocalRepo.Uri.LocalPath
        } else {
            $null = Unregister-PSRepository -Name $RepoName
            $LocalRepo.SourceLocation
        }
        $VerbosePreference, $DebugPreference = $Preferences
        Write-Verbose "Unregistered local repository '$RepoName' at '$RepoFolder'."
        if ($Clean) {
            Write-Verbose "Cleaning packages from unregistered local repository '$RepoName'."
            Remove-Item -Path "$RepoFolder/*" -Recurse -Force
            Write-Verbose "Cleaned packages from unregistered local repository '$RepoName'."
        }
    } else {
        Write-Verbose "Local repository '$RepoName' not registered."
    }
}

function Publish-LocalModule {
    [cmdletbinding(DefaultParameterSetName = 'ByPath')]
    param(
        [psmoduleinfo]$Module,
        [string]$RepoName = $Script:DefaultRepoName,
        [switch]$Force,
        [switch]$Retry,
        [switch]$Dependency
    )

    $LocalRepo = Get-LocalRepository -RepoName $RepoName

    if (!$LocalRepo) {
        $LocalRepo = Register-LocalRepository -RepoName $RepoName
    }

    if ($Retry) {
        Write-Verbose "Attempting to publish $Module again after resolving issues"
    } elseif ($Dependency) {
        Write-Verbose "Publishing dependency '$($Module.Name)' to local repository '$RepoName'."
    } else {
        $InitialPublishMessage = @(
            "Publishing module '$($Module.Name)' to local repository '$RepoName'. Module Info:"
            "`t`tVersion : $($Module.Version)"
            "`t`tPath    : $(Resolve-Path -Relative -Path $Module.Path)"
        ) -join "`n"
        Write-Verbose $InitialPublishMessage
    }

    $Path = Split-Path -Path $Module.Path -Parent
    try {
        $ErrorActionPreference = 'Stop'
        $Preferences = $VerbosePreference, $DebugPreference
        $VerbosePreference = $DebugPreference = 'SilentlyContinue'
        if ($Script:UsePSResourceGet) {
            Publish-PSResource -Path $Path -Repository $LocalRepo.Name
        } else {
            Publish-Module -Path $Path -Repository $LocalRepo.Name -Force:$Force
        }
        $VerbosePreference, $DebugPreference = $Preferences
        Write-Verbose "Published module '$($Module.Name)' to local repository '$RepoName'."
    } catch {
        $HandledErrors = @{
            AlreadyPublished  = 'ModuleVersionIsAlreadyAvailableInTheGallery'
            MissingDependency = 'UnableToResolveModuleDependency', 'DependencyNotFound'
        }
        $ErrorID = $_.FullyQualifiedErrorId -split ',' | Select-Object -First 1
        if ($ErrorID -in $HandledErrors.MissingDependency) {
            $Module.RequiredModules | ForEach-Object {
                $RequiredModule = Get-Module -ListAvailable $_ -Verbose:$false | Select-Object -First 1
                $VerbosePreference, $DebugPreference = $Preferences
                Publish-LocalModule -Module $RequiredModule -RepoName $RepoName -Force -Dependency
            }
            $VerbosePreference, $DebugPreference = $Preferences
            Publish-LocalModule -Module $Module -RepoName $RepoName -Force -Retry
        } elseif ($ErrorID -in $HandledErrors.AlreadyPublished) {
            $VerbosePreference, $DebugPreference = $Preferences
            Remove-LocalModule -Module $Module -RepoName $RepoName
            Publish-LocalModule -Module $Module -RepoName $RepoName -Force -Retry
        } else {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}

Function Remove-LocalModule {
    [cmdletbinding()]
    param(
        [psmoduleinfo]$Module,
        [string]$RepoName = $Script:DefaultRepoName
    )

    $LocalRepo = Get-LocalRepository -RepoName $RepoName

    if ($LocalRepo) {
        $RepoFolder = if ($Script:UsePSResourceGet) {
            $LocalRepo.Uri.LocalPath
        } else {
            $LocalRepo.SourceLocation
        }
        $PackageName = "$($Module.Name).$($Module.Version).nupkg"
        $PackagePath = Join-Path -Path $RepoFolder -ChildPath $PackageName
        if (Test-Path $PackagePath) {
            Write-Verbose "Removing package '$PackageName' from local repository '$RepoName'."
            Remove-Item -Path $PackagePath -Force
        } else {
            Write-Warning "Package '$PackageName' not found in folder '$RepoFolder'."
        }
    } else {
        Write-Warning "Local repository '$RepoName' not registered. No packages to remove."
    }
}

function Get-AllLocalModules {
    [cmdletbinding()]
    param(
        [string]$RepoName = $Script:DefaultRepoName
    )

    $LocalRepo = Get-LocalRepository -RepoName $RepoName

    if ($LocalRepo) {
        $Preferences = $VerbosePreference, $DebugPreference
        $VerbosePreference = $DebugPreference = 'SilentlyContinue'
        if ($Script:UsePSResourceGet) {
            Find-PSResource -Repository $LocalRepo.Name -Type Module
        } else {
            Find-Module -Repository $LocalRepo.Name
        }
        $VerbosePreference, $DebugPreference = $Preferences
    } else {
        Write-Warning "Local repository '$RepoName' not registered. No packages to find."
    }
}
