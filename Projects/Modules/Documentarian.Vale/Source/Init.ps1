# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

<#
  .SYNOPSIS
    Initializes state for the module on load.
  .DESCRIPTION
    This script file initializes state for the Documentarian.Vale module
    to make it easier to work with the module's classes, configuration,
    and enums.

    It runs in the caller's session state when the module is loaded to
    obviate the need to remember to call the `using` statement on the
    module and ensures the public classes and enums are available.
#>

$PackageNameCompleter = {
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

$PackageNameCompleterParams = @{
  CommandName   = 'New-ValeConfiguration'
  ParameterName = 'StylePackage'
  ScriptBlock   = $PackageNameCompleter
}
Register-ArgumentCompleter @PackageNameCompleterParams
