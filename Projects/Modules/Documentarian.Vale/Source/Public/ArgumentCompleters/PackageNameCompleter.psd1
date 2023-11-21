# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# The key-value pairs are parameters for the Register-ArgumentCompleter cmdlet.
# For more information, run `Get-Help Register-ArgumentCompleter` or see:
# https://learn.microsoft.com/powershell/module/microsoft.powershell.core/register-argumentcompleter
@{
    CommandName   = 'New-ValeConfiguration'
    ParameterName = 'StylePackage'
    ScriptBlock   = {
        param(
            $commandName,
            $parameterName,
            $wordToComplete,
            $commandAst,
            $fakeBoundParameters
        )

        [ValeKnownStylePackage].GetEnumNames() | Where-Object {
            $_ -like "$wordToComplete*"
        } | ForEach-Object {
            $_
        }
    }
}
