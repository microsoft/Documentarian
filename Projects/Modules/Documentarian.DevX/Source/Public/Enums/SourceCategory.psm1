# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

enum SourceCategory {
  <#
    .SYNOPSIS
    Defines the category of the a source file.

    .DESCRIPTION
    Defines the category of the a source file. A source file's category determines how the source
    file should be processed for module composition and reference lookup.

    .LABEL ArgumentCompleter
    Indicates that the source file defines a PowerShell argument completer.

    .LABEL Class
    Indicates that the source file defines a PowerShell class.

    .LABEL Enum
    Indicates that the source file defines a PowerShell enumeration.

    .LABEL Function
    Indicates that the source file defines a PowerShell function.

    .LABEL Format
    Indicates that the source file defines a PowerShell object format definition, a snippet for the
    module's `format.ps1xml` file.

    .LABEL Task
    Indicates that the source file defines an Invoke-Build task.

    .LABEL Type
    Indicates that the source file defines a PowerShell extended type definition, a snippet for the
    module's `types.ps1xml` file.
  #>

  ArgumentCompleter
  Class
  Enum
  Function
  Format
  Task
  Type
}
