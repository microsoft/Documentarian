# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

function New-ArgumentCompleterDefinition {
  <#
    .SYNOPSIS
  #>

  [CmdletBinding()]
  param(
    [Parameter()]
    [string[]]
    $Path = './ArgumentCompleter.psd1',

    [Parameter()]
    [string]
    $CopyrightNotice,

    [Parameter()]
    [string]
    $LicenseNotice,

    [Parameter()]
    [string[]]
    $CommandName,

    [Parameter()]
    [string]
    $ParameterName,

    [Parameter()]
    [scriptblock]
    $ScriptBlock,

    [Parameter()]
    [switch]
    $Native,

    [Parameter()]
    [switch]
    $Force
  )

  begin {
    $content = @()
    # Handle adding notices to the top of the file, if needed.
    $hasCopyrightNotice = -not [string]::IsNullOrEmpty($CopyrightNotice)
    $hasLicenseNotice   = -not [string]::IsNullOrEmpty($LicenseNotice)
    if ($hasCopyrightNotice) { $content += "# $CopyrightNotice" }
    if ($hasLicenseNotice) { $content += "# $LicenseNotice" }
    if ($hasCopyrightNotice -or $hasLicenseNotice) {
      $content += ''
    }

    # Add contextual help for future editors of the file.
    $content += @(
      '# The key-value pairs are parameters for the Register-ArgumentCompleter cmdlet.'
      '# For more information, run `Get-Help Register-ArgumentCompleter` or see:'
      '# https://learn.microsoft.com/powershell/module/microsoft.powershell.core/register-argumentcompleter'
    )

    $powerShellCommandParamBlock = @(
      '        param('
      '            $commandName,'
      '            $parameterName,'
      '            $wordToComplete,'
      '            $commandAst,'
      '            $fakeBoundParameters'
      '        )'
    ) -join "`n"
    $nativeCommandParamBlock = @(
      '        param('
      '            $wordToComplete,'
      '            $commandAst,'
      '            $cursorPosition'
      '        )'
    ) -join "`n"

    $content += @(
      '@{'
      "    CommandName   = '$($CommandName -join "', '")'"
      "    ParameterName = '$ParameterName'"
      '    ScriptBlock   = {'
        ($Native ? $nativeCommandParamBlock : $powerShellCommandParamBlock)
      ''
      '        # Script block body here.'
      ''
      '    }'
      '}'
    )

    $content = $content -join "`n"
  }

  process {
    if ($null -ne $ScriptBlock) {
      # Parse the script block to get the parameter names, make sure they're correct.
      $parameterNames         = $ScriptBlock.Ast.ParamBlock.Parameters.Name
      $parameterCount         = $ParameterNames.Count
      $expectedParameterCount = $Native ? 3 : 5

      if ($parameterCount -ne $expectedParameterCount) {
        $errorMessage = @(
          "The scriptblock must have $expectedParameterCount parameters,"
          "but had $parameterCount ('$($parameterNames -join ', ')')."
          'Use the following parameter block for the scriptblock.'
          "`n"
            ($Native ? $nativeCommandParamBlock : $powerShellCommandParamBlock)
          "`n"
          'For more information, see the Register-ArgumentCompleter cmdlet.'
        ) -join ' '
      }
      $PSCmdlet.ThrowTerminatingError(
        [System.Management.Automation.ErrorRecord]::new(
          [System.ArgumentException]::new($errorMessage),
          'InvalidArgumentCompleterScriptBlock',
          'InvalidArgumentCompleter',
          $null
        )
      )
    }

    if ((Test-Path -Path $Path) -and -not $Force) {
      $errorMessage = @(
        "The file '$((Get-Item $Path).FullName)' already exists."
        'Use the -Force switch to overwrite the file.'
      ) -join ' '
      $PSCmdlet.ThrowTerminatingError(
        [System.Management.Automation.ErrorRecord]::new(
          [System.IO.IOException]::new($errorMessage),
          'FileAlreadyExists',
          'ResourceExists',
          $null
        )
      )
    }

    $file = New-Item -Path $Path -ItemType File -Force
    $content | Out-File -FilePath $file -Encoding utf8NoBOM -Force
    $file
  }

  end {

  }
}
