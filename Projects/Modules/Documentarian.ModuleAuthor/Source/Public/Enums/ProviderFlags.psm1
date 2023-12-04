# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

[Flags()] enum ProviderFlags {
    Registry    = 0x01
    Alias       = 0x02
    Environment = 0x04
    FileSystem  = 0x08
    Function    = 0x10
    Variable    = 0x20
    Certificate = 0x40
    WSMan       = 0x80
}
