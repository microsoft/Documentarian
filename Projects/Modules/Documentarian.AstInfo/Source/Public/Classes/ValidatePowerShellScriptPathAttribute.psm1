# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

class ValidatePowerShellScriptPathAttribute : System.Management.Automation.ValidateArgumentsAttribute {

    hidden static [string] $MessagePrefix = 'Path must be the file path to a PowerShell file'

    hidden static [void] ValidatePathNotNullEmptyOrWhiteSpace($path) {
        if ([string]::IsNullOrEmpty($path) -or $path -match '^\s+$') {
            throw [System.ArgumentNullException]::new(
                'Path cannot be null, empty, or entirely whitespace.'
            )
        }
    }

    hidden static [void] ValidatePathInFileSystemProvider([string]$providerName) {
        if ($providerName -ne 'FileSystem') {
            $Message = @(
                [ValidatePowerShellScriptPathAttribute]::MessagePrefix,
                "specified provider '$providerName' is invalid."
            ) -join '; '
            throw [System.ArgumentException]::new($Message)
        }
    }

    hidden static [void] ValidatePathIsPowerShellFile([string]$extension) {
        $ValidExtensions = @('.psd1', '.ps1', '.psm1')
        $isNotPowerShellFile = $extension -notin $ValidExtensions
        if ($isNotPowerShellFile) {
            $Message = @(
                [ValidatePowerShellScriptPathAttribute]::MessagePrefix,
                "; specified file extension '$extension' is invalid."
                "Valid extensions are: '$($ValidExtensions -join "', '")'"
            ) -join ' '
            throw [System.ArgumentException]::new($Message)
        }
    }

    [void]  Validate(
        [object]$arguments,
        [System.Management.Automation.EngineIntrinsics]$engineIntrinsics
    ) {
        <#
            .SYNOPSIS
            Validates that the specified path is a valid path to a PowerShell script file.

            .DESCRIPTION
            Validates that the specified path is a valid path to a PowerShell script file. A path
            is valid if it meets these criteria:

            1. It's not null, empty, or entirely whitespace.
            1. The path resolves to an item in the FileSystem provider.
            1. The item has a valid PowerShell file extension: `*.ps1`, `*.psm1`, or `*.psd1`.
        #>
        $Path = $arguments

        [ValidatePowerShellScriptPathAttribute]::ValidatePathNotNullEmptyOrWhiteSpace(
            $Path
        )

        try {
            $Item = Get-Item -Path $Path -ErrorAction Stop
        } catch [System.Management.Automation.ItemNotFoundException] {
            throw [System.IO.FileNotFoundException]::new(
                "Could not find file '$Path'."
            )
        }

        [ValidatePowerShellScriptPathAttribute]::ValidatePathInFileSystemProvider(
            $Item.PSProvider.Name
        )
        [ValidatePowerShellScriptPathAttribute]::ValidatePathIsPowerShellFile(
            $Item.Extension
        )
    }
}
