# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

enum ClassLogLevels {
    <#
        .SYNOPSIS
        Defines the logging levels for classes.

        .DESCRIPTION
        Defines the logging levels for classes. The logging level determines the amount of log
        messages that a class should write when it performs operations.

        .LABEL None
        The class shouldn't write any log messages.

        .LABEL Basic
        The class should write basic log messages. Equivalent to verbose logging.

        .LABEL Detailed
        The class should write detailed log messages. Equivalent to debug logging.
    #>

    None     = 0
    Basic    = 1
    Detailed = 2
}
