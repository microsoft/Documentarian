# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function New-ArgumentCompleterDefinition {
    [CmdletBinding()]
    param(
        [string[]]$Path = './ArgumentCompleter.psd1',
        [string]$CopyrightNotice,
        [string]$LicenseNotice,
        [string[]]$CommandName,
        [string]$ParameterName,
        [scriptblock]$ScriptBlock,
        [switch]$Native,
        [switch]$Force
    )

    begin {
        $Content = @()
        # Handle adding notices to the top of the file, if needed.
        $HasCopyrightNotice = -not [string]::IsNullOrEmpty($CopyrightNotice)
        $HasLicenseNotice = -not [string]::IsNullOrEmpty($LicenseNotice)
        if ($HasCopyrightNotice) { $Content += "# $CopyrightNotice" }
        if ($HasLicenseNotice) { $Content += "# $LicenseNotice" }
        if ($HasCopyrightNotice -or $HasLicenseNotice) { $Content += '' }

        # Add contextual help for future editors of the file.
        $Content += @(
            '# The key-value pairs are parameters for the Register-ArgumentCompleter cmdlet.'
            '# For more information, run `Get-Help Register-ArgumentCompleter` or see:'
            '# https://learn.microsoft.com/powershell/module/microsoft.powershell.core/register-argumentcompleter'
        )

        $PowerShellCommandParamBlock = @(
            '        param('
            '            $commandName,'
            '            $parameterName,'
            '            $wordToComplete,'
            '            $commandAst,'
            '            $fakeBoundParameters'
            '        )'
        ) -join "`n"
        $NativeCommandParamBlock = @(
            '        param('
            '            $wordToComplete,'
            '            $commandAst,'
            '            $cursorPosition'
            '        )'
        ) -join "`n"

        $Content += @(
            '@{'
            "    CommandName   = '$($CommandName -join "', '")'"
            "    ParameterName = '$ParameterName'"
            '    ScriptBlock   = {'
            ($Native ? $NativeCommandParamBlock : $PowerShellCommandParamBlock)
            ''
            '        # Script block body here.'
            ''
            '    }'
            '}'
        )

        $Content = $Content -join "`n"
    }

    process {
        if ($null -ne $ScriptBlock) {
            # Parse the script block to get the parameter names, make sure they're correct.
            $ParameterNames = $ScriptBlock.Ast.ParamBlock.Parameters.Name
            $ParameterCount = $ParameterNames.Count
            $ExpectedParameterCount = $Native ? 3 : 5
            if ($ParameterCount -ne $ExpectedParameterCount) {
                $ErrorMessage = @(
                    "The scriptblock must have $ExpectedParameterCount parameters,"
                    "but only had $ParameterCount ($($ParameterNames -join ', '))."
                    'Use the following parameter block for the scriptblock.'
                    "`n"
                    ($Native ? $NativeCommandParamBlock : $PowerShellCommandParamBlock)
                    "`n"
                    'For more information, see the Register-ArgumentCompleter cmdlet.'
                ) -join ' '
            }
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    [System.ArgumentException]::new($ErrorMessage),
                    'InvalidArgumentCompleterScriptBlock',
                    'InvalidArgumentCompleter',
                    $null
                )
            )
        }

        if ((Test-Path -Path $Path) -and -not $Force) {
            $Message = @(
                "The file '$((Get-Item $Path).FullName)' already exists."
                'Use the -Force switch to overwrite the file.'
            ) -join ' '
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    [System.IO.IOException]::new($Message),
                    'FileAlreadyExists',
                    'ResourceExists',
                    $null
                )
            )
        }

        $File = New-Item -Path $Path -ItemType File -Force
        $Content | Out-File -FilePath $File -Encoding utf8NoBOM -Force
        $File
    }
}
