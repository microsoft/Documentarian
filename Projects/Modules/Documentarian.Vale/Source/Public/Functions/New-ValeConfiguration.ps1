# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Enums/ValeAlertLevel.psm1
using module ../Classes/ValeStylePackageTransformAttribute.psm1
using module ../Classes/ValeStyleNameTransformAttribute.psm1

function New-ValeConfiguration {
    [cmdletbinding()]
    [OutputType([System.IO.FileSystemInfo])]
    param(
        [Parameter(Position = 0)]
        [string]$FilePath = './.vale.ini',

        [string]$StylesPath,

        [ValeAlertLevel]$MinimumAlertLevel,

        [ValeStylePackageTransform()]
        [string[]] $StylePackage,

        [switch]$Force,

        [switch]$PassThru,

        [switch]$NoSpelling,

        [switch]$NoSync
    )

    begin {
        # The configuration needs to be ordered and the root section must be defined first.
        # The implementation for PsIni skips writing a section when adding sectionless keys,
        # so if they come after the '*' section, the configuration file is malformed.
        $Configuration = New-Object -TypeName System.Collections.Specialized.OrderedDictionary
        $Configuration.Add('_', @{
                StylesPath    = 'styles'
                MinAlertLevel = 'suggestion'
                Packages      = @()
            }
        )
        $Configuration.Add('*', @{
                BasedOnStyles = @()
            }
        )
        $ConfigExists = Test-Path -Path $FilePath
    }

    process {
        if ($ConfigExists -and -not $Force) {
            $ResolvedPath = Resolve-Path $FilePath
            $Message = "Specified Vale configuration file already exists at '$ResolvedPath'."

            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                ([System.ArgumentException]$Message),
                'Vale.ConfigurationFileAlreadyExists',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $FilePath
            )

            $PSCmdlet.ThrowTerminatingError($ErrorRecord)
        }

        if (![string]::IsNullOrEmpty($StylesPath)) {
            $Configuration._.StylesPath = $StylesPath
        }

        if ($null -ne $MinimumAlertLevel) {
            $Configuration._.MinAlertLevel = $MinimumAlertLevel.ToString().ToLowerInvariant()
        }

        if (!$NoSpelling) {
            $Configuration['*'].BasedOnStyles += 'Vale'
        } elseif ($StylePackage.Count -eq 0) {
            $Message = @(
                'Must specify at least one style for the configuration when specifying NoSpelling.'
                'Run the command again with at least one package specified for StylePackage'
                'or without NoSpelling.'
            ) -join ' '

            $ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
                ([System.ArgumentException]$Message),
                'Vale.NoStylePackagesSpecified',
                [System.Management.Automation.ErrorCategory]::InvalidArgument,
                $PSBoundParameters
            )

            $PSCmdlet.ThrowTerminatingError($ErrorRecord)
        }

        foreach ($Package in $StylePackage) {
            # Skip duplicates
            if ($Package -in $Configuration._.Packages) {
                Write-Warning "Skipping duplicate package '$Package'"
                continue
            }

            # For built-in packages, the package name and style name are the same.
            $Style = $Package

            # .zip packages are local or remote styles not built into Vale
            if ($Package -match '.zip$') {
                # Split for the last path segment, trim the '.zip' from the end.
                # Definitionally, vale style packages must have the same name
                # as their zip file.
                $Style = (Split-Path $Package -Leaf) | ForEach-Object {
                    $_.Substring(0, $_.Length - 4)
                }
            }

            $Configuration._.Packages += $Package
            $Configuration['*'].BasedOnStyles += $Style
        }

        # These need to convert to comma-separated strings for Vale to be happy;
        # PsIni adds arrays as repeated entries by default.
        $Configuration._.Packages = $Configuration._.Packages -join ', '
        $Configuration['*'].BasedOnStyles = $Configuration['*'].BasedOnStyles -join ', '

        try {
            $OutputParameters = @{
                InputObject = $Configuration
                FilePath    = $FilePath
                Force       = $Force
                Passthru    = $PassThru
                ErrorAction = 'Stop'
            }
            Out-IniFile @OutputParameters

            if (!$NoSync) {
                Sync-Vale -Path $FilePath
            }
        } catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}
