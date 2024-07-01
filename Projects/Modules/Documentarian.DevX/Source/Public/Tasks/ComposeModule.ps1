# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Synopsis: Compose the module from source files
task ComposeModule InitializeDevXConfiguration, {
  <#
    .SYNOPSIS
  #>

  Build-ComposedModule -ProjectRootFolderPath $BuildRoot
}
