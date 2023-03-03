# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Synopsis: Compose the module from source files
task ComposeModule InitializeDevXConfiguration, {
  Build-ComposedModule -ProjectRootFolderPath $BuildRoot
}
