# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

using module ../Classes/DevXAstInfo.psm1
using module ../Classes/DevXValidatePowerShellScriptPathAttribute.psm1

Function Get-Ast {
  [CmdletBinding()]
  [OutputType([DevXAstInfo])]
  param(
    [Parameter(Mandatory, ParameterSetName = 'ByPath')]
    [DevXValidatePowerShellScriptPathAttribute()]
    [string]$Path,

    [Parameter(Mandatory, ParameterSetName = 'ByScriptBlock')]
    [scriptblock]$ScriptBlock,

    [Parameter(Mandatory, ParameterSetName = 'ByInputText')]
    [ValidateNotNullOrEmpty()]
    [string]$Text
  )

  begin {}

  process {
    switch ($PSCmdlet.ParameterSetName) {
      'ByPath' {
        $Path = Resolve-Path -Path $Path -ErrorAction Stop
        [DevXAstInfo]::New($Path)
      }
      'ByScriptBlock' {
        [DevXAstInfo]::New($ScriptBlock)
      }
      'ByInputText' {
        [DevXAstInfo]::New([ScriptBlock]::Create($Text))
      }
    }
  }

  end {}
}
