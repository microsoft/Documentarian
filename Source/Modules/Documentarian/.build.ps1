# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#requires -Version 7.2
#requires -Module InvokeBuild
#requires -Module Documentarian.DevX

<#
  .SYNOPSIS
  Build script for the Documentarian project using `Invoke-Build`
#>

[CmdletBinding()]
param(
  $Configuration = 'Test'
)

# Import the bundled tasks from Documentarian.DevX
. DevX.Tasks

# Default task composes the module and writes the manifest
task . ComposeModule
