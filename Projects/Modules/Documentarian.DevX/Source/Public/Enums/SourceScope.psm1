# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

enum SourceScope {
  <#
    .SYNOPSIS
    Defines the scope of a source file.

    .DESCRIPTION
    Defines the scope of a source file. The scope determines how the source file should be
    processed for module composition. Public source files are included in the module's public
    root module manifest, while private source files are placed in the `<ModuleName>.Private.psm1`
    module manifest.

    Module composition defines type accelerators for public classes and enumerations, making them
    available to users when they call `Import-Module`, without needing to also call `using module`.
    It also ensures that all public functions are included in the generated module manifest as
    exported functions.

    .LABEL Private
    Indicates that the source file is private and should not be included in the module's public
    interface.

    .LABEL Public
    Indicates that the source file is public and should be included in the module's public
    interface.
  #>

  Private
  Public
}
