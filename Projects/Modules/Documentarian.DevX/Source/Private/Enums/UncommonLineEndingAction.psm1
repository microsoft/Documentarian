# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

enum UncommonLineEndingAction {
  <#
    .SYNOPSIS
    Defines the action to take when an uncommon line ending is encountered.

    .DESCRIPTION
    Defines the action to take when an uncommon line ending is encountered. An uncommon line ending
    is a line ending that is not the standard line ending for the current platform.

    .LABEL SilentlyContinue
    Ignore the uncommon line ending and continue processing.

    .LABEL WarnAndContinue
    Emit a warning about the uncommon line ending and continue processing.

    .LABEL ErrorAndStop
    Emit an error about the uncommon line ending and stop processing.
  #>

  SilentlyContinue = 0
  WarnAndContinue  = 1
  ErrorAndStop     = 2
}
