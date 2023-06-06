# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

enum ClassLogLevels {
    # The class shouldn't write any log messages.
    None = 0
    # The class should write basic log messages.
    # Equivalent to verbose logging.
    Basic = 1
    # The class should write detailed log messages.
    # Equivalent to debug logging.
    Detailed = 2
}
